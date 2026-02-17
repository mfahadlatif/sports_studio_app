import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';
import '../../core/constants/api_constants.dart';
import '../../data/services/api_service.dart';

class EventProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mocking API call for now. In real app use:
      // final response = await _apiService.get('/events');
      // _events = (response.data as List).map((e) => Event.fromJson(e)).toList();

      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      _events = List.generate(
        5,
        (index) => Event(
          id: index,
          title: 'Sports Festival Cup ${2026 + index}',
          description:
              'Join us for the biggest multi-sport community festival of the year! Fun and competition for all age groups.',
          date: '2026-03-${10 + index}',
          time: '09:00 AM',
          location: 'Main Ground, Sports Studio',
          imageUrl:
              'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&q=80',
          price: 500.0,
          maxParticipants: 100,
          currentParticipants: 45 + (index * 10),
        ),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
