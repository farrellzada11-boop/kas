class Train {
  final String id;
  final String name;
  final String code;
  final String type; // Eksekutif, Bisnis, Ekonomi
  final List<String> facilities;
  final int totalSeats;
  final String? imageUrl;

  Train({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.facilities,
    required this.totalSeats,
    this.imageUrl,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    var facilitiesData = json['facilities'];
    List<String> facilitiesList = [];
    
    if (facilitiesData != null) {
      if (facilitiesData is String) {
        // Handle JSON string from API
        try {
          facilitiesList = List<String>.from(
            (facilitiesData as String).isNotEmpty 
              ? List.from(facilitiesData.split(',').map((e) => e.trim()))
              : []
          );
        } catch (e) {
          facilitiesList = [];
        }
      } else if (facilitiesData is List) {
        facilitiesList = List<String>.from(facilitiesData);
      }
    }
    
    return Train(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'Ekonomi',
      facilities: facilitiesList,
      totalSeats: json['total_seats'] is int ? json['total_seats'] : int.tryParse(json['total_seats']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'facilities': facilities,
      'total_seats': totalSeats,
      'image_url': imageUrl,
    };
  }

  String get displayName => '$name ($code)';

  // Facility icons mapping
  static Map<String, String> facilityIcons = {
    'AC': '❄️',
    'WiFi': '📶',
    'Toilet': '🚽',
    'Restaurant': '🍽️',
    'TV': '📺',
    'Power Outlet': '🔌',
    'Reclining Seat': '💺',
  };

  @override
  String toString() => displayName;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Train && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
