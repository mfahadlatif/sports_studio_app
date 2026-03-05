import 'dart:io';
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
      print('🌐 [GroundAPI] Fetching public grounds...');
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
        print('✅ [GroundAPI] Fetched ${data.length} grounds');
        if (data.isNotEmpty) {
          print('   Sample images[0]: ${data[0]['images']}');
        }
        return data.map((json) => Ground.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [GroundAPI] getPublicGrounds error: $e');
      throw Exception('Failed to fetch grounds: $e');
    }
  }

  Future<Ground> getGroundBySlug(String slug) async {
    try {
      print('🌐 [GroundAPI] Fetching ground by slug: $slug');
      final response = await _client.dio.get('/public/grounds/$slug');
      if (response.statusCode == 200) {
        print(
          '✅ [GroundAPI] Ground fetched. images: ${response.data['images']}',
        );
        return Ground.fromJson(response.data);
      }
      throw Exception('Ground not found');
    } catch (e) {
      print('❌ [GroundAPI] getGroundBySlug error: $e');
      throw Exception('Failed to fetch ground: $e');
    }
  }

  Future<List<dynamic>> getGroundBookings(int groundId, {String? date}) async {
    try {
      print('🌐 [GroundAPI] Fetching bookings for ground $groundId...');
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;

      final response = await _client.dio.get(
        '/public/grounds/$groundId/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print(
          '✅ [GroundAPI] Bookings fetched: ${(response.data as List).length}',
        );
        return response.data as List;
      }
      return [];
    } catch (e) {
      print('❌ [GroundAPI] getGroundBookings error: $e');
      throw Exception('Failed to fetch ground bookings: $e');
    }
  }

  Future<List<Ground>> getUserGrounds({int page = 1, int perPage = 15}) async {
    try {
      print('🌐 [GroundAPI] Fetching user grounds...');
      final response = await _client.dio.get(
        '/grounds',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print('✅ [GroundAPI] User grounds: ${data.length}');
        return data.map((json) => Ground.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [GroundAPI] getUserGrounds error: $e');
      throw Exception('Failed to fetch user grounds: $e');
    }
  }

  Future<Ground> createGround(Map<String, dynamic> groundData) async {
    try {
      print('🌐 [GroundAPI] Creating ground: ${groundData['name']}');
      final response = await _client.dio.post('/grounds', data: groundData);
      if (response.statusCode == 201) {
        print('✅ [GroundAPI] Ground created: ${response.data['id']}');
        return Ground.fromJson(response.data);
      }
      throw Exception('Failed to create ground');
    } catch (e) {
      print('❌ [GroundAPI] createGround error: $e');
      throw Exception('Failed to create ground: $e');
    }
  }

  Future<Ground> updateGround(int id, Map<String, dynamic> groundData) async {
    try {
      print('🌐 [GroundAPI] Updating ground $id...');
      final response = await _client.dio.put('/grounds/$id', data: groundData);
      if (response.statusCode == 200) {
        print('✅ [GroundAPI] Ground updated: $id');
        return Ground.fromJson(response.data);
      }
      throw Exception('Failed to update ground');
    } catch (e) {
      print('❌ [GroundAPI] updateGround error: $e');
      throw Exception('Failed to update ground: $e');
    }
  }

  Future<void> deleteGround(int id) async {
    try {
      print('🌐 [GroundAPI] Deleting ground $id...');
      final response = await _client.dio.delete('/grounds/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete ground');
      }
      print('✅ [GroundAPI] Ground deleted: $id');
    } catch (e) {
      print('❌ [GroundAPI] deleteGround error: $e');
      throw Exception('Failed to delete ground: $e');
    }
  }

  Future<Ground> uploadGroundImages(
    int groundId,
    List<String> imagePaths,
  ) async {
    try {
      print(
        '🌐 [GroundAPI] Uploading ${imagePaths.length} images for ground $groundId...',
      );
      final List<MultipartFile> files = await Future.wait(
        imagePaths.map((p) => MultipartFile.fromFile(p)),
      );
      final formData = FormData.fromMap({'images[]': files, '_method': 'PUT'});
      final response = await _client.dio.post(
        '/grounds/$groundId/images',
        data: formData,
      );
      if (response.statusCode == 200) {
        print('✅ [GroundAPI] Images uploaded for ground $groundId');
        return Ground.fromJson(response.data);
      }
      throw Exception('Failed to upload ground images');
    } catch (e) {
      print('❌ [GroundAPI] uploadGroundImages error: $e');
      throw Exception('Failed to upload ground images: $e');
    }
  }
}

