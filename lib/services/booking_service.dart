import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../config/app_constants.dart';
import 'mock_data.dart';
import 'api_service.dart';

class BookingService extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<Booking> _userBookings = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<Booking> get bookings => _bookings;
  List<Booking> get userBookings => _userBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Keep track of newly created bookings in this session
  static final List<Booking> _sessionBookings = [];

  Future<void> loadAllBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        // Combine mock data with session bookings
        final mockBookings = MockData.bookings;
        final allBookings = <Booking>[];
        
        // Add mock bookings
        for (final booking in mockBookings) {
          allBookings.add(booking);
        }
        
        // Add session bookings (new bookings created in this session)
        for (final booking in _sessionBookings) {
          if (!allBookings.any((b) => b.id == booking.id)) {
            allBookings.add(booking);
          }
        }
        
        _bookings = allBookings;
      } else {
        final response = await _apiService.get('${AppConstants.bookingsEndpoint}/all');
        _bookings = (response['data'] as List).map((e) => Booking.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat booking: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        _userBookings = MockData.getUserBookings(userId);
      } else {
        final response = await _apiService.get(AppConstants.bookingsEndpoint);
        _userBookings = (response['data'] as List).map((e) => Booking.fromJson(e)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat tiket: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking?> createBooking({
    required User user,
    required Schedule schedule,
    required List<Passenger> passengers,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 800));

        final booking = Booking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookingCode: _generateBookingCode(),
          user: user,
          schedule: schedule,
          passengers: passengers,
          totalPrice: schedule.price * passengers.length,
          status: BookingStatus.pending,
          bookingDate: DateTime.now(),
        );

        _userBookings.add(booking);
        _bookings.add(booking);
        _sessionBookings.add(booking); // Add to session bookings for persistence
        
        _isLoading = false;
        notifyListeners();
        return booking;
      } else {
        final response = await _apiService.post(
          AppConstants.bookingsEndpoint,
          {
            'schedule_id': schedule.id,
            'passengers': passengers.map((p) => <String, dynamic>{
              'name': p.name,
              'id_number': p.idNumber,
              'seat_number': p.seatNumber,
            }).toList(),
          },
        );

        final booking = Booking.fromJson(response['data']);
        _userBookings.add(booking);
        _isLoading = false;
        notifyListeners();
        return booking;
      }
    } catch (e) {
      _error = 'Gagal membuat booking: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  String _generateBookingCode() {
    final now = DateTime.now();
    return 'KAS-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  // User pays - changes status to waitingConfirmation
  Future<bool> payBooking(String bookingId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _updateBookingStatus(bookingId, BookingStatus.waitingConfirmation);
      } else {
        await _apiService.put('${AppConstants.bookingsEndpoint}/$bookingId/pay', {});
        await loadAllBookings();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal memproses pembayaran: $e';
      notifyListeners();
      return false;
    }
  }

  // Admin confirms payment - changes status to confirmed
  Future<bool> confirmBooking(String bookingId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _updateBookingStatus(bookingId, BookingStatus.confirmed);
      } else {
        await _apiService.put('${AppConstants.bookingsEndpoint}/$bookingId/confirm', {});
        await loadAllBookings();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal konfirmasi booking: $e';
      notifyListeners();
      return false;
    }
  }

  // Admin completes booking after trip is done
  Future<bool> completeBooking(String bookingId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _updateBookingStatus(bookingId, BookingStatus.completed);
      } else {
        await _apiService.put('${AppConstants.bookingsEndpoint}/$bookingId/complete', {});
        await loadAllBookings();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menyelesaikan booking: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        _updateBookingStatus(bookingId, BookingStatus.cancelled);
      } else {
        await _apiService.put('${AppConstants.bookingsEndpoint}/$bookingId/cancel', {});
        await loadAllBookings();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal membatalkan booking: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateBookingStatus(String bookingId, BookingStatus status) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _bookings[index];
      final updated = Booking(
        id: old.id,
        bookingCode: old.bookingCode,
        user: old.user,
        schedule: old.schedule,
        passengers: old.passengers,
        totalPrice: old.totalPrice,
        status: status,
        bookingDate: old.bookingDate,
        paymentDate: status == BookingStatus.confirmed ? DateTime.now() : old.paymentDate,
      );
      _bookings[index] = updated;

      final userIndex = _userBookings.indexWhere((b) => b.id == bookingId);
      if (userIndex != -1) _userBookings[userIndex] = updated;
    }
  }

  // Statistics for admin
  int get totalBookings => _bookings.length;
  int get pendingBookings => _bookings.where((b) => b.status == BookingStatus.pending).length;
  int get confirmedBookings => _bookings.where((b) => b.status == BookingStatus.confirmed).length;
  int get completedBookings => _bookings.where((b) => b.status == BookingStatus.completed).length;
  
  double get totalRevenue {
    return _bookings
        .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.completed)
        .fold(0, (sum, b) => sum + b.totalPrice);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
