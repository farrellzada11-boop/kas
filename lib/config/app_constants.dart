class AppConstants {
  // App Info
  static const String appName = 'KAS - Kereta Api System';
  static const String appVersion = '1.0.0';
  
  // Toggle between Mock Data and API
  // Set to false when CI4 backend is running
  static const bool useMockData = false;
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String trainsEndpoint = '/trains';
  static const String schedulesEndpoint = '/schedules';
  static const String stationsEndpoint = '/stations';
  static const String bookingsEndpoint = '/bookings';
  static const String usersEndpoint = '/users';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String roleKey = 'user_role';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int phoneLength = 12;
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  
  // Train Classes
  static const List<String> trainClasses = ['Eksekutif', 'Bisnis', 'Ekonomi'];
  
  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}
