import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'package:weather_animation/weather_animation.dart';

class WeatherTile extends StatelessWidget {
  final Weather weather;
  final List<Weather> forecast;

  const WeatherTile({Key? key, required this.weather, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildWeatherScene(),
          ),
          Column(
            children: [
              _buildCurrentWeatherSection(),
              _buildForecastSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherScene() {
    WeatherScene weatherScene = _getWeatherScene();
    return WeatherSceneWidget(weatherScene: weatherScene);
  }

  WeatherScene _getWeatherScene() {
    if(weather.weatherDescription.toString()=="sunny"){
      return WeatherScene.scorchingSun;
    }
    if(weather.weatherDescription.toString()=="cloudy"){
      return WeatherScene.rainyOvercast;
    }
    if(weather.weatherDescription.toString()=="clear sky"){
      return WeatherScene.scorchingSun;
    }
    return WeatherScene.weatherEvery;
  }

  Widget _buildCurrentWeatherSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              weather.areaName ?? "",
              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              _formatTime(weather.date),
              style: const TextStyle(fontSize: 18, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${weather.temperature?.celsius?.toStringAsFixed(0) ?? ""}°',
              style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.w200),
            ),
          ),
          Center(
            child: Text(
              weather.weatherDescription ?? "",
              style: const TextStyle(fontSize: 24, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Min: ${weather.tempMin?.celsius?.toStringAsFixed(0) ?? ""}°',
                style: const TextStyle(fontSize: 18, color: Colors.white54),
              ),
              const SizedBox(width: 20),
              Text(
                'Max: ${weather.tempMax?.celsius?.toStringAsFixed(0) ?? ""}°',
                style: const TextStyle(fontSize: 18, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Humidity: ${weather.humidity ?? ""}%',
            style: const TextStyle(fontSize: 18, color: Colors.white54),
          ),
          Text(
            'Feels like: ${weather.tempFeelsLike?.celsius?.toInt() ?? ""}°',
            style: const TextStyle(fontSize: 18, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          padding: const EdgeInsets.only(right: 8,left: 8),
          itemCount: forecast.length,
          itemBuilder: (context, index) {
            Weather dayWeather = forecast[index];
            return Card(
              color: Colors.transparent,
              child: ListTile(
                title: Text(
                  _formatDayName(dayWeather.date),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  dayWeather.weatherDescription ?? "",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  '${dayWeather.temperature?.celsius?.toStringAsFixed(0)}°',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "";
    String formattedTime = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  String _formatDayName(DateTime? date) {
    if (date == null) return "";
    String formattedDay = DateFormat('EEEE').format(date);
    return formattedDay;
  }
}
