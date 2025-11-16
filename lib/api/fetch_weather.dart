import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/weather_daily_model.dart';

class WeatherService {
  static const String apiKey = "70f3316bd624d7876896331d9bf56b6a";

  static Future<Weather> getCurrentWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data['current']);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  static Future<List<DailyWeather>> get7DayForecast(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,current,alerts&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List dailyList = data['daily'];
      return dailyList.map((e) => DailyWeather.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load 7-day forecast');
    }
  }
}
