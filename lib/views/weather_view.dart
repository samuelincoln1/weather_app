import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'dart:developer' as dev;

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final _weatherService = WeatherService("89bdf6b34b40a76f051e9289c7e32d9d");
  Weather? _weather;

  void _fetchWeather() async {
    String cidade = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cidade);
      weather.locPrecisa = await _weatherService.getPreciseLocation();
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      dev.log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weather?.locPrecisa ?? ""),
            Text(_weather?.cidade ?? "Carregando..."),
            Text('${_weather?.temperatura.round() ?? ""}°C'),
        
          ],),
      ),
    );
  }
}