class AppConstants {
  static const int splashDurationMs = 2400;

  // Responsive Breakpoints
  static const double smallPhoneBreakpoint = 360.0;
  static const double normalPhoneBreakpoint = 430.0;
  static const double tabletBreakpoint = 600.0;

  // API Coordinates (Default to Pune Agri-Belt, India)
  static const double defaultLatitude = 18.5204;
  static const double defaultLongitude = 73.8567;
  static const String defaultCityName = 'Pune Agri-Belt';

  // Open-Meteo Weather API Base URL
  static const String weatherApiBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Demo user credentials for quick testing
  static const String demoFarmerEmail = 'farmer@greenconnect.org';
  static const String demoFarmerPassword = 'password123';

  static const String demoAdminEmail = 'admin@greenconnect.org';
  static const String demoAdminPassword = 'adminpassword';
}
