class Complex {
  final int id;
  final String name;
  final String address;
  final String description;

  Complex({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
  });

  factory Complex.fromJson(Map<String, dynamic> json) {
    return Complex(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Ground {
  final int id;
  final String name;
  final double pricePerHour;
  final String description;
  final String location;
  final int complexId;
  final String status;
  final String type;
  final List<String>? images;

  Ground({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.description,
    required this.location,
    required this.complexId,
    required this.status,
    required this.type,
    this.images,
  });

  factory Ground.fromJson(Map<String, dynamic> json) {
    return Ground(
      id: json['id'],
      name: json['name'] ?? '',
      pricePerHour: double.tryParse(json['price_per_hour'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      complexId: json['complex_id'] ?? 0,
      status: json['status'] ?? 'active',
      type: json['type'] ?? 'cricket',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}
