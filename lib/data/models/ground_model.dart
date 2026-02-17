class Ground {
  final int id;
  final String slug;
  final String name;
  final String address;
  final String city;
  final double rating;
  final String? mainImage;
  final String startingPrice;
  final bool isFeatured;
  final List<String> amenities;
  final double latitude;
  final double longitude;

  Ground({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.city,
    required this.rating,
    this.mainImage,
    required this.startingPrice,
    this.isFeatured = false,
    this.amenities = const [],
    this.latitude = 24.8607, // Default Karachi lat
    this.longitude = 67.0011, // Default Karachi lng
  });

  factory Ground.fromJson(Map<String, dynamic> json) {
    // Handle complex object for location
    final complex = json['complex'] ?? {};
    final address =
        complex['address'] ??
        complex['name'] ??
        json['address'] ??
        'Location not available';
    final city = complex['city'] ?? json['city'] ?? '';

    // Handle images array
    String? imageUrl = json['main_image'];
    if (imageUrl == null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List)[0];
    }
    // Fallback images if none provided (matching web app style)
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl =
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800&q=80';
    }

    return Ground(
      id: json['id'],
      slug: json['slug'] ?? 'ground-${json['id']}',
      name: json['name'] ?? 'Unknown Ground',
      address: address,
      city: city,
      rating: (json['rating'] ?? complex['rating'] ?? 4.5).toDouble(),
      mainImage: imageUrl,
      startingPrice:
          json['price_per_hour']?.toString() ??
          json['starting_price']?.toString() ??
          '0',
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      amenities:
          (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      latitude:
          double.tryParse(json['latitude']?.toString() ?? '') ??
          double.tryParse(complex['latitude']?.toString() ?? '') ??
          24.8607,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '') ??
          double.tryParse(complex['longitude']?.toString() ?? '') ??
          67.0011,
    );
  }

  // Getters for display
  String get locationString => '$address, $city';
  String get priceDisplay => '\$$startingPrice/hr';
  double get price => double.tryParse(startingPrice) ?? 0.0;
}
