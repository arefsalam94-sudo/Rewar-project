import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaceWeather {
  const PlaceWeather({
    required this.temperature,
    required this.weatherCode,
    required this.hourly,
  });

  final int temperature;
  final int weatherCode;
  final List<HourlyWeather> hourly;
}

class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  final DateTime time;
  final int temperature;
  final int weatherCode;
}

/// Fetches coordinate-based weather. Weather is intentionally not stored on a
/// place document: doing so would turn a live condition into stale catalog
/// content. Open-Meteo requires no client secret.
class PlaceWeatherService {
  const PlaceWeatherService();

  Future<PlaceWeather> fetch(double latitude, double longitude) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,weather_code',
      'hourly': 'temperature_2m,weather_code',
      'forecast_hours': '5',
      'timezone': 'auto',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Weather request failed (${response.statusCode}).');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>?;
    final hourly = data['hourly'] as Map<String, dynamic>?;
    if (current == null || hourly == null) {
      throw const FormatException('Weather response is incomplete.');
    }
    final times = (hourly['time'] as List?)?.whereType<String>().toList() ?? [];
    final temperatures = hourly['temperature_2m'] as List? ?? const [];
    final codes = hourly['weather_code'] as List? ?? const [];
    final count = [
      times.length,
      temperatures.length,
      codes.length,
    ].reduce((a, b) => a < b ? a : b);
    return PlaceWeather(
      temperature: (current['temperature_2m'] as num).round(),
      weatherCode: (current['weather_code'] as num).toInt(),
      hourly: [
        for (var index = 0; index < count; index++)
          if (temperatures[index] is num && codes[index] is num)
            HourlyWeather(
              time: DateTime.parse(times[index]),
              temperature: (temperatures[index] as num).round(),
              weatherCode: (codes[index] as num).toInt(),
            ),
      ],
    );
  }
}
