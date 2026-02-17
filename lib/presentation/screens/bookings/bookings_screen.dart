import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/booking_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/booking_card.dart';

import 'package:sports_studio/presentation/widgets/app_drawer.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchUserBookings();
    });
  }

  void _handleCancel(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<BookingProvider>()
                  .cancelBooking(bookingId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                  ),
                );
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (provider.bookings.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchUserBookings(),
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                final booking = provider.bookings[index];
                return BookingCard(
                  booking: booking,
                  onCancel: () => _handleCancel(booking.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
