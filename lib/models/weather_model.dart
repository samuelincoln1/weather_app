class Weather {
  final String city;
  String? preciseLocation;
  final double temperature;
  final String condition;
  final String conditionDescription;
  final double minTemperature;
  final double maxTemperature;

  Weather({required this.city, this.preciseLocation, required this.temperature, required this.condition, required this.conditionDescription, required this.minTemperature, required this.maxTemperature});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      conditionDescription: json['weather'][0]['description'],
      minTemperature: json['main']['temp_min'].toDouble(),
      maxTemperature: json['main']['temp_max'].toDouble(),

    );
  }
}