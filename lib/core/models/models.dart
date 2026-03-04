class Complex {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String? description;
  final double rating;
  final List<String>? images;
  final String status;
  final List<Ground>? grounds;
  final User? owner;

  Complex({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.description,
    this.rating = 0.0,
    this.images,
    this.status = 'active',
    this.grounds,
    this.owner,
  });

  factory Complex.fromJson(Map<String, dynamic> json) {
    return Complex(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: json['status'] ?? 'active',
      grounds: json['grounds'] != null
          ? (json['grounds'] as List).map((g) => Ground.fromJson(g)).toList()
          : null,
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'rating': rating,
      'images': images,
      'status': status,
      'grounds': grounds?.map((g) => g.toJson()).toList(),
      'owner': owner?.toJson(),
    };
  }
}

class Ground {
  final int id;
  final int complexId;
  final String name;
  final String? slug;
  final String? description;
  final double pricePerHour;
  final String? dimensions;
  final String type;
  final List<String>? images;
  final List<String>? amenities;
  final bool lighting;
  final String status;
  final int? bookingsCount;
  final Complex? complex;
  final String? openingTime;
  final String? closingTime;

  Ground({
    required this.id,
    required this.complexId,
    required this.name,
    this.slug,
    this.description,
    required this.pricePerHour,
    this.dimensions,
    this.type = 'cricket',
    this.images,
    this.amenities,
    this.lighting = true,
    this.status = 'active',
    this.bookingsCount,
    this.complex,
    this.openingTime,
    this.closingTime,
  });

  factory Ground.fromJson(Map<String, dynamic> json) {
    return Ground(
      id: json['id'],
      complexId: json['complex_id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      pricePerHour: double.tryParse(json['price_per_hour'].toString()) ?? 0.0,
      dimensions: json['dimensions'],
      type: json['type'] ?? 'cricket',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      lighting: json['lighting'] ?? true,
      status: json['status'] ?? 'active',
      bookingsCount: json['bookings_count'],
      complex: json['complex'] != null
          ? Complex.fromJson(json['complex'])
          : null,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complex_id': complexId,
      'name': name,
      'slug': slug,
      'description': description,
      'price_per_hour': pricePerHour,
      'dimensions': dimensions,
      'type': type,
      'images': images,
      'amenities': amenities,
      'lighting': lighting,
      'status': status,
      'bookings_count': bookingsCount,
      'complex': complex?.toJson(),
      'opening_time': openingTime,
      'closing_time': closingTime,
    };
  }
}

class Booking {
  final int id;
  final int userId;
  final int groundId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final int players;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Ground? ground;
  final User? user;
  final Event? event;

  Booking({
    required this.id,
    required this.userId,
    required this.groundId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.players = 1,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.createdAt,
    this.updatedAt,
    this.ground,
    this.user,
    this.event,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      groundId: json['ground_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      players: json['players'] ?? 1,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      ground: json['ground'] != null ? Ground.fromJson(json['ground']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ground_id': groundId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_price': totalPrice,
      'players': players,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'ground': ground?.toJson(),
      'user': user?.toJson(),
      'event': event?.toJson(),
    };
  }
}

class Event {
  final int id;
  final int organizerId;
  final int? bookingId;
  final String name;
  final String? slug;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final double registrationFee;
  final int? maxParticipants;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? image;
  final String? location;
  final String? rules;
  final String? safetyPolicy;
  final Map<String, dynamic>? schedule;
  final User? organizer;
  final Booking? booking;
  final int? participantsCount;
  final bool? userJoined;

