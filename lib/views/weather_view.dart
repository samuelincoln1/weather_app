import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'dart:developer' as dev;

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchWeather();
    // _timer = Timer.periodic(const Duration(seconds: 3), (timer) {_fetchWeather();});
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  late String _apiKey;
  late WeatherService _weatherService;
  // late Timer _timer;

  Future<void> _initializeData() async {
    _apiKey = dotenv.env['API_KEY'] ?? "";
    _weatherService = WeatherService(apiKey: _apiKey);
  }

  Weather? _weather;

  void _fetchWeather() async {
    String cidade = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cidade);
      weather.preciseLocation = await _weatherService.getPreciseLocation();
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      dev.log(e.toString());
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/stomry.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_weather?.city ?? "Carregando..."),
              ],
            ),
            Text(_weather?.preciseLocation ?? ""),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(getWeatherAnimation(_weather?.condition)),
                ],
              ),
            ),
            Text('${_weather?.temperature != null ? '${_weather!.temperature.round()}°C - ' : ''} ${_weather?.conditionDescription ?? ""}'),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
