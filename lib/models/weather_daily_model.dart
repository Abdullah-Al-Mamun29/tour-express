class DailyWeather {
  final String day;
  final double tempDay;
  final double tempNight;
  final String icon;
  final int humidity;
  final double windSpeed;

  DailyWeather({
    required this.day,
    required this.tempDay,
    required this.tempNight,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      day: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          .weekday
          .toString(),
      tempDay: json['temp']['day'].toDouble(),
      tempNight: json['temp']['night'].toDouble(),
      icon: json['weather'][0]['icon'],
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
    );
  }
}
