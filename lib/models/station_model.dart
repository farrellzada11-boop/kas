class Station {
  final String id;
  final String name;
  final String code;
  final String city;
  final String? address;

  Station({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    this.address,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'address': address,
    };
  }

  String get displayName => '$name ($code)';

  @override
  String toString() => displayName;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Station && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
