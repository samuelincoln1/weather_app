class Weather {
  final String cidade;
  final String temperatura;
  final String condicao;
  final String temperaturaMinima;
  final String temperaturaMaxima;

  Weather({required this.cidade, required this.temperatura, required this.condicao, required this.temperaturaMinima, required this.temperaturaMaxima});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cidade: json['name'],
      temperatura: json['main']['temp'].toDouble(),
      condicao: json['weather'][0]['main'],
      temperaturaMinima: json['main']['temp_min'].toDouble(),
      temperaturaMaxima: json['main']['temp_max'].toDouble(),

    );
  }
}