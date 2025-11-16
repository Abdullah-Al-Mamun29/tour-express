class Weather {
  final double temp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.temp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: json['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
    );
  }
}
