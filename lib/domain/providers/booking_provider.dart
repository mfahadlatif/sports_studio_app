import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/booking_service.dart';

enum BookingStatus { initial, loading, success, error }

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  BookingProvider({required BookingService bookingService})
    : _bookingService = bookingService;

  List<Booking> _bookings = [];
  BookingStatus _status = BookingStatus.initial;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  BookingStatus get status => _status;
  bool get isLoading => _status == BookingStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserBookings() async {
    _status = BookingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getUserBookings();
      _status = BookingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = BookingStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createBooking({
    required int groundId,
    required String date,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    try {
      _status = BookingStatus.loading;
      notifyListeners();

      final booking = await _bookingService.createBooking(
        groundId: groundId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
      );

      if (booking != null) {
        _bookings.insert(0, booking); // Add to top
        _status = BookingStatus.success;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = BookingStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final success = await _bookingService.cancelBooking(bookingId);
      if (success) {
        _bookings.removeWhere((b) => b.id == bookingId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Booking>> getBookingsForGround(int groundId, String date) async {
    return _bookingService.getGroundBookings(groundId, date);
  }
}