class ComplexApiService {
  final ApiClient _client = ApiClient();

  Future<List<Complex>> getPublicComplexes() async {
    try {
      print('🌐 [ComplexAPI] Fetching public complexes...');
      final response = await _client.dio.get('/public/complexes');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print('✅ [ComplexAPI] Fetched ${data.length} complexes');
        return data.map((json) => Complex.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ComplexAPI] getPublicComplexes error: $e');
      throw Exception('Failed to fetch complexes: $e');
    }
  }

  Future<List<Complex>> getOwnerComplexes() async {
    try {
      print('🌐 [ComplexAPI] Fetching owner complexes...');
      final response = await _client.dio.get('/complexes');
      if (response.statusCode == 200) {
        final raw = response.data;
        List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [ComplexAPI] Owner complexes: ${data.length}');
        return data.map((json) => Complex.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ComplexAPI] getOwnerComplexes error: $e');
      throw Exception('Failed to fetch owner complexes: $e');
    }
  }

  Future<Complex> createComplex(Map<String, dynamic> complexData) async {
    try {
      print('🌐 [ComplexAPI] Creating complex: ${complexData['name']}');
      final response = await _client.dio.post('/complexes', data: complexData);
      if (response.statusCode == 201) {
        print('✅ [ComplexAPI] Complex created');
        return Complex.fromJson(response.data);
      }
      throw Exception('Failed to create complex');
    } catch (e) {
      print('❌ [ComplexAPI] createComplex error: $e');
      throw Exception('Failed to create complex: $e');
    }
  }

  Future<Complex> updateComplex(
    int id,
    Map<String, dynamic> complexData,
  ) async {
    try {
      print('🌐 [ComplexAPI] Updating complex $id...');
      final response = await _client.dio.put(
        '/complexes/$id',
        data: complexData,
      );
      if (response.statusCode == 200) {
        print('✅ [ComplexAPI] Complex updated: $id');
        return Complex.fromJson(response.data);
      }
      throw Exception('Failed to update complex');
    } catch (e) {
      print('❌ [ComplexAPI] updateComplex error: $e');
      throw Exception('Failed to update complex: $e');
    }
  }

  Future<void> deleteComplex(int id) async {
    try {
      print('🌐 [ComplexAPI] Deleting complex $id...');
      final response = await _client.dio.delete('/complexes/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete complex');
      }
      print('✅ [ComplexAPI] Complex deleted: $id');
    } catch (e) {
      print('❌ [ComplexAPI] deleteComplex error: $e');
      throw Exception('Failed to delete complex: $e');
    }
  }
}

class BookingApiService {
  final ApiClient _client = ApiClient();

