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
    _calculateTime(_weather?.timezone);

  }

  @override
  void dispose() {
    super.dispose();
  }

  late String _apiKey;
  late WeatherService _weatherService;
  bool _isLoading = false;
  bool _isNight = false;

  Weather? _weather;
  // inicializar api
  Future<void> _initializeData() async {
    _apiKey = dotenv.env['API_KEY'] ?? "";
    _weatherService = WeatherService(apiKey: _apiKey);
  }

  // calcular horario no local escolhido, para saber se e noite
  int _calculateTime(int? timezone) {
    if (timezone == null) return 10;
    int currentTimezone = (timezone / 3600).round();
    DateTime nowUTC = DateTime.now().toUtc();
    int localHour = nowUTC.hour + currentTimezone;
    dev.log(localHour.toString());
      if ((localHour >= 18 && localHour <= 23) || (localHour >= 0 && localHour <= 4)) {
        setState(() {
          _isNight = true;
        });
      } else {
        setState(() {
          _isNight = false;
        });
      }
    return localHour;
  }

  // carregar dados do clima do local do dispositivo
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
        dev.log(_weather.toString());
      });
    } catch (e) {
      dev.log(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  // carregar dados do clima de uma cidade escolhida
  void _fetchWeather(String cidade) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final weather = await _weatherService.getWeather(cidade);
      setState(() {
        _weather = weather;
         dev.log(_weather.toString());
      });
    } catch (e) {
      dev.log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // carregar animacao dependendo da condicao climatica
  String getWeatherAnimation(int? conditionID) {
    if (conditionID == null) return 'assets/clear_day.json';

    switch (conditionID) {
      case (>800 && <803) || (>700 && < 760):
        return 'assets/clouds.json'; //nuvers+sol
      case 803 || 804:
        return 'assets/clouds.json'; //nuvers+sol
      case >=300 && < 600:
        return 'assets/rain_day.json';
      case >=200 && <300:
        return 'assets/storm.json';
      case 800:
        return 'assets/clear_day.json';
      default:
        return 'assets/clear_day.json';
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
              // Text(_weather?.preciseLocation != null ? '${_weather!.preciseLocation}' : ''),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_weather?.preciseLocation != null)
                    const Icon(Icons.location_on_outlined),
                  Text(_weather?.preciseLocation != null
                      ? '${_weather!.preciseLocation}'
                      : ''),
                ],
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLoading)
                      Lottie.asset(getWeatherAnimation(_weather?.conditionID)),
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