  Event({
    required this.id,
    required this.organizerId,
    this.bookingId,
    required this.name,
    this.slug,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.registrationFee,
    this.maxParticipants,
    this.status = 'upcoming',
    this.createdAt,
    this.updatedAt,
    this.image,
    this.location,
    this.rules,
    this.safetyPolicy,
    this.schedule,
    this.organizer,
    this.booking,
    this.participantsCount,
    this.userJoined,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      organizerId: json['organizer_id'],
      bookingId: json['booking_id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      registrationFee:
          double.tryParse(json['registration_fee'].toString()) ?? 0.0,
      maxParticipants: json['max_participants'],
      status: json['status'] ?? 'upcoming',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      image: json['image'],
      location: json['location'],
      rules: json['rules'],
      safetyPolicy: json['safety_policy'],
      schedule: json['schedule'],
      organizer: json['organizer'] != null
          ? User.fromJson(json['organizer'])
          : null,
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
      participantsCount: json['participants_count'],
      userJoined: json['user_joined'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'booking_id': bookingId,
      'name': name,
      'slug': slug,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'registration_fee': registrationFee,
      'max_participants': maxParticipants,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': image,
      'location': location,
      'rules': rules,
      'safety_policy': safetyPolicy,
      'schedule': schedule,
      'organizer': organizer?.toJson(),
      'booking': booking?.toJson(),
      'participants_count': participantsCount,
      'user_joined': userJoined,
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
  final String? emailVerifiedAt;
  final String? password;
  final String? rememberToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phone;
  final String? businessName;
  final Map<String, dynamic>? notificationPreferences;
  final String role;
  final bool isActive;
  final String? avatar;
  final String? googleId;
  final String? appleId;
  final String? fcmToken;
  final DateTime? phoneVerifiedAt;
  final bool? isPhoneVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.password,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.businessName,
    this.notificationPreferences,
    this.role = 'user',
    this.isActive = true,
    this.avatar,
    this.googleId,
    this.appleId,
    this.fcmToken,
    this.phoneVerifiedAt,
    this.isPhoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      password: json['password'],
      rememberToken: json['remember_token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      phone: json['phone'],
      businessName: json['business_name'],
      notificationPreferences: json['notification_preferences'],
      role: json['role'] ?? 'user',
      isActive: json['is_active'] ?? true,
      avatar: json['avatar'],
      googleId: json['google_id'],
      appleId: json['apple_id'],
      fcmToken: json['fcm_token'],
      phoneVerifiedAt: json['phone_verified_at'],
      isPhoneVerified: json['is_phone_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'password': password,
      'remember_token': rememberToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone': phone,
      'business_name': businessName,
      'notification_preferences': notificationPreferences,
      'role': role,
      'is_active': isActive,
      'avatar': avatar,
      'google_id': googleId,
      'apple_id': appleId,
      'fcm_token': fcmToken,
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'is_phone_verified': isPhoneVerified,
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
  final String id; // Laravel notifications use UUID strings as IDs
  final int userId;
  final String title;
  final String message;
  final String type;
  final String? link;
  final DateTime? readAt;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.link,
    this.readAt,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    // FIX: Laravel DB notifications store payload in nested 'data' object
    // Structure: { id, notifiable_id, data: { title, message, type, link }, read_at, created_at }
    final data = json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return Notification(
      // FIX: Laravel notification IDs are UUIDs (strings), not integers
      id: json['id']?.toString() ?? '',
      userId: json['notifiable_id'] ?? json['user_id'] ?? 0,
      title: data['title'] ?? json['title'] ?? 'Notification',
      message: data['message'] ?? json['message'] ?? '',
      type: data['type'] ?? json['type'] ?? 'general',
      link: data['link'] ?? json['link'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Deal {
  final int id;
  final String title;
  final String? description;
  final String? code;
  final double discountPercentage;
  final DateTime validUntil;
  final String? applicableSports;
  final bool isActive;
  final String colorTheme;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Complex? complex;

  Deal({
    required this.id,
    required this.title,
    this.description,
    this.code,
    required this.discountPercentage,
    required this.validUntil,
    this.applicableSports,
    this.isActive = true,
    this.colorTheme = 'from-primary to-primary/80',
    this.createdAt,
    this.updatedAt,
    this.complex,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      code: json['code'],
      discountPercentage:
          double.tryParse(json['discount_percentage'].toString()) ?? 0.0,
      validUntil: DateTime.parse(json['valid_until']),
      applicableSports: json['applicable_sports'],
      isActive: json['is_active'] ?? true,
      colorTheme: json['color_theme'] ?? 'from-primary to-primary/80',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