  Future<List<Booking>> getUserBookings() async {
    try {
      print('🌐 [BookingAPI] Fetching user bookings...');
      final response = await _client.dio.get('/bookings');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [BookingAPI] Bookings: ${data.length}');
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [BookingAPI] getUserBookings error: $e');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      print('🌐 [BookingAPI] Creating booking: $bookingData');
      final response = await _client.dio.post('/bookings', data: bookingData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [BookingAPI] Booking created: ${response.data['id']}');
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to create booking');
    } catch (e) {
      print('❌ [BookingAPI] createBooking error: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<Booking> cancelBooking(int id) async {
    try {
      print('🌐 [BookingAPI] Cancelling booking $id...');
      final response = await _client.dio.post('/bookings/$id/cancel');
      if (response.statusCode == 200) {
        print('✅ [BookingAPI] Booking cancelled: $id');
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to cancel booking');
    } catch (e) {
      print('❌ [BookingAPI] cancelBooking error: $e');
      throw Exception('Failed to cancel booking: $e');
    }
  }

  Future<List<Booking>> getOwnerBookings({String? status}) async {
    try {
      print('🌐 [BookingAPI] Fetching owner bookings...');
      final response = await _client.dio.get(
        '/owner/bookings',
        queryParameters: {if (status != null) 'status': status},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [BookingAPI] Owner bookings: ${data.length}');
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [BookingAPI] getOwnerBookings error: $e');
      throw Exception('Failed to fetch owner bookings: $e');
    }
  }

  Future<Booking> updateBookingStatus(int id, String status) async {
    try {
      print('🌐 [BookingAPI] Updating booking $id status to $status...');
      final response = await _client.dio.put(
        '/bookings/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        print('✅ [BookingAPI] Booking status updated: $id -> $status');
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to update booking status');
    } catch (e) {
      print('❌ [BookingAPI] updateBookingStatus error: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }
}

class EventApiService {
  final ApiClient _client = ApiClient();

  Future<List<Event>> getPublicEvents() async {
    try {
      print('🌐 [EventAPI] Fetching public events...');
      final response = await _client.dio.get('/public/events');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [EventAPI] Events: ${data.length}');
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [EventAPI] getPublicEvents error: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<Event> getEventBySlug(String slug) async {
    try {
      print('🌐 [EventAPI] Fetching event by slug: $slug');
      final response = await _client.dio.get('/public/events/$slug');
      if (response.statusCode == 200) {
        print('✅ [EventAPI] Event fetched: $slug');
        return Event.fromJson(response.data);
      }
      throw Exception('Event not found');
    } catch (e) {
      print('❌ [EventAPI] getEventBySlug error: $e');
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<List<Event>> getUserEvents() async {
    try {
      print('🌐 [EventAPI] Fetching user events...');
      final response = await _client.dio.get('/events');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [EventAPI] User events: ${data.length}');
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [EventAPI] getUserEvents error: $e');
      throw Exception('Failed to fetch user events: $e');
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    try {
      print('🌐 [EventAPI] Creating event: ${eventData['name']}');
      final response = await _client.dio.post('/events', data: eventData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [EventAPI] Event created: ${response.data['id']}');
        return Event.fromJson(response.data);
      }
      throw Exception('Failed to create event');
    } catch (e) {
      print('❌ [EventAPI] createEvent error: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  Future<Event> updateEvent(int id, Map<String, dynamic> eventData) async {
    try {
      print('🌐 [EventAPI] Updating event $id...');
      final response = await _client.dio.put('/events/$id', data: eventData);
      if (response.statusCode == 200) {
        print('✅ [EventAPI] Event updated: $id');
        return Event.fromJson(response.data);
      }
      throw Exception('Failed to update event');
    } catch (e) {
      print('❌ [EventAPI] updateEvent error: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      print('🌐 [EventAPI] Deleting event $id...');
      final response = await _client.dio.delete('/events/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete event');
      }
      print('✅ [EventAPI] Event deleted: $id');
    } catch (e) {
      print('❌ [EventAPI] deleteEvent error: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<dynamic> joinEvent(int eventId) async {
    try {
      print('🌐 [EventAPI] Joining event $eventId...');
      final response = await _client.dio.post('/events/$eventId/join');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [EventAPI] Joined event $eventId');
        return response.data;
      }
      throw Exception('Failed to join event');
    } catch (e) {
      print('❌ [EventAPI] joinEvent error: $e');
      throw Exception('Failed to join event: $e');
    }
  }

  Future<void> leaveEvent(int eventId) async {
    try {
      print('🌐 [EventAPI] Leaving event $eventId...');
      final response = await _client.dio.post('/events/$eventId/leave');
      if (response.statusCode == 200) {
        print('✅ [EventAPI] Left event $eventId');
        return;
      }
      throw Exception('Failed to leave event');
    } catch (e) {
      print('❌ [EventAPI] leaveEvent error: $e');
      throw Exception('Failed to leave event: $e');
    }
  }

  /// Alias used by EventsController.fetchEventDetail
  Future<Event> getPublicEvent(String idOrSlug) => getEventBySlug(idOrSlug);

  Future<List<dynamic>> getEventParticipants(int eventId) async {
    try {
      print('🌐 [EventAPI] Fetching participants for event $eventId...');
      final response = await _client.dio.get('/events/$eventId/participants');
      if (response.statusCode == 200) {
        print('✅ [EventAPI] Participants fetched');
        return response.data as List;
      }
      return [];
    } catch (e) {
      print('❌ [EventAPI] getEventParticipants error: $e');
      throw Exception('Failed to fetch event participants: $e');
    }
  }
}

class FavoriteApiService {
  final ApiClient _client = ApiClient();

  Future<List<Favorite>> getUserFavorites() async {
    try {
      print('🌐 [FavAPI] Fetching favorites...');
      final response = await _client.dio.get('/favorites');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [FavAPI] Favorites: ${data.length}');
        return data.map((json) {
          try {
            return Favorite.fromJson(json);
          } catch (e) {
            print('⚠️ [FavAPI] Error parsing favorite: $e | json: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ [FavAPI] getUserFavorites error: $e');
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  Future<void> addFavorite(int groundId) async {
    try {
      print('🌐 [FavAPI] Adding favorite: ground $groundId...');
      final response = await _client.dio.post(
        '/favorites',
        data: {'ground_id': groundId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [FavAPI] Favorite added');
        return;
      }
      throw Exception('Failed to add favorite');
    } catch (e) {
      print('❌ [FavAPI] addFavorite error: $e');
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(int groundId) async {
    try {
      print('🌐 [FavAPI] Removing favorite: ground $groundId...');
      final response = await _client.dio.delete('/favorites/$groundId');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to remove favorite');
      }
      print('✅ [FavAPI] Favorite removed');
    } catch (e) {
      print('❌ [FavAPI] removeFavorite error: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }
}

class TeamApiService {
  final ApiClient _client = ApiClient();

  Future<List<Team>> getUserTeams() async {
    try {
      print('🌐 [TeamAPI] Fetching user teams...');
      final response = await _client.dio.get('/teams');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [TeamAPI] Teams: ${data.length}');
        return data.map((json) => Team.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [TeamAPI] getUserTeams error: $e');
      throw Exception('Failed to fetch teams: $e');
    }
  }

  Future<Team> createTeam(Map<String, dynamic> teamData) async {
    try {
      print('🌐 [TeamAPI] Creating team: ${teamData['name']}');
      final response = await _client.dio.post('/teams', data: teamData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [TeamAPI] Team created: ${response.data['id']}');
        return Team.fromJson(response.data);
      }
      throw Exception('Failed to create team');
    } catch (e) {
      print('❌ [TeamAPI] createTeam error: $e');
      throw Exception('Failed to create team: $e');
    }
  }

  Future<Team> updateTeam(int id, Map<String, dynamic> teamData) async {
    try {
      print('🌐 [TeamAPI] Updating team $id...');
      final response = await _client.dio.put('/teams/$id', data: teamData);
      if (response.statusCode == 200) {
        print('✅ [TeamAPI] Team updated: $id');
        return Team.fromJson(response.data);
      }
      throw Exception('Failed to update team');
    } catch (e) {
      print('❌ [TeamAPI] updateTeam error: $e');
      throw Exception('Failed to update team: $e');
    }
  }

  Future<void> deleteTeam(int id) async {
    try {
      print('🌐 [TeamAPI] Deleting team $id...');
      final response = await _client.dio.delete('/teams/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete team');
      }
      print('✅ [TeamAPI] Team deleted: $id');
    } catch (e) {
      print('❌ [TeamAPI] deleteTeam error: $e');
      throw Exception('Failed to delete team: $e');
    }
  }

  Future<dynamic> addTeamMember(
    int teamId,
    Map<String, dynamic> memberData,
  ) async {
    try {
      print('🌐 [TeamAPI] Adding member to team $teamId...');
      final response = await _client.dio.post(
        '/teams/$teamId/members',
        data: memberData,
      );
      if (response.statusCode == 201) {
        print('✅ [TeamAPI] Member added to team $teamId');
        return response.data;
      }
      throw Exception('Failed to add team member');
    } catch (e) {
      print('❌ [TeamAPI] addTeamMember error: $e');
      throw Exception('Failed to add team member: $e');
    }
  }

  Future<void> removeTeamMember(int teamId, int userId) async {
    try {
      print('🌐 [TeamAPI] Removing member $userId from team $teamId...');
      final response = await _client.dio.delete(
        '/teams/$teamId/members/$userId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to remove team member');
      }
      print('✅ [TeamAPI] Member removed from team $teamId');
    } catch (e) {
      print('❌ [TeamAPI] removeTeamMember error: $e');
      throw Exception('Failed to remove team member: $e');
    }
  }

  Future<Team> getTeam(int id) async {
    try {
      print('🌐 [TeamAPI] Fetching team $id...');
      final response = await _client.dio.get('/teams/$id');
      if (response.statusCode == 200) {
        print('✅ [TeamAPI] Team fetched: $id');
        return Team.fromJson(response.data);
      }
      throw Exception('Team not found');
    } catch (e) {
      print('❌ [TeamAPI] getTeam error: $e');
      throw Exception('Failed to fetch team: $e');
    }
  }
}

class ReviewApiService {
  final ApiClient _client = ApiClient();

  Future<List<Review>> getPublicReviews({int? groundId}) async {
    try {
      print('🌐 [ReviewAPI] Fetching reviews for ground $groundId...');
      final response = await _client.dio.get(
        '/public/reviews',
        queryParameters: {if (groundId != null) 'ground_id': groundId},
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        // Handle both {data: [...]} and direct list
        List data = rawData is List
            ? rawData
            : (rawData['data'] as List? ?? []);
        print('✅ [ReviewAPI] Reviews: ${data.length}');
        if (data.isNotEmpty) {
          print('   Sample review: ${data[0]}');
        }
        return data.map((json) {
          try {
            return Review.fromJson(json);
          } catch (e) {
            print('⚠️ [ReviewAPI] Parse error for review: $e | data: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ReviewAPI] getPublicReviews error: $e');
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<Review> createPublicReview(Map<String, dynamic> reviewData) async {
    try {
      print('🌐 [ReviewAPI] Creating review: $reviewData');
      final response = await _client.dio.post(
        '/public/reviews',
        data: reviewData,
      );
      if (response.statusCode == 201) {
        print('✅ [ReviewAPI] Review created');
        return Review.fromJson(response.data);
      }
      throw Exception('Failed to create review');
    } catch (e) {
      print('❌ [ReviewAPI] createPublicReview error: $e');
      throw Exception('Failed to create review: $e');
    }
  }

  Future<List<Review>> getUserReviews() async {
    try {
      print('🌐 [ReviewAPI] Fetching user reviews...');
      final response = await _client.dio.get('/reviews');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print('✅ [ReviewAPI] User reviews: ${data.length}');
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ReviewAPI] getUserReviews error: $e');
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  Future<Review> updateReviewStatus(int id, String status) async {
    try {
      print('🌐 [ReviewAPI] Updating review $id status to $status...');
      final response = await _client.dio.put(
        '/reviews/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        print('✅ [ReviewAPI] Review status updated');
        return Review.fromJson(response.data);
      }
      throw Exception('Failed to update review status');
    } catch (e) {
      print('❌ [ReviewAPI] updateReviewStatus error: $e');
      throw Exception('Failed to update review status: $e');
    }
  }

  Future<void> deleteReview(int id) async {
    try {
      print('🌐 [ReviewAPI] Deleting review $id...');
      final response = await _client.dio.delete('/reviews/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete review');
      }
      print('✅ [ReviewAPI] Review deleted');
    } catch (e) {
      print('❌ [ReviewAPI] deleteReview error: $e');
      throw Exception('Failed to delete review: $e');
    }
  }
}

class TransactionApiService {
  final ApiClient _client = ApiClient();

  Future<List<Transaction>> getUserTransactions() async {
    try {
      print('🌐 [TransactionAPI] Fetching user transactions...');
      final response = await _client.dio.get('/transactions');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [TransactionAPI] Transactions: ${data.length}');
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [TransactionAPI] getUserTransactions error: $e');
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<Transaction> getTransaction(int id) async {
    try {
      print('🌐 [TransactionAPI] Fetching transaction $id...');
      final response = await _client.dio.get('/transactions/$id');
      if (response.statusCode == 200) {
        print('✅ [TransactionAPI] Transaction fetched: $id');
        return Transaction.fromJson(response.data);
      }
      throw Exception('Transaction not found');
    } catch (e) {
      print('❌ [TransactionAPI] getTransaction error: $e');
      throw Exception('Failed to fetch transaction: $e');
    }
  }
}

class NotificationApiService {
  final ApiClient _client = ApiClient();

  Future<List<Notification>> getUserNotifications() async {
    try {
      print('🌐 [NotifAPI] Fetching notifications...');
      final response = await _client.dio.get('/notifications');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [NotifAPI] Notifications: ${data.length}');
        return data.map((json) {
          try {
            return Notification.fromJson(json);
          } catch (e) {
            print('⚠️ [NotifAPI] Parse error: $e | data: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ [NotifAPI] getUserNotifications error: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print('🌐 [NotifAPI] Marking notification $notificationId as read...');
      await _client.dio.post('/notifications/$notificationId/read');
      print('✅ [NotifAPI] Notification marked as read');
    } catch (e) {
      print('❌ [NotifAPI] markAsRead error: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      print('🌐 [NotifAPI] Marking all notifications as read...');
      await _client.dio.post('/notifications/read-all');
      print('✅ [NotifAPI] All notifications marked as read');
    } catch (e) {
      print('❌ [NotifAPI] markAllAsRead error: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🌐 [NotifAPI] Deleting notification $notificationId...');
      await _client.dio.delete('/notifications/$notificationId');
      print('✅ [NotifAPI] Notification deleted');
    } catch (e) {
      print('❌ [NotifAPI] deleteNotification error: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }
}

class DealApiService {
  final ApiClient _client = ApiClient();

  Future<List<Deal>> getPublicDeals() async {
    try {
      print('🌐 [DealAPI] Fetching public deals...');
      final response = await _client.dio.get('/public/deals');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [DealAPI] Deals: ${data.length}');
        return data.map((json) => Deal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [DealAPI] getPublicDeals error: $e');
      throw Exception('Failed to fetch deals: $e');
    }
  }

  Future<List<Deal>> getOwnerDeals() async {
    try {
      print('🌐 [DealAPI] Fetching owner deals...');
      final response = await _client.dio.get('/deals');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [DealAPI] Owner deals: ${data.length}');
        return data.map((json) => Deal.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [DealAPI] getOwnerDeals error: $e');
      throw Exception('Failed to fetch owner deals: $e');
    }
  }

  Future<Deal> createDeal(Map<String, dynamic> dealData) async {
    try {
      print('🌐 [DealAPI] Creating deal: ${dealData['title']}');
      final response = await _client.dio.post('/deals', data: dealData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [DealAPI] Deal created');
        return Deal.fromJson(response.data);
      }
      throw Exception('Failed to create deal');
    } catch (e) {
      print('❌ [DealAPI] createDeal error: $e');
      throw Exception('Failed to create deal: $e');
    }
  }

  Future<Deal> updateDeal(int id, Map<String, dynamic> dealData) async {
    try {
      print('🌐 [DealAPI] Updating deal $id...');
      final response = await _client.dio.put('/deals/$id', data: dealData);
      if (response.statusCode == 200) {
        print('✅ [DealAPI] Deal updated: $id');
        return Deal.fromJson(response.data);
      }
      throw Exception('Failed to update deal');
    } catch (e) {
      print('❌ [DealAPI] updateDeal error: $e');
      throw Exception('Failed to update deal: $e');
    }
  }

  Future<void> deleteDeal(int id) async {
    try {
      print('🌐 [DealAPI] Deleting deal $id...');
      final response = await _client.dio.delete('/deals/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete deal');
      }
      print('✅ [DealAPI] Deal deleted: $id');
    } catch (e) {
      print('❌ [DealAPI] deleteDeal error: $e');
      throw Exception('Failed to delete deal: $e');
    }
  }
}

class PaymentApiService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> initiateSafepayPayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      print('🌐 [PaymentAPI] Initiating Safepay payment: $paymentData');
      final response = await _client.dio.post(
        '/safepay/init',
        data: paymentData,
      );
      if (response.statusCode == 200) {
        print('✅ [PaymentAPI] Payment initiated');
        return response.data;
      }
      throw Exception('Failed to initiate payment');
    } catch (e) {
      print('❌ [PaymentAPI] initiateSafepayPayment error: $e');
      throw Exception('Failed to initiate payment: $e');
    }
  }

  Future<Map<String, dynamic>> verifySafepayPayment(String token) async {
    try {
      print('🌐 [PaymentAPI] Verifying Safepay payment token...');
      final response = await _client.dio.post(
        '/safepay/verify',
        data: {'token': token},
      );
      if (response.statusCode == 200) {
        print('✅ [PaymentAPI] Payment verified');
        return response.data;
      }
      throw Exception('Failed to verify payment');
    } catch (e) {
      print('❌ [PaymentAPI] verifySafepayPayment error: $e');
      throw Exception('Failed to verify payment: $e');
    }
  }
}

class MediaApiService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    try {
      print('🌐 [MediaAPI] Uploading file: $filePath');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _client.dio.post('/upload', data: formData);
      if (response.statusCode == 200) {
        print('✅ [MediaAPI] File uploaded. Response: ${response.data}');
        return response.data;
      }
      throw Exception('Failed to upload file');
    } catch (e) {
      print('❌ [MediaAPI] uploadFile error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteMedia(int id) async {
    try {
      print('🌐 [MediaAPI] Deleting media $id...');
      final response = await _client.dio.delete('/media/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete media');
      }
      print('✅ [MediaAPI] Media deleted: $id');
    } catch (e) {
      print('❌ [MediaAPI] deleteMedia error: $e');
      throw Exception('Failed to delete media: $e');
    }
  }

  Future<void> deleteMediaByPath(String path) async {
    try {
      print('🌐 [MediaAPI] Deleting media by path: $path');
      final response = await _client.dio.post(
        '/media/delete-by-path',
        data: {'path': path},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete media by path');
      }
      print('✅ [MediaAPI] Media deleted by path');
    } catch (e) {
      print('❌ [MediaAPI] deleteMediaByPath error: $e');
      throw Exception('Failed to delete media by path: $e');
    }
  }
}

class UserApiService {
  final ApiClient _client = ApiClient();

  Future<User> getCurrentUser() async {
    try {
      print('🌐 [UserAPI] Fetching current user...');
      final response = await _client.dio.get('/me');
      if (response.statusCode == 200) {
        print(
          '✅ [UserAPI] User fetched: ${response.data['name']} | avatar: ${response.data['avatar']}',
        );
        return User.fromJson(response.data);
      }
      throw Exception('Failed to fetch user profile');
    } catch (e) {
      print('❌ [UserAPI] getCurrentUser error: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print(
        '🌐 [UserAPI] Updating profile with keys: ${profileData.keys.toList()}',
      );
      // Check if there's an avatar file path to upload
      final avatarPath = profileData['avatar_file_path'];
      if (avatarPath != null) {
        profileData = Map.of(profileData);
        profileData.remove('avatar_file_path');
      }

      // Build either FormData (if avatar file) or JSON
      dynamic requestData;
      if (avatarPath != null && File(avatarPath).existsSync()) {
        print('   📷 Avatar file detected, sending as multipart...');
        final formMap = <String, dynamic>{
          ...profileData,
          '_method': 'PUT',
          'avatar': await MultipartFile.fromFile(
            avatarPath,
            filename: 'avatar.jpg',
          ),
        };
        requestData = FormData.fromMap(formMap);
      } else {
        requestData = {...profileData, '_method': 'PUT'};
        print('   📝 Sending profile as JSON: $requestData');
      }

      final response = await _client.dio.post('/profile', data: requestData);
      if (response.statusCode == 200) {
        final raw = response.data;
        print('✅ [UserAPI] Profile updated. Response: $raw');
        final userData = raw is Map && raw.containsKey('user')
            ? raw['user'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      print(
        '❌ [UserAPI] updateProfile status: ${response.statusCode} | data: ${response.data}',
      );
      throw Exception('Failed to update profile');
    } catch (e) {
      print('❌ [UserAPI] updateProfile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      print('🌐 [UserAPI] Changing password...');
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
      print('✅ [UserAPI] Password changed');
    } catch (e) {
      print('❌ [UserAPI] changePassword error: $e');
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> requestPhoneVerification(String phone) async {
    try {
      print('🌐 [UserAPI] Requesting phone verification for: $phone');
      final response = await _client.dio.post(
        '/request-phone-verification',
        data: {'phone': phone},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to request phone verification');
      }
      print('✅ [UserAPI] Phone verification requested');
    } catch (e) {
      print('❌ [UserAPI] requestPhoneVerification error: $e');
      throw Exception('Failed to request phone verification: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPhone(String phone, String code) async {
    try {
      print('🌐 [UserAPI] Verifying phone: $phone with code: $code');
      final response = await _client.dio.post(
        '/verify-phone',
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200) {
        print('✅ [UserAPI] Phone verified');
        return response.data;
      }
      throw Exception('Failed to verify phone');
    } catch (e) {
      print('❌ [UserAPI] verifyPhone error: $e');
      throw Exception('Failed to verify phone: $e');
    }
  }

  Future<Map<String, dynamic>> checkPhoneVerificationStatus() async {
    try {
      print('🌐 [UserAPI] Checking phone verification status...');
      final response = await _client.dio.get('/phone-verification-status');
      if (response.statusCode == 200) {
        print('✅ [UserAPI] Status: ${response.data}');
        return response.data;
      }
      throw Exception('Failed to check verification status');
    } catch (e) {
      print('❌ [UserAPI] checkPhoneVerificationStatus error: $e');
      throw Exception('Failed to check verification status: $e');
    }
  }
}

class ContactApiService {
  final ApiClient _client = ApiClient();

  Future<void> submitContactForm(Map<String, dynamic> contactData) async {
    try {
      print('🌐 [ContactAPI] Submitting contact form...');
      final response = await _client.dio.post('/contact', data: contactData);
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw Exception('Failed to submit contact form');
      }
      print('✅ [ContactAPI] Contact form submitted');
    } catch (e) {
      print('❌ [ContactAPI] submitContactForm error: $e');
      throw Exception('Failed to submit contact form: $e');
    }
  }
}

/// Service for event participant operations (used by EventsController)
class EventParticipantApiService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getEventParticipants(int eventId) async {
    try {
      print('🌐 [ParticipantAPI] Fetching participants for event $eventId...');
      final response = await _client.dio.get('/events/$eventId/participants');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        print('✅ [ParticipantAPI] Participants: ${data.length}');
        return data;
      }
      return [];
    } catch (e) {
      print('❌ [ParticipantAPI] getEventParticipants error: $e');
      throw Exception('Failed to fetch event participants: $e');
    }
  }

  Future<dynamic> addParticipant(int eventId, Map<String, dynamic> data) async {
    try {
      print('🌐 [ParticipantAPI] Adding participant to event $eventId...');
      final response = await _client.dio.post(
        '/events/$eventId/participants',
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [ParticipantAPI] Participant added');
        return response.data;
      }
      throw Exception('Failed to add participant');
    } catch (e) {
      print('❌ [ParticipantAPI] addParticipant error: $e');
      throw Exception('Failed to add participant: $e');
    }
  }

  Future<void> removeParticipant(int eventId, int userId) async {
    try {
      print(
        '🌐 [ParticipantAPI] Removing participant $userId from event $eventId...',
      );
      await _client.dio.delete('/events/$eventId/participants/$userId');
      print('✅ [ParticipantAPI] Participant removed');
    } catch (e) {
      print('❌ [ParticipantAPI] removeParticipant error: $e');
      throw Exception('Failed to remove participant: $e');
    }
  }

  /// Join an event (used by events_controller.dart)
  Future<dynamic> joinEvent(Map<String, dynamic> participantData) async {
    try {
      final eventId = participantData['event_id'];
      print('🌐 [ParticipantAPI] Joining event $eventId...');
      final response = await _client.dio.post(
        '/events/$eventId/join',
        data: participantData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [ParticipantAPI] Joined event $eventId');
        return response.data;
      }
      throw Exception('Failed to join event');
    } catch (e) {
      print('❌ [ParticipantAPI] joinEvent error: $e');
      throw Exception('Failed to join event: $e');
    }
  }

  /// Leave an event by participant record ID
  Future<void> leaveEvent(int participantId) async {
    try {
      print(
        '🌐 [ParticipantAPI] Leaving event (participant $participantId)...',
      );
      await _client.dio.delete('/event-participants/$participantId');
      print('✅ [ParticipantAPI] Left event');
    } catch (e) {
      print('❌ [ParticipantAPI] leaveEvent error: $e');
      throw Exception('Failed to leave event: $e');
    }
  }
}

extension BookingApiServicePayment on BookingApiService {
  /// Finalize a booking after successful payment.
  Future<Booking> finalizePayment(int bookingId) async {
    final ApiClient client = ApiClient();
    try {
      print('🌐 [BookingAPI] Finalizing payment for booking $bookingId...');
      // Match website/backend: POST /bookings/:id/finalize-payment
      final response = await client.dio.post(
        '/bookings/$bookingId/finalize-payment',
      );
      if (response.statusCode == 200) {
        print('✅ [BookingAPI] Payment finalized for booking $bookingId');
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to finalize payment');
    } catch (e) {
      print('❌ [BookingAPI] finalizePayment error: $e');
      throw Exception('Failed to finalize payment: $e');
    }
  }
}
