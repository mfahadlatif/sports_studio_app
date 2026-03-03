class Complex {
  final int id;
  final String name;
  final String address;
  final String description;
  final List<String>? images;
  final double? latitude;
  final double? longitude;
  final List<String>? amenities;
  final String status;
  final int? ownerId;
  final List<Ground>? grounds;

  Complex({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    this.images,
    this.latitude,
    this.longitude,
    this.amenities,
    this.status = 'active',
    this.ownerId,
    this.grounds,
  });

  factory Complex.fromJson(Map<String, dynamic> json) {
    return Complex(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      status: json['status'] ?? 'active',
      ownerId: json['owner_id'],
      grounds: json['grounds'] != null
          ? (json['grounds'] as List).map((g) => Ground.fromJson(g)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'amenities': amenities,
      'status': status,
      'owner_id': ownerId,
      'grounds': grounds?.map((g) => g.toJson()).toList(),
    };
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
  final String? dimensions;
  final List<String>? amenities;
  final bool? lighting;
  final int? bookingsCount;
  final Complex? complex;

  Ground({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.description,
    required this.location,
    required this.complexId,
    this.status = 'active',
    this.type = 'cricket',
    this.images,
    this.dimensions,
    this.amenities,
    this.lighting,
    this.bookingsCount,
    this.complex,
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
      dimensions: json['dimensions'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      lighting: json['lighting'] ?? false,
      bookingsCount: json['bookings_count'],
      complex: json['complex'] != null
          ? Complex.fromJson(json['complex'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_per_hour': pricePerHour,
      'description': description,
      'location': location,
      'complex_id': complexId,
      'status': status,
      'type': type,
      'images': images,
      'dimensions': dimensions,
      'amenities': amenities,
      'lighting': lighting,
      'bookings_count': bookingsCount,
      'complex': complex?.toJson(),
    };
  }
}

class Booking {
  final int id;
  final int groundId;
  final int? userId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final int? players;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final DateTime? paymentExpiresAt;
  final DateTime createdAt;
  final Ground? ground;
  final User? user;
  final Event? event;

  Booking({
    required this.id,
    required this.groundId,
    this.userId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.players,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.paymentExpiresAt,
    required this.createdAt,
    this.ground,
    this.user,
    this.event,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      groundId: json['ground_id'],
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      players: json['players'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentMethod: json['payment_method'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      paymentExpiresAt: json['payment_expires_at'] != null
          ? DateTime.parse(json['payment_expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      ground: json['ground'] != null ? Ground.fromJson(json['ground']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ground_id': groundId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_price': totalPrice,
      'players': players,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'payment_expires_at': paymentExpiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'ground': ground?.toJson(),
      'user': user?.toJson(),
      'event': event?.toJson(),
    };
  }
}

class Event {
  final int id;
  final String name;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final double registrationFee;
  final int maxParticipants;
  final int groundId;
  final int organizerId;
  final double? latitude;
  final double? longitude;
  final String? rules;
  final String? safetyPolicy;
  final List<String>? images;
  final Map<String, dynamic>? schedule;
  final String? location;
  final String eventType;
  final String status;
  final int? participantsCount;
  final bool? userJoined;
  final User? organizer;
  final Booking? booking;

  Event({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.registrationFee,
    required this.maxParticipants,
    required this.groundId,
    required this.organizerId,
    this.latitude,
    this.longitude,
    this.rules,
    this.safetyPolicy,
    this.images,
    this.schedule,
    this.location,
    this.eventType = 'public',
    this.status = 'upcoming',
    this.participantsCount,
    this.userJoined,
    this.organizer,
    this.booking,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      registrationFee:
          double.tryParse(json['registration_fee'].toString()) ?? 0.0,
      maxParticipants: json['maxParticipants'] ?? json['max_participants'] ?? 0,
      groundId: json['ground_id'],
      organizerId: json['organizer_id'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      rules: json['rules'],
      safetyPolicy: json['safety_policy'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      schedule: json['schedule'],
      location: json['location'],
      eventType: json['event_type'] ?? 'public',
      status: json['status'] ?? 'upcoming',
      participantsCount:
          json['participants_count'] ?? json['participants_count'],
      userJoined: json['user_joined'],
      organizer: json['organizer'] != null
          ? User.fromJson(json['organizer'])
          : null,
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'registration_fee': registrationFee,
      'max_participants': maxParticipants,
      'ground_id': groundId,
      'organizer_id': organizerId,
      'latitude': latitude,
      'longitude': longitude,
      'rules': rules,
      'safety_policy': safetyPolicy,
      'images': images,
      'schedule': schedule,
      'location': location,
      'event_type': eventType,
      'status': status,
      'participants_count': participantsCount,
      'user_joined': userJoined,
      'organizer': organizer?.toJson(),
      'booking': booking?.toJson(),
    };
  }
}

class Team {
  final int id;
  final String name;
  final String? sport;
  final String? description;
  final String? logo;
  final int ownerId;
  final DateTime createdAt;
  final User? owner;
  final List<TeamMember>? members;

  Team({
    required this.id,
    required this.name,
    this.sport,
    this.description,
    this.logo,
    required this.ownerId,
    required this.createdAt,
    this.owner,
    this.members,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'] ?? '',
      sport: json['sport'],
      description: json['description'],
      logo: json['logo'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      members: json['members'] != null
          ? (json['members'] as List)
                .map((m) => TeamMember.fromJson(m))
                .toList()
          : null,
    );
  }
}

class TeamMember {
  final int id;
  final int teamId;
  final int userId;
  final String role;
  final String status;
  final User? user;

  TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    this.role = 'player',
    this.status = 'active',
    this.user,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      teamId: json['team_id'],
      userId: json['user_id'],
      role: json['role'] ?? 'player',
      status: json['status'] ?? 'active',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool? phoneVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    this.phoneVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      phoneVerified: json['phone_verified'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'phone_verified': phoneVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Favorite {
  final int id;
  final int groundId;
  final int userId;
  final DateTime createdAt;
  final Ground? ground;

  Favorite({
    required this.id,
    required this.groundId,
    required this.userId,
    required this.createdAt,
    this.ground,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      groundId: json['ground_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      ground: json['ground'] != null ? Ground.fromJson(json['ground']) : null,
    );
  }
}

class Notification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final DateTime? readAt;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.readAt,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Deal {
  final int id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? complexId;
  final int? groundId;
  final String status;
  final Complex? complex;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    this.complexId,
    this.groundId,
    this.status = 'active',
    this.complex,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage:
          double.tryParse(json['discount_percentage'].toString()) ?? 0.0,
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      complexId: json['complex_id'],
      groundId: json['ground_id'],
      status: json['status'] ?? 'active',
      complex: json['complex'] != null
          ? Complex.fromJson(json['complex'])
          : null,
    );
  }
}

class Review {
  final int id;
  final int groundId;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final double rating;
  final String comment;
  final String status;
  final DateTime createdAt;
  final User? user;

  Review({
    required this.id,
    required this.groundId,
    this.userId,
    this.userName,
    this.userEmail,
    required this.rating,
    required this.comment,
    this.status = 'pending',
    required this.createdAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      groundId: json['ground_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      comment: json['comment'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Transaction {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    this.status = 'pending',
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
