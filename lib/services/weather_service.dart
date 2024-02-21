import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class WeatherService {

  static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String? apiKey;

  WeatherService({required this.apiKey});

  Future<Weather> getWeather(String cidade) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$cidade&appid=$apiKey&units=metric&lang=pt_br'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    // dev.log(placemarks.toString());
     dev.log('chamado');

    String? city = placemarks[0].subAdministrativeArea;

    return city ?? "";

  }

  Future<String?> getPreciseLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    dev.log(placemarks.toString());

    String? number = placemarks[0].name;
    String? street = placemarks[0].street;
    

    if (number != null && street != null) {
      return "$street - $number";
    } else {
      return null;
    }

  }

}