class Weather {
  final String city;
  String? preciseLocation;
  final double temperature;
  final String condition;
  final int conditionID;
  final String conditionDescription;
  final double minTemperature;
  final double maxTemperature;
  final int timezone;

  Weather({required this.city, this.preciseLocation, required this.temperature, required this.condition, required this.conditionID, required this.conditionDescription, required this.minTemperature, required this.maxTemperature, required this.timezone});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      conditionDescription: json['weather'][0]['description'],
      conditionID: json['weather'][0]['id'],
      minTemperature: json['main']['temp_min'].toDouble(),
      maxTemperature: json['main']['temp_max'].toDouble(),
      timezone: json['timezone'],

    );
  }

   @override
  String toString() {
    return 'Weather{ '
        'city: $city, '
        'preciseLocation: $preciseLocation, '
        'temperature: $temperature, '
        'condition: $condition, '
        'conditionDescription: $conditionDescription, '
        'conditionID: $conditionID, '
        'minTemperature: $minTemperature, '
        'maxTemperature: $maxTemperature, '
        'timezone: $timezone }';
  }
}