import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_constants.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  WeatherModel? _weather;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather({bool forceRefresh = false}) async {
    if (_weather != null && !forceRefresh) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchWeatherData(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        cityName: AppConstants.defaultCityName,
      );
      _weather = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void retry() {
    fetchWeather(forceRefresh: true);
  }
}
