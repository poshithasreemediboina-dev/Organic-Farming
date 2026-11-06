import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches real live weather data from Open-Meteo REST API
  Future<WeatherModel> fetchWeatherData({
    double latitude = AppConstants.defaultLatitude,
    double longitude = AppConstants.defaultLongitude,
    String cityName = AppConstants.defaultCityName,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.weatherApiBaseUrl}?'
      'latitude=$latitude&'
      'longitude=$longitude&'
      'current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&'
      'daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&'
      'timezone=auto',
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'GreenConnect-FlutterApp/1.0',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromOpenMeteoJson(
          json: data,
          cityName: cityName,
        );
      } else {
        throw ApiException(
          'Weather API returned error status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Connection timed out. Please check your internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to retrieve weather data: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
