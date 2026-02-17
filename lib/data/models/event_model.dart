class Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final double price;
  final int maxParticipants;
  final int currentParticipants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.maxParticipants,
    required this.currentParticipants,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse Date/Time from start_time (e.g. "2024-03-15 14:00:00")
    String date = '';
    String time = '';
    if (json['start_time'] != null) {
      try {
        final parts = json['start_time'].toString().split(' ');
        if (parts.isNotEmpty) date = parts[0];
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          time = '${timeParts[0]}:${timeParts[1]}'; // HH:mm
        }
      } catch (_) {}
    }

    // Handle Location (Booking -> Ground Name fallback)
    String location = json['location'] ?? 'Venue TBD';
    if (json['booking'] != null && json['booking']['ground'] != null) {
      location = json['booking']['ground']['name'] ?? location;
    }

    // Handle Image
    String imageUrl = json['image'] ?? 'https://via.placeholder.com/400x200';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List)[0];
    } else if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      // Fallback for relative paths or empty
      imageUrl =
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&q=80';
    }

    // Number Parsing
    double price = 0.0;
    if (json['registration_fee'] != null) {
      price = double.tryParse(json['registration_fee'].toString()) ?? 0.0;
    }

    int currentParticipants = 0;
    if (json['participants_count'] != null) {
      currentParticipants =
          int.tryParse(json['participants_count'].toString()) ?? 0;
    }

    int maxParticipants = 0;
    if (json['max_participants'] != null) {
      maxParticipants = int.tryParse(json['max_participants'].toString()) ?? 0;
    }

    return Event(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      date: date,
      time: time,
      location: location,
      imageUrl: imageUrl,
      price: price,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
    );
  }
}
