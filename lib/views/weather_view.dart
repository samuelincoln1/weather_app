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
    _fetchWeatherCurrentLocation();
    // _timer = Timer.periodic(const Duration(seconds: 3), (timer) {_fetchWeather();});
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  late String _apiKey;
  late WeatherService _weatherService;
  bool _isLoading = false;
  // late Timer _timer;

  Future<void> _initializeData() async {
    _apiKey = dotenv.env['API_KEY'] ?? "";
    _weatherService = WeatherService(apiKey: _apiKey);
  }

  Weather? _weather;

  void _fetchWeatherCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    String cidade = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cidade);
      weather.preciseLocation = await _weatherService.getPreciseLocation();
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      dev.log(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  void _fetchWeather(String cidade) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final weather = await _weatherService.getWeather(cidade);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      dev.log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: Stack(children: [
          if (_isLoading)
            Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Column(
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: PopupMenuButton<String>(
                      surfaceTintColor: Colors.transparent,
                      position: PopupMenuPosition.under,
                      onSelected: (String value) {
                        if (value == 'Meu local') {
                          _fetchWeatherCurrentLocation();
                        } else {
                          setState(() {
                            _fetchWeather(value);
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Meu local',
                          child: Text('Meu local'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'São Paulo',
                          child: Text('São Paulo'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Pesquisar',
                          child: Text('Pesquisar...'),
                        ),
                      ],
                      child: Text(
                        _weather?.city ?? "Carregando...",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(_weather?.preciseLocation ?? ""),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLoading)
                      Lottie.asset(getWeatherAnimation(_weather?.condition)),
                  ],
                ),
              ),
              Text(
                _weather?.temperature != null
                    ? '${_weather!.temperature.round()}°C'
                    : '',
                style: const TextStyle(fontSize: 20),
              ),
              Text(' ${_weather?.conditionDescription ?? ""}'),
              const SizedBox(height: 50)
            ],
          ),
        ]),
      ),
    );
  }
}
