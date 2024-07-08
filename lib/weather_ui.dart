import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/weather_tile.dart';

class WeatherUi extends StatefulWidget {
  const WeatherUi({super.key});

  @override
  State<WeatherUi> createState() => _WeatherUiState();
}

class _WeatherUiState extends State<WeatherUi> {
  final WeatherFactory _wf = WeatherFactory(
      '3a4d85f54c1fe3fa125d481b3ea3b838');
  List<String> _cities = [];
  final List<Weather> _weatherList = [];
  final Map<String, List<Weather>> _forecastMap = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _cities = (prefs.getStringList('cities') ?? []);
    });
    for (String city in _cities) {
      _fetchWeather(city);
    }
  }

  void _saveCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('cities', _cities);
  }

  void _fetchWeather(String cityName) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(cityName);
      List<Weather> forecast = await _wf.fiveDayForecastByCityName(cityName);

      setState(() {
        _weatherList.add(weather);
        _forecastMap[cityName] = forecast;
      });
    } catch (error) {
      print('Error');
   }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCity() {
    String cityName = _searchController.text.trim();
    if (cityName.isNotEmpty && !_cities.contains(cityName)) {
      setState(() {
        _cities.add(cityName);
        _fetchWeather(cityName);
        _saveCities();
      });
    }
    _searchController.clear();
  }

  void _searchCityWeather(String cityName) {
    if (_cities.contains(cityName)) {
      Weather weather = _weatherList.firstWhere((weather) => weather.areaName == cityName);
      List<Weather> forecast = _forecastMap[cityName]!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherTile(weather: weather, forecast: forecast),
        ),
      );
    } else {
      _wf.currentWeatherByCityName(cityName).then((w) {
        _wf.fiveDayForecastByCityName(cityName).then((forecast) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherTile(weather: w, forecast: forecast),
            ),
          );
        });
      }).catchError((error) {});
    }
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Weather",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () {},
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        _searchCityWeather(value);
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addCity,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _weatherList.length,
              itemBuilder: (context, index) {
                Weather weather = _weatherList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: InkWell(
                      onTap: () {
                        List<Weather> forecast = _forecastMap[weather.areaName]!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WeatherTile(weather: weather, forecast: forecast)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.areaName ?? "",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatTime(weather.date),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    weather.weatherDescription ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${weather.temperature?.celsius?.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'H:${weather.tempMax?.celsius?.toInt()}° L:${weather.tempMin?.celsius?.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "";
    String formattedTime = '${date.hour}:${date.minute}';
    return formattedTime;
  }
}
