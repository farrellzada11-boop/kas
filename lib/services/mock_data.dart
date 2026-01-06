import '../models/user_model.dart';
import '../models/train_model.dart';
import '../models/station_model.dart';
import '../models/schedule_model.dart';
import '../models/booking_model.dart';

class MockData {
  // Mock Users
  static final List<User> users = [
    User(
      id: '1',
      name: 'Farrel Zada',
      email: 'user@mail.com',
      phone: '081234567890',
      role: UserRole.user,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: '2',
      name: 'Admin KAI',
      email: 'admin@mail.com',
      phone: '081234567891',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Mock Stations
  static final List<Station> stations = [
    Station(id: '1', name: 'Gambir', code: 'GMR', city: 'Jakarta'),
    Station(id: '2', name: 'Bandung', code: 'BD', city: 'Bandung'),
    Station(id: '3', name: 'Yogyakarta', code: 'YK', city: 'Yogyakarta'),
    Station(id: '4', name: 'Surabaya Gubeng', code: 'SGU', city: 'Surabaya'),
    Station(id: '5', name: 'Semarang Tawang', code: 'SMT', city: 'Semarang'),
    Station(id: '6', name: 'Solo Balapan', code: 'SLO', city: 'Solo'),
    Station(id: '7', name: 'Malang', code: 'ML', city: 'Malang'),
    Station(id: '8', name: 'Cirebon', code: 'CN', city: 'Cirebon'),
  ];

  // Mock Trains
  static final List<Train> trains = [
    Train(
      id: '1',
      name: 'Argo Parahyangan',
      code: 'AP-01',
      type: 'Eksekutif',
      facilities: ['AC', 'WiFi', 'Restaurant', 'Power Outlet', 'Reclining Seat'],
      totalSeats: 400,
    ),
    Train(
      id: '2',
      name: 'Argo Wilis',
      code: 'AW-02',
      type: 'Eksekutif',
      facilities: ['AC', 'WiFi', 'Restaurant', 'Power Outlet'],
      totalSeats: 350,
    ),
    Train(
      id: '3',
      name: 'Taksaka',
      code: 'TK-03',
      type: 'Eksekutif',
      facilities: ['AC', 'WiFi', 'Toilet', 'Power Outlet'],
      totalSeats: 380,
    ),
    Train(
      id: '4',
      name: 'Gajayana',
      code: 'GJ-04',
      type: 'Bisnis',
      facilities: ['AC', 'Toilet', 'Power Outlet'],
      totalSeats: 450,
    ),
    Train(
      id: '5',
      name: 'Matarmaja',
      code: 'MM-05',
      type: 'Ekonomi',
      facilities: ['AC', 'Toilet'],
      totalSeats: 600,
    ),
    Train(
      id: '6',
      name: 'Lodaya',
      code: 'LD-06',
      type: 'Bisnis',
      facilities: ['AC', 'WiFi', 'Toilet'],
      totalSeats: 420,
    ),
  ];

  // Mock Schedules
  static List<Schedule> get schedules {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      // Jakarta - Bandung
      Schedule(
        id: '1',
        train: trains[0],
        origin: stations[0], // Gambir
        destination: stations[1], // Bandung
        departureTime: today.add(const Duration(hours: 6, minutes: 30)),
        arrivalTime: today.add(const Duration(hours: 9, minutes: 30)),
        price: 150000,
        availableSeats: 120,
      ),
      Schedule(
        id: '2',
        train: trains[0],
        origin: stations[0],
        destination: stations[1],
        departureTime: today.add(const Duration(hours: 12, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 15, minutes: 0)),
        price: 175000,
        availableSeats: 85,
      ),
      // Jakarta - Yogyakarta
      Schedule(
        id: '3',
        train: trains[2],
        origin: stations[0], // Gambir
        destination: stations[2], // Yogyakarta
        departureTime: today.add(const Duration(hours: 7, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 14, minutes: 30)),
        price: 350000,
        availableSeats: 200,
      ),
      Schedule(
        id: '4',
        train: trains[2],
        origin: stations[0],
        destination: stations[2],
        departureTime: today.add(const Duration(hours: 20, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 3, minutes: 30)).add(const Duration(days: 1)),
        price: 320000,
        availableSeats: 150,
      ),
      // Jakarta - Surabaya
      Schedule(
        id: '5',
        train: trains[1],
        origin: stations[0], // Gambir
        destination: stations[3], // Surabaya
        departureTime: today.add(const Duration(hours: 8, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 17, minutes: 0)),
        price: 450000,
        availableSeats: 100,
      ),
      // Bandung - Yogyakarta
      Schedule(
        id: '6',
        train: trains[3],
        origin: stations[1], // Bandung
        destination: stations[2], // Yogyakarta
        departureTime: today.add(const Duration(hours: 9, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 15, minutes: 0)),
        price: 250000,
        availableSeats: 180,
      ),
      // Semarang - Surabaya
      Schedule(
        id: '7',
        train: trains[4],
        origin: stations[4], // Semarang
        destination: stations[3], // Surabaya
        departureTime: today.add(const Duration(hours: 10, minutes: 30)),
        arrivalTime: today.add(const Duration(hours: 15, minutes: 0)),
        price: 180000,
        availableSeats: 250,
      ),
      // Solo - Malang
      Schedule(
        id: '8',
        train: trains[5],
        origin: stations[5], // Solo
        destination: stations[6], // Malang
        departureTime: today.add(const Duration(hours: 11, minutes: 0)),
        arrivalTime: today.add(const Duration(hours: 17, minutes: 0)),
        price: 200000,
        availableSeats: 160,
      ),
    ];
  }

  // Mock Bookings
  static List<Booking> get bookings {
    return [
      Booking(
        id: '1',
        bookingCode: 'KAS-2024-001',
        user: users[0],
        schedule: schedules[0],
        passengers: [
          Passenger(name: 'Farrel Zada', idNumber: '3201234567890001', seatNumber: 'A1'),
        ],
        totalPrice: 150000,
        status: BookingStatus.confirmed,
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
        paymentDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Booking(
        id: '2',
        bookingCode: 'KAS-2024-002',
        user: users[0],
        schedule: schedules[2],
        passengers: [
          Passenger(name: 'Farrel Zada', idNumber: '3201234567890001', seatNumber: 'B5'),
          Passenger(name: 'Aisyah', idNumber: '3201234567890002', seatNumber: 'B6'),
        ],
        totalPrice: 700000,
        status: BookingStatus.pending,
        bookingDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Booking(
        id: '3',
        bookingCode: 'KAS-2024-003',
        user: users[0],
        schedule: schedules[4],
        passengers: [
          Passenger(name: 'Farrel Zada', idNumber: '3201234567890001', seatNumber: 'C10'),
        ],
        totalPrice: 450000,
        status: BookingStatus.completed,
        bookingDate: DateTime.now().subtract(const Duration(days: 10)),
        paymentDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  // Helper methods
  static User? getUserByEmail(String email) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  static List<Schedule> searchSchedules({
    required String originId,
    required String destinationId,
    DateTime? date,
  }) {
    return schedules.where((s) {
      final matchOrigin = s.origin.id == originId;
      final matchDestination = s.destination.id == destinationId;
      if (date != null) {
        final matchDate = s.departureTime.year == date.year &&
            s.departureTime.month == date.month &&
            s.departureTime.day == date.day;
        return matchOrigin && matchDestination && matchDate;
      }
      return matchOrigin && matchDestination;
    }).toList();
  }

  static List<Booking> getUserBookings(String userId) {
    return bookings.where((b) => b.user.id == userId).toList();
  }
}
