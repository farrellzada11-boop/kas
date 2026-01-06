import 'schedule_model.dart';
import 'user_model.dart';

enum BookingStatus { pending, waitingConfirmation, confirmed, completed, cancelled }

class Passenger {
  final String name;
  final String idNumber;
  final String seatNumber;

  Passenger({
    required this.name,
    required this.idNumber,
    required this.seatNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      name: json['name'] ?? '',
      idNumber: json['id_number'] ?? '',
      seatNumber: json['seat_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id_number': idNumber,
      'seat_number': seatNumber,
    };
  }
}

class Booking {
  final String id;
  final String bookingCode;
  final User user;
  final Schedule schedule;
  final List<Passenger> passengers;
  final double totalPrice;
  final BookingStatus status;
  final DateTime bookingDate;
  final DateTime? paymentDate;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.user,
    required this.schedule,
    required this.passengers,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.paymentDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle user - can be nested object or flat fields
    User user;
    if (json['user'] != null && json['user'] is Map) {
      user = User.fromJson(json['user']);
    } else {
      user = User(
        id: json['user_id']?.toString() ?? '',
        name: json['user_name'] ?? '',
        email: json['user_email'] ?? '',
        phone: json['user_phone'] ?? '',
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
    }

    // Handle schedule - can be nested object or flat fields
    Schedule schedule;
    if (json['schedule'] != null && json['schedule'] is Map) {
      schedule = Schedule.fromJson(json['schedule']);
    } else {
      // Build schedule from flat fields
      schedule = Schedule.fromJson({
        'id': json['schedule_id'],
        'train_id': json['train_id'],
        'train_name': json['train_name'],
        'train_code': json['train_code'],
        'train_type': json['train_type'],
        'origin_id': json['origin_id'],
        'origin_name': json['origin_name'],
        'origin_code': json['origin_code'],
        'destination_id': json['destination_id'],
        'destination_name': json['destination_name'],
        'destination_code': json['destination_code'],
        'departure_time': json['departure_time'],
        'arrival_time': json['arrival_time'],
        'price': json['schedule_price'] ?? json['price'],
        'available_seats': json['available_seats'] ?? 0,
        'is_active': true,
      });
    }

    // Handle passengers
    List<Passenger> passengers = [];
    if (json['passengers'] != null && json['passengers'] is List) {
      passengers = (json['passengers'] as List).map((p) => Passenger.fromJson(p)).toList();
    }

    // Parse dates safely
    DateTime bookingDate = DateTime.now();
    DateTime? paymentDate;
    try {
      if (json['booking_date'] != null) {
        bookingDate = DateTime.parse(json['booking_date'].toString());
      }
      if (json['payment_date'] != null) {
        paymentDate = DateTime.parse(json['payment_date'].toString());
      }
    } catch (e) {
      // Keep default values
    }

    // Parse total price
    double totalPrice = 0.0;
    if (json['total_price'] != null) {
      if (json['total_price'] is double) {
        totalPrice = json['total_price'];
      } else if (json['total_price'] is int) {
        totalPrice = json['total_price'].toDouble();
      } else {
        totalPrice = double.tryParse(json['total_price'].toString()) ?? 0.0;
      }
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      bookingCode: json['booking_code'] ?? '',
      user: user,
      schedule: schedule,
      passengers: passengers,
      totalPrice: totalPrice,
      status: _parseStatus(json['status']),
      bookingDate: bookingDate,
      paymentDate: paymentDate,
    );
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'waiting_confirmation':
        return BookingStatus.waitingConfirmation;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'user': user.toJson(),
      'schedule': schedule.toJson(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'total_price': totalPrice,
      'status': status.name,
      'booking_date': bookingDate.toIso8601String(),
      'payment_date': paymentDate?.toIso8601String(),
    };
  }

  int get passengerCount => passengers.length;

  String get formattedTotalPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu Pembayaran';
      case BookingStatus.waitingConfirmation:
        return 'Menunggu Konfirmasi Admin';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
