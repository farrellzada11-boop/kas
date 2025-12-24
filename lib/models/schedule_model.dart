import 'station_model.dart';
import 'train_model.dart';

class Schedule {
  final String id;
  final Train train;
  final Station origin;
  final Station destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int availableSeats;
  final bool isActive;

  Schedule({
    required this.id,
    required this.train,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    this.isActive = true,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Handle both nested and flat API responses
    Train train;
    Station origin;
    Station destination;

    // Check if nested or flat structure
    if (json['train'] != null && json['train'] is Map) {
      train = Train.fromJson(json['train']);
    } else {
      // Flat structure from API JOIN query
      train = Train(
        id: json['train_id']?.toString() ?? '',
        name: json['train_name'] ?? '',
        code: json['train_code'] ?? '',
        type: json['train_type'] ?? 'Ekonomi',
        facilities: _parseFacilities(json['facilities']),
        totalSeats: int.tryParse(json['total_seats']?.toString() ?? '0') ?? 0,
      );
    }

    if (json['origin'] != null && json['origin'] is Map) {
      origin = Station.fromJson(json['origin']);
    } else {
      origin = Station(
        id: json['origin_id']?.toString() ?? '',
        name: json['origin_name'] ?? '',
        code: json['origin_code'] ?? '',
        city: json['origin_city'] ?? '',
      );
    }

    if (json['destination'] != null && json['destination'] is Map) {
      destination = Station.fromJson(json['destination']);
    } else {
      destination = Station(
        id: json['destination_id']?.toString() ?? '',
        name: json['destination_name'] ?? '',
        code: json['destination_code'] ?? '',
        city: json['destination_city'] ?? '',
      );
    }

    return Schedule(
      id: json['id']?.toString() ?? '',
      train: train,
      origin: origin,
      destination: destination,
      departureTime: _parseDateTime(json['departure_time']),
      arrivalTime: _parseDateTime(json['arrival_time']),
      price: _parsePrice(json['price']),
      availableSeats: int.tryParse(json['available_seats']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static List<String> _parseFacilities(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) {
      try {
        // Try to parse JSON array string
        if (value.startsWith('[')) {
          return List<String>.from(value.substring(1, value.length - 1).split(',').map((e) => e.trim().replaceAll('"', '')));
        }
        return value.split(',').map((e) => e.trim()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_id': train.id,
      'origin_id': origin.id,
      'destination_id': destination.id,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'price': price,
      'available_seats': availableSeats,
      'is_active': isActive,
    };
  }

  // Calculate duration
  Duration get duration => arrivalTime.difference(departureTime);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}
