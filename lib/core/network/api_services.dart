import 'package:dio/dio.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/models/models.dart';

class GroundApiService {
  final ApiClient _client = ApiClient();

  Future<List<Ground>> getPublicGrounds({
    int? complexId,
    String? type,
    int? ownerId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _client.dio.get(
        '/public/grounds',
        queryParameters: {
          if (complexId != null) 'complex_id': complexId,
          if (type != null) 'type': type,
          if (ownerId != null) 'owner_id': ownerId,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Ground.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch grounds: $e');
    }
  }

  Future<Ground> getGroundBySlug(String slug) async {
    try {
      final response = await _client.dio.get('/public/grounds/$slug');
      if (response.statusCode == 200) {
        return Ground.fromJson(response.data);
      }
      throw Exception('Ground not found');
    } catch (e) {
      throw Exception('Failed to fetch ground: $e');
    }
  }

  Future<List<dynamic>> getGroundBookings(int groundId, {String? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;

      final response = await _client.dio.get(
        '/public/grounds/$groundId/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch ground bookings: $e');
    }
  }

  Future<List<Ground>> getUserGrounds({int page = 1, int perPage = 15}) async {
    try {
      final response = await _client.dio.get(
        '/grounds',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Ground.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user grounds: $e');
    }
  }

  Future<Ground> createGround(Map<String, dynamic> groundData) async {
    try {
      final response = await _client.dio.post('/grounds', data: groundData);
      if (response.statusCode == 201) {
        return Ground.fromJson(response.data);
      }
      throw Exception('Failed to create ground');
    } catch (e) {
      throw Exception('Failed to create ground: $e');
    }
  }

  Future<Ground> updateGround(int id, Map<String, dynamic> groundData) async {
    try {
      final response = await _client.dio.put('/grounds/$id', data: groundData);
      if (response.statusCode == 200) {
        return Ground.fromJson(response.data);
      }
      throw Exception('Failed to update ground');
    } catch (e) {
      throw Exception('Failed to update ground: $e');
    }
  }

  Future<void> deleteGround(int id) async {
    try {
      final response = await _client.dio.delete('/grounds/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete ground');
      }
    } catch (e) {
      throw Exception('Failed to delete ground: $e');
    }
  }
}

class ComplexApiService {
  final ApiClient _client = ApiClient();

  Future<List<Complex>> getPublicComplexes({
    int? ownerId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        '/public/complexes',
        queryParameters: {
          if (ownerId != null) 'owner_id': ownerId,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Complex.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch complexes: $e');
    }
  }

  Future<Complex> getComplexBySlug(String slug) async {
    try {
      final response = await _client.dio.get('/public/complexes/$slug');
      if (response.statusCode == 200) {
        return Complex.fromJson(response.data);
      }
      throw Exception('Complex not found');
    } catch (e) {
      throw Exception('Failed to fetch complex: $e');
    }
  }

  Future<List<Complex>> getUserComplexes({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        '/complexes',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Complex.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user complexes: $e');
    }
  }

  Future<Complex> createComplex(Map<String, dynamic> complexData) async {
    try {
      final response = await _client.dio.post('/complexes', data: complexData);
      if (response.statusCode == 201) {
        return Complex.fromJson(response.data);
      }
      throw Exception('Failed to create complex');
    } catch (e) {
      throw Exception('Failed to create complex: $e');
    }
  }

  Future<Complex> updateComplex(
    int id,
    Map<String, dynamic> complexData,
  ) async {
    try {
      final response = await _client.dio.put(
        '/complexes/$id',
        data: complexData,
      );
      if (response.statusCode == 200) {
        return Complex.fromJson(response.data);
      }
      throw Exception('Failed to update complex');
    } catch (e) {
      throw Exception('Failed to update complex: $e');
    }
  }

  Future<void> deleteComplex(int id) async {
    try {
      final response = await _client.dio.delete('/complexes/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete complex');
      }
    } catch (e) {
      throw Exception('Failed to delete complex: $e');
    }
  }
}

class BookingApiService {
  final ApiClient _client = ApiClient();

  Future<List<Booking>> getUserBookings({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _client.dio.get(
        '/bookings',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<Booking> getBooking(int id) async {
    try {
      final response = await _client.dio.get('/bookings/$id');
      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Booking not found');
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _client.dio.post('/bookings', data: bookingData);
      if (response.statusCode == 201) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to create booking');
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<Booking> updateBooking(
    int id,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final response = await _client.dio.put(
        '/bookings/$id',
        data: bookingData,
      );
      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to update booking');
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  Future<void> deleteBooking(int id) async {
    try {
      final response = await _client.dio.delete('/bookings/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete booking');
      }
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  Future<Booking> finalizePayment(int bookingId) async {
    try {
      final response = await _client.dio.post(
        '/bookings/$bookingId/finalize-payment',
      );
      if (response.statusCode == 200) {
        // FIX 2: Backend returns { message: '...', booking: {...} }
        final bookingData = response.data['booking'] ?? response.data;
        return Booking.fromJson(bookingData);
      }
      throw Exception('Failed to finalize payment');
    } catch (e) {
      throw Exception('Failed to finalize payment: $e');
    }
  }
}

class EventApiService {
  final ApiClient _client = ApiClient();

  Future<List<Event>> getPublicEvents({
    int? organizerId,
    String? eventType,
    int page = 1,
    int perPage = 24,
  }) async {
    try {
      final response = await _client.dio.get(
        '/public/events',
        queryParameters: {
          if (organizerId != null) 'organizer_id': organizerId,
          if (eventType != null) 'event_type': eventType,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<Event> getPublicEvent(String idOrSlug) async {
    try {
      final response = await _client.dio.get('/public/events/$idOrSlug');
      if (response.statusCode == 200) {
        // FIX 13: Safely handle both wrapped { data: {...} } and direct responses
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return Event.fromJson(data);
      }
      throw Exception('Event not found');
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<List<Event>> getUserEvents({int page = 1, int perPage = 24}) async {
    try {
      final response = await _client.dio.get(
        '/events',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user events: $e');
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _client.dio.post('/events', data: eventData);
      if (response.statusCode == 201) {
        return Event.fromJson(response.data);
      }
      throw Exception('Failed to create event');
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<Event> getEvent(int id) async {
    try {
      final response = await _client.dio.get('/events/$id');
      if (response.statusCode == 200) {
        return Event.fromJson(response.data);
      }
      throw Exception('Event not found');
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<Event> updateEvent(int id, Map<String, dynamic> eventData) async {
    try {
      final response = await _client.dio.put('/events/$id', data: eventData);
      if (response.statusCode == 200) {
        return Event.fromJson(response.data);
      }
      throw Exception('Failed to update event');
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      final response = await _client.dio.delete('/events/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete event');
      }
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}

class EventParticipantApiService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getEventParticipants({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _client.dio.get(
        '/event-participants',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch event participants: $e');
    }
  }

  Future<dynamic> joinEvent(Map<String, dynamic> participantData) async {
    try {
      final response = await _client.dio.post(
        '/event-participants',
        data: participantData,
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to join event');
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }

  Future<dynamic> getParticipant(int id) async {
    try {
      final response = await _client.dio.get('/event-participants/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Participant not found');
    } catch (e) {
      throw Exception('Failed to fetch participant: $e');
    }
  }

  Future<dynamic> updateParticipant(
    int id,
    Map<String, dynamic> participantData,
  ) async {
    try {
      final response = await _client.dio.put(
        '/event-participants/$id',
        data: participantData,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update participant');
    } catch (e) {
      throw Exception('Failed to update participant: $e');
    }
  }

  Future<void> leaveEvent(int id) async {
    try {
      final response = await _client.dio.delete('/event-participants/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to leave event');
      }
    } catch (e) {
      throw Exception('Failed to leave event: $e');
    }
  }
}

class TeamApiService {
  final ApiClient _client = ApiClient();

  Future<List<Team>> getUserTeams() async {
    try {
      final response = await _client.dio.get('/teams');
      if (response.statusCode == 200) {
        // FIX 3: API returns paginated { data: [...] }, not raw list
        final raw = response.data;
        final list = raw is Map ? (raw['data'] ?? raw) : raw;
        return (list as List).map((json) => Team.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch teams: $e');
    }
  }

  Future<Team> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await _client.dio.post('/teams', data: teamData);
      if (response.statusCode == 201) {
        return Team.fromJson(response.data);
      }
      throw Exception('Failed to create team');
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  Future<Team> getTeam(int id) async {
    try {
      final response = await _client.dio.get('/teams/$id');
      if (response.statusCode == 200) {
        return Team.fromJson(response.data);
      }
      throw Exception('Team not found');
    } catch (e) {
      throw Exception('Failed to fetch team: $e');
    }
  }

  Future<Team> updateTeam(int id, Map<String, dynamic> teamData) async {
    try {
      final response = await _client.dio.put('/teams/$id', data: teamData);
      if (response.statusCode == 200) {
        return Team.fromJson(response.data);
      }
      throw Exception('Failed to update team');
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  Future<void> deleteTeam(int id) async {
    try {
      final response = await _client.dio.delete('/teams/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete team');
      }
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  Future<dynamic> addTeamMember(
    int teamId,
    Map<String, dynamic> memberData,
  ) async {
    try {
      final response = await _client.dio.post(
        '/teams/$teamId/members',
        data: memberData,
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to add team member');
    } catch (e) {
      throw Exception('Failed to add team member: $e');
    }
  }

  Future<void> removeTeamMember(int teamId, int userId) async {
    try {
      final response = await _client.dio.delete(
        '/teams/$teamId/members/$userId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to remove team member');
      }
    } catch (e) {
      throw Exception('Failed to remove team member: $e');
    }
  }
}

class FavoriteApiService {
  final ApiClient _client = ApiClient();

  Future<List<Favorite>> getUserFavorites() async {
    try {
      final response = await _client.dio.get('/favorites');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Favorite.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  Future<Favorite> addFavorite(int groundId) async {
    try {
      final response = await _client.dio.post(
        '/favorites',
        data: {'ground_id': groundId},
      );
      if (response.statusCode == 201) {
        return Favorite.fromJson(response.data);
      }
      throw Exception('Failed to add favorite');
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(int groundId) async {
    try {
      final response = await _client.dio.delete('/favorites/$groundId');
      if (response.statusCode != 204) {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}

class NotificationApiService {
  final ApiClient _client = ApiClient();

  Future<List<Notification>> getUserNotifications() async {
    try {
      final response = await _client.dio.get('/notifications');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Notification.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // FIX: Laravel notification IDs are UUIDs (Strings), not integers
  Future<void> markAsRead(String id) async {
    try {
      final response = await _client.dio.post('/notifications/$id/read');
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _client.dio.post('/notifications/read-all');
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // FIX: Laravel notification IDs are UUIDs (Strings), not integers
  Future<void> deleteNotification(String id) async {
    try {
      final response = await _client.dio.delete('/notifications/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}

class DealApiService {
  final ApiClient _client = ApiClient();

  Future<List<Deal>> getPublicDeals() async {
    try {
      final response = await _client.dio.get('/public/deals');
      if (response.statusCode == 200) {
        // FIX: Backend uses ->get() returning a flat array, NOT a paginated {data:[...]}
        final raw = response.data;
        final list = raw is List
            ? raw
            : (raw is Map ? (raw['data'] ?? []) : []);
        return (list as List).map((json) => Deal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch deals: $e');
    }
  }

  Future<List<Deal>> getUserDeals() async {
    try {
      final response = await _client.dio.get('/deals');
      if (response.statusCode == 200) {
        // FIX: Backend uses ->get() returning a flat array, NOT a paginated {data:[...]}
        final raw = response.data;
        final list = raw is List
            ? raw
            : (raw is Map ? (raw['data'] ?? []) : []);
        return (list as List).map((json) => Deal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user deals: $e');
    }
  }

  Future<Deal> createDeal(Map<String, dynamic> dealData) async {
    try {
      final response = await _client.dio.post('/deals', data: dealData);
      if (response.statusCode == 201) {
        return Deal.fromJson(response.data);
      }
      throw Exception('Failed to create deal');
    } catch (e) {
      throw Exception('Failed to create deal: $e');
    }
  }

  Future<Deal> updateDeal(int id, Map<String, dynamic> dealData) async {
    try {
      final response = await _client.dio.put('/deals/$id', data: dealData);
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      }
      throw Exception('Failed to update deal');
    } catch (e) {
      throw Exception('Failed to update deal: $e');
    }
  }

  Future<void> deleteDeal(int id) async {
    try {
      final response = await _client.dio.delete('/deals/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete deal');
      }
    } catch (e) {
      throw Exception('Failed to delete deal: $e');
    }
  }
}

class ReviewApiService {
  final ApiClient _client = ApiClient();

  Future<List<Review>> getPublicReviews({int? groundId}) async {
    try {
      final response = await _client.dio.get(
        '/public/reviews',
        queryParameters: {if (groundId != null) 'ground_id': groundId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<Review> createPublicReview(Map<String, dynamic> reviewData) async {
    try {
      final response = await _client.dio.post(
        '/public/reviews',
        data: reviewData,
      );
      if (response.statusCode == 201) {
        return Review.fromJson(response.data);
      }
      throw Exception('Failed to create review');
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  Future<List<Review>> getUserReviews() async {
    try {
      final response = await _client.dio.get('/reviews');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  Future<Review> updateReviewStatus(int id, String status) async {
    try {
      final response = await _client.dio.put(
        '/reviews/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return Review.fromJson(response.data);
      }
      throw Exception('Failed to update review status');
    } catch (e) {
      throw Exception('Failed to update review status: $e');
    }
  }

  Future<void> deleteReview(int id) async {
    try {
      final response = await _client.dio.delete('/reviews/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}

class TransactionApiService {
  final ApiClient _client = ApiClient();

  Future<List<Transaction>> getUserTransactions() async {
    try {
      final response = await _client.dio.get('/transactions');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<Transaction> getTransaction(int id) async {
    try {
      final response = await _client.dio.get('/transactions/$id');
      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      }
      throw Exception('Transaction not found');
    } catch (e) {
      throw Exception('Failed to fetch transaction: $e');
    }
  }
}

class PaymentApiService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> initiateSafepayPayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final response = await _client.dio.post(
        '/safepay/init',
        data: paymentData,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to initiate payment');
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  Future<Map<String, dynamic>> verifySafepayPayment(String token) async {
    try {
      final response = await _client.dio.post(
        '/safepay/verify',
        data: {'token': token},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to verify payment');
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}

class MediaApiService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _client.dio.post('/upload', data: formData);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to upload file');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteMedia(int id) async {
    try {
      final response = await _client.dio.delete('/media/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete media');
      }
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }

  Future<void> deleteMediaByPath(String path) async {
    try {
      final response = await _client.dio.post(
        '/media/delete-by-path',
        data: {'path': path},
      );
      // FIX 6: Backend returns 200, not 204, for this POST endpoint
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete media by path');
      }
    } catch (e) {
      throw Exception('Failed to delete media by path: $e');
    }
  }
}

class UserApiService {
  final ApiClient _client = ApiClient();

  Future<User> getCurrentUser() async {
    try {
      final response = await _client.dio.get('/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to fetch user profile');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // FIX: Backend returns {message: '...', user: {...}} — must unwrap 'user'
      // Route accepts both POST and PUT via Route::match(['put','post'])
      final response = await _client.dio.post(
        '/profile',
        data: {...profileData, '_method': 'PUT'},
      );
      if (response.statusCode == 200) {
        // Handle both wrapped {user: {...}} and direct user object responses
        final raw = response.data;
        final userData = raw is Map && raw.containsKey('user')
            ? raw['user'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _client.dio.post(
        '/profile/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> requestPhoneVerification(String phone) async {
    try {
      final response = await _client.dio.post(
        '/request-phone-verification',
        data: {'phone': phone},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to request phone verification');
      }
    } catch (e) {
      throw Exception('Failed to request phone verification: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPhone(String phone, String code) async {
    try {
      final response = await _client.dio.post(
        '/verify-phone',
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to verify phone');
    } catch (e) {
      throw Exception('Failed to verify phone: $e');
    }
  }

  Future<Map<String, dynamic>> checkPhoneVerificationStatus() async {
    try {
      final response = await _client.dio.get('/phone-verification-status');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to check verification status');
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }
}

class ContactApiService {
  final ApiClient _client = ApiClient();

  Future<void> submitContactForm(Map<String, dynamic> contactData) async {
    try {
      final response = await _client.dio.post('/contact', data: contactData);
      // FIX 7: Backend returns 201 Created, accept any 2xx success response
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw Exception('Failed to submit contact form');
      }
    } catch (e) {
      throw Exception('Failed to submit contact form: $e');
    }
  }
}
