import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/data/services/api_service.dart';
// import 'package:sports_studio/data/models/booking_model.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await _apiService.get('/bookings');
      final data = response.data['data'] as List;

      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBookingStatus(int id, String status) async {
    try {
      await _apiService.put('/bookings/$id', data: {'status': status});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking updated to $status')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final b = _bookings[index];
                return Card(
                  color: AppColors.surface,
                  child: ListTile(
                    title: Text(
                      'Ground #${b['ground_id']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${b['booking_date']} at ${b['start_time']} - ${b['status']}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: AppColors.textMuted),
                      onSelected: (status) =>
                          _updateBookingStatus(b['id'], status),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'confirmed',
                          child: Text('Confirm'),
                        ),
                        const PopupMenuItem(
                          value: 'rejected',
                          child: Text('Reject'),
                        ),
                        const PopupMenuItem(
                          value: 'cancelled',
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
