import 'dart:convert';

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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ownerId: int.tryParse(json['owner_id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      images: _parseJsonList<String>(json['images']),
      status: json['status'] ?? 'active',
      grounds: json['grounds'] != null && json['grounds'] is List
          ? (json['grounds'] as List).map((g) => Ground.fromJson(g)).toList()
          : null,
      owner: json['owner'] != null && json['owner'] is Map<String, dynamic>
          ? User.fromJson(json['owner'])
          : null,
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      complexId: int.tryParse(json['complex_id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      pricePerHour:
          double.tryParse(json['price_per_hour']?.toString() ?? '0') ?? 0.0,
      dimensions: json['dimensions'],
      type: json['type'] ?? 'cricket',
      images: _parseJsonList<String>(json['images']),
      amenities: _parseJsonList<String>(json['amenities']),
      lighting: json['lighting'] == 1 || json['lighting'] == true,
      status: json['status'] ?? 'active',
      bookingsCount: json['bookings_count'] != null
          ? int.tryParse(json['bookings_count'].toString())
          : null,
      complex:
          json['complex'] != null && json['complex'] is Map<String, dynamic>
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
  final String? paymentMethod;
  final DateTime? paymentExpiresAt;
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
    required this.players,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.paymentExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.ground,
    this.user,
    this.event,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      groundId: int.tryParse(json['ground_id']?.toString() ?? '') ?? 0,
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      players: int.tryParse(json['players']?.toString() ?? '') ?? 1,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method']?.toString(),
      paymentExpiresAt: json['payment_expires_at'] != null
          ? DateTime.tryParse(json['payment_expires_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      ground: json['ground'] != null && json['ground'] is Map<String, dynamic>
          ? Ground.fromJson(json['ground'])
          : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      event: json['event'] != null && json['event'] is Map<String, dynamic>
          ? Event.fromJson(json['event'])
          : null,
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
      'payment_method': paymentMethod,
      'payment_expires_at': paymentExpiresAt?.toIso8601String(),
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
  final String eventType; // public / private
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? image;
  final String? location;
  final String? rules;
  final String? safetyPolicy;
  final String? schedule;
  final List<String> images;
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
    this.eventType = 'public',
    this.status = 'upcoming',
    this.createdAt,
    this.updatedAt,
    this.image,
    this.location,
    this.rules,
    this.safetyPolicy,
    this.schedule,
    this.images = const [],
    this.organizer,
    this.booking,
    this.participantsCount,
    this.userJoined,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      organizerId: int.tryParse(json['organizer_id']?.toString() ?? '') ?? 0,
      bookingId: json['booking_id'] != null
          ? int.tryParse(json['booking_id'].toString())
          : null,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      registrationFee:
          double.tryParse(json['registration_fee']?.toString() ?? '0') ?? 0.0,
      maxParticipants: json['max_participants'] != null
          ? int.tryParse(json['max_participants'].toString())
          : null,
      eventType: json['event_type']?.toString() ?? 'public',
      status: json['status'] ?? 'upcoming',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      image: json['image'],
      location: json['location'],
      rules: json['rules'],
      safetyPolicy: json['safety_policy'],
      schedule: json['schedule'],
      images: (json['images'] is List)
          ? List<String>.from(
              (json['images'] as List).map((e) => e.toString()),
            )
          : const [],
      organizer:
          json['organizer'] != null && json['organizer'] is Map<String, dynamic>
          ? User.fromJson(json['organizer'])
          : null,
      booking:
          json['booking'] != null && json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'])
          : null,
      participantsCount: json['participants_count'] != null
          ? int.tryParse(json['participants_count'].toString())
          : null,
      userJoined: json['user_joined'] == 1 || json['user_joined'] == true,
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
      'event_type': eventType,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': image,
      'location': location,
      'rules': rules,
      'safety_policy': safetyPolicy,
      'schedule': schedule,
      'images': images,
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
  final String? logo;
  final String? description;
  final int ownerId;
  final List<TeamMember>? members;

  Team({
    required this.id,
    required this.name,
    this.sport,
    this.logo,
    this.description,
    required this.ownerId,
    this.members,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      sport: json['sport'],
      logo: json['logo'],
      description: json['description'],
      ownerId: int.tryParse(json['owner_id']?.toString() ?? '') ?? 0,
      members: json['members'] != null && json['members'] is List
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      teamId: int.tryParse(json['team_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      role: json['role'] ?? 'player',
      status: json['status'] ?? 'active',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      password: json['password'],
      rememberToken: json['remember_token'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      phone: json['phone']?.toString(),
      businessName: json['business_name'],
      notificationPreferences: json['notification_preferences'],
      role: json['role'] ?? 'user',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      avatar: json['avatar'],
      googleId: json['google_id']?.toString(),
      appleId: json['apple_id']?.toString(),
      fcmToken: json['fcm_token'],
      phoneVerifiedAt: json['phone_verified_at'] != null
          ? DateTime.tryParse(json['phone_verified_at'])
          : null,
      isPhoneVerified:
          json['is_phone_verified'] == 1 || json['is_phone_verified'] == true,
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
  final DateTime? createdAt;
  final Ground? ground;

  Favorite({
    required this.id,
    required this.groundId,
    required this.userId,
    this.createdAt,
    this.ground,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      groundId: int.tryParse(json['ground_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      ground: json['ground'] != null && json['ground'] is Map<String, dynamic>
          ? Ground.fromJson(json['ground'])
          : null,
    );
  }
}

class Notification {
  final String id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String? link;
  final DateTime? readAt;
  final DateTime? createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.link,
    this.readAt,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return Notification(
      id: json['id']?.toString() ?? '',
      userId:
          int.tryParse(
            json['notifiable_id']?.toString() ??
                json['user_id']?.toString() ??
                '',
          ) ??
          0,
      title: data['title'] ?? json['title'] ?? 'Notification',
      message: data['message'] ?? json['message'] ?? '',
      type: data['type'] ?? json['type'] ?? 'general',
      link: data['link'] ?? json['link'],
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      code: json['code'],
      discountPercentage:
          double.tryParse(json['discount_percentage']?.toString() ?? '0') ??
          0.0,
      validUntil:
          DateTime.tryParse(json['valid_until'] ?? '') ?? DateTime.now(),
      applicableSports: json['applicable_sports'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      colorTheme: json['color_theme'] ?? 'from-primary to-primary/80',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      complex:
          json['complex'] != null && json['complex'] is Map<String, dynamic>
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      groundId: int.tryParse(json['ground_id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      userName: json['user_name'],
      userEmail: json['user_email'],
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      comment: json['comment'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      bookingId: int.tryParse(json['booking_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

List<T>? _parseJsonList<T>(dynamic data) {
  if (data == null) return null;
  if (data is List) {
    if (T == String && data.isNotEmpty && data.first is Map) {
      return data
              .map(
                (item) =>
                    (item['url'] ??
                            item['image_path'] ??
                            item['path'] ??
                            item['image'] ??
                            '')
                        .toString(),
              )
              .where((s) => s.isNotEmpty)
              .toList()
          as List<T>;
    }
    return data.cast<T>();
  }
  if (data is String && data.isNotEmpty) {
    if (data.trim().startsWith('[') || data.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(data);
        return _parseJsonList<T>(decoded);
      } catch (_) {}
    }
    if (T == String) return [data] as List<T>;
  }
  return null;
}
