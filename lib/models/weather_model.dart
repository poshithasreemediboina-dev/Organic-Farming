class DailyForecast {
  final String day;
  final double maxTemp;
  final double minTemp;
  final int rainChance;
  final int weatherCode;

  const DailyForecast({
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
    required this.weatherCode,
  });

  String get conditionText {
    if (weatherCode == 0) return 'Clear';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Rain';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Showers';
    if (weatherCode >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }
}

class WeatherModel {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int weatherCode;
  final String cityName;
  final DateTime lastUpdated;
  final List<DailyForecast> forecast;
  final List<String> recommendations;

  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.cityName,
    required this.lastUpdated,
    this.forecast = const [],
    this.recommendations = const [],
  });

  String get conditionText {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Moderate Weather';
    }
  }

  factory WeatherModel.fromOpenMeteoJson({
    required Map<String, dynamic> json,
    required String cityName,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 26.0;
    final hum = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 60.0;
    final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
    final code = (current['weather_code'] as num?)?.toInt() ?? 0;

    // Parse daily forecast
    List<DailyForecast> dailyForecasts = [];
    final times = daily['time'] as List<dynamic>? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final rainChances = daily['precipitation_probability_max'] as List<dynamic>? ?? [];
    final weatherCodes = daily['weather_code'] as List<dynamic>? ?? [];

    final dayNames = ['Today', 'Tomorrow', 'Day 3', 'Day 4', 'Day 5'];

    for (int i = 0; i < times.length && i < 5; i++) {
      dailyForecasts.add(
        DailyForecast(
          day: i < dayNames.length ? dayNames[i] : 'Day ${i + 1}',
          maxTemp: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : temp + 2,
          minTemp: i < minTemps.length ? (minTemps[i] as num).toDouble() : temp - 4,
          rainChance: i < rainChances.length ? (rainChances[i] as num).toInt() : 10,
          weatherCode: i < weatherCodes.length ? (weatherCodes[i] as num).toInt() : code,
        ),
      );
    }

    // Generate smart agronomic recommendations based on real weather conditions
    List<String> advice = [];
    if (code >= 51 || (dailyForecasts.isNotEmpty && dailyForecasts.first.rainChance > 50)) {
      advice.add('Rain expected: Postpone liquid bio-fertilizer and foliar spray applications to prevent runoff.');
      advice.add('Ensure farm drainage channels are unobstructed to avoid waterlogging in root zones.');
    } else if (temp > 32) {
      advice.add('High temperature: Apply organic straw or leaf mulch to conserve soil moisture and protect root systems.');
      advice.add('Schedule irrigation during early morning (6-8 AM) or late afternoon to minimize evaporation.');
    } else {
      advice.add('Moderate weather: Excellent conditions for applying Jeevamrutha or vermicompost top-dressing.');
      advice.add('Ideal window for hand weeding and monitoring pest traps across vegetable beds.');
    }

    if (hum > 75) {
      advice.add('High relative humidity: Inspect crop foliage for signs of fungal blights or downy mildew.');
      advice.add('Ensure adequate row spacing and pruning to maintain proper air circulation.');
    } else if (hum < 35) {
      advice.add('Low humidity: Protect young seedlings with shade netting or light micro-sprinkling.');
    }

    advice.add('Maintain biodiversity: Check border flowering plants to encourage predatory insects and native pollinators.');

    return WeatherModel(
      temperature: temp,
      humidity: hum,
      windSpeed: wind,
      weatherCode: code,
      cityName: cityName,
      lastUpdated: DateTime.now(),
      forecast: dailyForecasts,
      recommendations: advice,
    );
  }
}
