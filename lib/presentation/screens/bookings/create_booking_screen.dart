import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/data/models/ground_model.dart';
import 'package:sports_studio/domain/providers/booking_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';
import 'package:sports_studio/data/services/payment_service.dart';
import 'package:sports_studio/presentation/screens/payments/payment_screen.dart';
import 'package:sports_studio/presentation/widgets/payment_method_selector.dart';

class CreateBookingScreen extends StatefulWidget {
  final Ground ground;

  const CreateBookingScreen({super.key, required this.ground});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.safepay;
  bool _isLoadingSlots = false;
  List<String> _bookedSlots = [];

  // Define available operational hours (e.g., 6 AM to 10 PM)
  final List<String> _allSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _bookedSlots = [];
      _selectedTimeSlot = null; // Reset selection on date change
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final bookings = await context.read<BookingProvider>().getBookingsForGround(
      widget.ground.id,
      dateStr,
    );

    setState(() {
      _bookedSlots = bookings.map((b) => b.startTime.substring(0, 5)).toList();
      _isLoadingSlots = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchBookedSlots();
    }
  }

  Future<void> _initiatePayment() async {
    if (_selectedTimeSlot == null) return;

    // Simulate loading
    // In a real app with local state loading: setState(() => _isLoading = true);
    // But here we rely on BookingProvider loading or local state.
    // I'll add a local loading state for payment init if needed, or just block UI.
    // For simplicity, let's just proceed.

    if (_selectedPaymentMethod == PaymentMethod.cash) {
      // Cash flow: Skip digital payment and go straight to booking
      _processBooking(paymentStatus: 'pending');
      return;
    }

    if (_selectedPaymentMethod == PaymentMethod.card) {
      // Card flow placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card payment integration coming soon!')),
      );
      return;
    }

    try {
      // 1. Get Payment Tracker
      final tracker = await PaymentService().initializePayment(
        amount: widget.ground.price,
        currency: 'PKR',
      );

      if (!mounted) return;

      if (tracker == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize payment')),
        );
        return;
      }

      // 2. Navigate to Payment Screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            tracker: tracker,
            onPaymentComplete: (data) {
              Navigator.pop(context, true); // Return success
            },
            onPaymentCancel: () {
              Navigator.pop(context, false); // Return failure
            },
          ),
        ),
      );

      if (result == true) {
        _processBooking(paymentStatus: 'paid');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment init failed: $e')));
    }
  }

  Future<void> _processBooking({String paymentStatus = 'pending'}) async {
    if (_selectedTimeSlot == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startJson = _selectedTimeSlot!;
    final hour = int.parse(startJson.split(':')[0]);
    final endJson = '${(hour + 1).toString().padLeft(2, '0')}:00';

    final success = await context.read<BookingProvider>().createBooking(
      groundId: widget.ground.id,
      date: dateStr,
      startTime: startJson,
      endTime: endJson,
      totalPrice: widget.ground.price,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentStatus == 'paid'
                ? 'Payment Successful! Booking Confirmed.'
                : 'Booking Confirmed!',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book Ground')),
      body: Column(
        children: [
          // Date Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                  style: AppTextStyles.heading3,
                ),
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Change Date',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _allSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _allSlots[index];
                      final isBooked = _bookedSlots.contains(slot);
                      final isSelected = _selectedTimeSlot == slot;

                      return InkWell(
                        onTap: isBooked
                            ? null
                            : () {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? AppColors.surface.withOpacity(0.5)
                                : (isSelected
                                      ? AppColors.primary
                                      : AppColors.surface),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.glassBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isBooked
                                  ? AppColors.textMuted
                                  : (isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary),
                              fontWeight: FontWeight.bold,
                              decoration: isBooked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Payment Method Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: PaymentMethodSelector(
              selectedMethod: _selectedPaymentMethod,
              onMethodChanged: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '\$${widget.ground.price.toStringAsFixed(2)}',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<BookingProvider>(
                    builder: (context, provider, _) {
                      return PrimaryButton(
                        text: 'Pay & Book',
                        onPressed: _selectedTimeSlot != null
                            ? _initiatePayment
                            : () {},
                        color: _selectedTimeSlot != null
                            ? AppColors.primary
                            : AppColors.textMuted.withOpacity(0.3),
                        isLoading: provider.isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
