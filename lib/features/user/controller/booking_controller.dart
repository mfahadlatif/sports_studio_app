import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/network/api_services.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/core/services/data_fetch_service.dart';
import 'package:sport_studio/core/services/safepay_service.dart';
import 'package:sport_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/widgets/safepay_payment_widget.dart';

class BookingController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> selectedSlots = <String>[].obs;
  final RxBool isBooking = false.obs;
  final RxInt players = 2.obs;
  final double serviceFee = 0.0;

  @override
  void onInit() {
    super.onInit();
    // Initialize data immediately on load
    final ground = Get.arguments;
    setGroundAndFetchAvailability(ground);
  }

  final RxList<String> allSlots = <String>[].obs;

  final RxList<String> bookedSlots = <String>[].obs;
  final RxBool isLoadingSlots = false.obs;

  final RxString promoCode = ''.obs;
  final RxBool isCheckingPromo = false.obs;
  final Rxn<Deal> selectedDeal = Rxn<Deal>();
  final RxList<Deal> availableDeals = <Deal>[].obs;
  final RxBool isLoadingDeals = false.obs;

  double get discount => selectedDeal.value != null 
    ? (subtotal * (selectedDeal.value!.discountPercentage / 100)) 
    : 0.0;

  final BookingApiService _bookingApiService = BookingApiService();
  final DealApiService _dealApiService = DealApiService();
  final DataFetchService _dataFetchService = Get.find<DataFetchService>();
  final SafepayService _safepayService = Get.find<SafepayService>();


  /// Set ground and fetch availability for that ground
  void setGroundAndFetchAvailability(dynamic ground) {
    if (ground != null) {
      final idData = ground['id'];
      if (idData != null) {
        final id = int.tryParse(idData.toString());
        if (id != null) {
          fetchAvailability(id);
          fetchAvailableDeals(ground);
        }
      }
    }
  }

  Future<void> fetchAvailability(int groundId) async {
    isLoadingSlots.value = true;
    try {
      final ground = Get.arguments;
      final groundObj = ground != null ? Ground.fromJson(ground) : null;
      
      // Dynamically calculate operating hours based on ground data
      // Web: const startHour = ground?.opening_time ? parseInt(ground.opening_time.split(':')[0]) : 8;
      // Web: let endHour = ground?.closing_time ? parseInt(ground.closing_time.split(':')[0]) : 22;
      
      int startHour = 8;
      int endHour = 22;

      if (groundObj != null) {
        if (groundObj.openingTime != null && groundObj.openingTime!.isNotEmpty) {
          startHour = int.tryParse(groundObj.openingTime!.split(':').first) ?? 8;
        }
        if (groundObj.closingTime != null && groundObj.closingTime!.isNotEmpty) {
          endHour = int.tryParse(groundObj.closingTime!.split(':').first) ?? 22;
          if (endHour == 0) endHour = 24; // Handle midnight
        }
      }

      // Generate allSlots based on operating hours
      final List<String> generatedSlots = [];
      for (int i = startHour; i < endHour; i++) {
        // Handle overflow for 24-hour cycle if closing > opening
        final hour = i % 24;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        generatedSlots.add('${displayHour.toString().padLeft(2, '0')}:00 $period');
      }
      
      // If we couldn't generate any slots (invalid range), fallback
      if (generatedSlots.isEmpty) {
        generatedSlots.addAll([
          '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM',
          '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
          '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM', '08:00 PM',
          '09:00 PM', '10:00 PM',
        ]);
      }
      
      allSlots.value = generatedSlots;

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final bookings = await _dataFetchService.fetchGroundBookings(
        groundId,
        date: dateStr,
      );

      final List<String> booked = [];

      for (var b in bookings) {
        try {
          // NORMALIZE: Align with web's normalization to ignore Z (UTC) and treat as local ground time
          // Web: const normalizeTime = (timeStr: string) => timeStr.split('.')[0].replace('Z', '').replace(' ', 'T');
          String startStr = b['start_time']?.toString() ?? '';
          String endStr = b['end_time']?.toString() ?? '';
          
          if (startStr.isEmpty || endStr.isEmpty) continue;

          String normalize(String s) => s.split('.').first.replaceAll('Z', '').replaceAll(' ', 'T');
          
          final start = DateTime.parse(normalize(startStr));
          final end = DateTime.parse(normalize(endStr));

          // Identify which of our generated slots overlap with this booking
          for (var slotStr in allSlots) {
            final slotTime = _parseSlotTime(slotStr);
            // Construct a DateTime for slot on selected date (local context)
            final slotStart = DateTime(
              selectedDate.value.year,
              selectedDate.value.month,
              selectedDate.value.day,
              slotTime.hour,
              slotTime.minute,
            );
            final slotEnd = slotStart.add(const Duration(hours: 1));

            // Overlap check
            if (slotStart.isBefore(end) && slotEnd.isAfter(start)) {
              booked.add(slotStr);
            }
          }
        } catch (e) {
          print('Error parsing booking time: $e');
        }
      }

      bookedSlots.value = booked.toSet().toList(); // Unique
    } catch (e) {
      AppUtils.showError(message: 'Error fetching availability: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }

  TimeOfDay _parseSlotTime(String slotStr) {
    try {
      // Try formats: "06:00 AM" or "06:00"
      if (slotStr.contains('AM') || slotStr.contains('PM')) {
        final time = DateFormat('hh:mm a').parse(slotStr);
        return TimeOfDay(hour: time.hour, minute: time.minute);
      } else {
        final parts = slotStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      return const TimeOfDay(hour: 6, minute: 0);
    }
  }

  bool isSlotPassed(String slotStr) {
    try {
      final now = DateTime.now();
      // Normalize dates for day comparison:
      final todayAtMidnight = DateTime(now.year, now.month, now.day);
      final selectedDateAtMidnight = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);

      if (selectedDateAtMidnight.isBefore(todayAtMidnight)) {
        return true; // Past dates
      }
      if (selectedDateAtMidnight.isAfter(todayAtMidnight)) {
        return false; // Future dates
      }

      // If it's today, parse slot and compare time
      final slotTime = _parseSlotTime(slotStr);
      final slotDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        slotTime.hour,
        slotTime.minute,
      );

      // We mark as passed if the slot has already started or is just starting.
      // E.g., if it's 09:01, the 09:00 slot is passed.
      return now.isAfter(slotDateTime);
    } catch (e) {
      return false;
    }
  }

  bool isSlotAvailable(String slot) {
    return !bookedSlots.contains(slot) && !isSlotPassed(slot);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlots.clear();
    final ground = Get.arguments;
    if (ground != null && ground['id'] != null) {
      fetchAvailability(ground['id']);
    }
  }

  void toggleSlot(String slot) {
    if (!isSlotAvailable(slot)) return;
    
    if (selectedSlots.contains(slot)) {
      selectedSlots.remove(slot);
    } else {
      selectedSlots.add(slot);
    }
  }

  Future<void> fetchAvailableDeals(dynamic ground) async {
    isLoadingDeals.value = true;
    try {
      final deals = await _dealApiService.getPublicDeals();
      final now = DateTime.now();
      final groundSport = (ground?['type'] ?? '').toString().toLowerCase();

      availableDeals.value = deals.where((deal) {
        return deal.isActive && 
               deal.validUntil.isAfter(now) && 
               _dealAppliesToSport(deal.applicableSports, groundSport);
      }).toList();
    } catch (e) {
      print('Error fetching available deals: $e');
    } finally {
      isLoadingDeals.value = false;
    }
  }

  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) return;
    isCheckingPromo.value = true;
    try {
      final ground = Get.arguments;
      final groundId = int.tryParse(ground?['id']?.toString() ?? '');
      final deal = await _dealApiService.validatePromoCode(
        code: code,
        groundId: groundId,
      );

      // Also check validity dates and sport applicability.
      final now = DateTime.now();
      final groundSport = (ground?['type'] ?? '').toString().toLowerCase();

        if (deal != null) {
          if (!deal.isActive ||
              !deal.validUntil.isAfter(now) ||
              !_dealAppliesToSport(deal.applicableSports, groundSport)) {
            AppUtils.showError(message: 'Invalid or expired promo code');
            selectedDeal.value = null;
            return;
          }

          selectedDeal.value = deal;
          promoCode.value = code;
          AppUtils.showSuccess(
            message:
                'Promo code applied: ${deal.title} (${deal.discountPercentage.toStringAsFixed(0)}% off)',
          );
        } else {
          AppUtils.showError(message: 'Invalid or expired promo code');
          selectedDeal.value = null;
        }
    } catch (e) {
      AppUtils.showError(message: 'Could not validate promo code');
    } finally {
      isCheckingPromo.value = false;
    }
  }

  void removePromoCode() {
    selectedDeal.value = null;
    promoCode.value = '';
    AppUtils.showInfo(message: 'Promo code removed');
  }

  bool _dealAppliesToSport(String? applicableSportsRaw, String groundSport) {
    if (groundSport.isEmpty) return true;
    if (applicableSportsRaw == null) return true;
    final raw = applicableSportsRaw.trim();
    if (raw.isEmpty) return true;

    // Backend stores applicable_sports as a string. Accept common formats:
    // - "cricket"
    // - "cricket,football"
    // - '["cricket","football"]'
    final lower = raw.toLowerCase();
    if (lower == 'all') return true;

    // JSON-ish list
    if (lower.startsWith('[') && lower.endsWith(']')) {
      final cleaned = lower.replaceAll('[', '').replaceAll(']', '');
      final parts = cleaned
          .split(',')
          .map((p) => p.replaceAll('"', '').replaceAll("'", '').trim())
          .where((p) => p.isNotEmpty)
          .toList();
      return parts.contains(groundSport);
    }

    // Comma-separated
    final parts = lower
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.contains(groundSport);
  }

  double get subtotal {
    final ground = Get.arguments;
    if (ground == null) return 0.0;
    final groundObj = Ground.fromJson(ground);
    return selectedSlots.length * groundObj.pricePerHour;
  }

  double get totalPrice {
    final total = subtotal + serviceFee;
    return (total - discount).clamp(0, double.infinity);
  }

  void incrementPlayers(int max) {
    if (players.value < max) {
      players.value++;
    }
  }

  void decrementPlayers() {
    if (players.value > 1) {
      players.value--;
    }
  }

  Future<void> createBooking({String? paymentMethod}) async {
    final ground = Get.arguments;
    if (ground == null || ground['id'] == null) {
      AppUtils.showError(message: 'Ground data is missing.');
      return;
    }

    // Enforce phone verification before reserving a slot.
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      if (!profileController.isPhoneVerified) {
        Get.dialog(
          PhoneVerificationDialog(
            initialPhone: profileController.userProfile['phone']?.toString() ?? '',
            onVerified: () {},
          ),
        );
        return;
      }
    }


    isBooking.value = true;
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final startTimeStr = DateFormat(
        'HH:mm',
      ).format(DateFormat('hh:mm a').parse(selectedSlots.first));
      final endTimeStr = DateFormat('HH:mm').format(
        DateFormat(
          'hh:mm a',
        ).parse(selectedSlots.last).add(const Duration(hours: 1)),
      );

      final bookingData = {
        'ground_id': ground['id'],
        'start_time': '$formattedDate $startTimeStr:00',
        'end_time': '$formattedDate $endTimeStr:00',
        'total_price': totalPrice, // Discount is already factored in
        'players': players.value,
        // FIX 12: Removed coupon_id — backend doesn't accept it, discount is pre-applied in total_price
      };

      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        bookingData['payment_method'] = paymentMethod;
        if (paymentMethod == 'wallet') {
          bookingData['payment_status'] = 'paid';
          bookingData['status'] = 'confirmed';
        } else if (paymentMethod == 'cash') {
          bookingData['payment_status'] = 'unpaid';
          bookingData['status'] = 'pending';
        }
      }

      final booking = await _bookingApiService.createBooking(bookingData);

      if (paymentMethod == 'wallet' || paymentMethod == 'cash') {
        final msg = paymentMethod == 'wallet' 
            ? 'Wallet payment successful! Booking confirmed.'
            : 'Booking confirmed! Please pay at the venue.';
        AppUtils.showSuccess(message: msg);
        Get.offAllNamed('/');
        selectedSlots.clear();
        return;
      }

      Get.offAllNamed(
        '/payment',
        arguments: {
          'bookingId': booking.id,
          'totalPrice': totalPrice,
          'subtotal': subtotal,
          'discount': discount,
          'deal': selectedDeal.value,
          'promoCode': promoCode.value,
          'paymentMethod': paymentMethod ?? 'card',
        },
      );
      selectedSlots.clear();
    } catch (e) {
      AppUtils.showError(message: 'Something went wrong while booking: $e');
    } finally {
      isBooking.value = false;
    }
  }

  /// Start a booking with direct Safepay payment flow.
  /// This implements: "if completed payment then book the ground"
  Future<void> bookWithSafepay() async {
    final ground = Get.arguments;
    if (ground == null || ground['id'] == null) {
      AppUtils.showError(message: 'Ground data is missing.');
      return;
    }


    if (selectedSlots.isEmpty) {
      AppUtils.showError(message: 'Please select at least one time slot.');
      return;
    }

    isBooking.value = true;
    try {
      // Step 1: Initiate Safepay via Service to get tracker
      final response = await _safepayService.initiateCheckout(
        amount: totalPrice,
      );

      final tracker = response?['tracker'];
      final token = response?['tbt'] ?? response?['token'];

      if (tracker == null) {
        AppUtils.showError(message: 'Failed to generate payment tracker. Please try again.');
        isBooking.value = false;
        return;
      }

      // Step 2: Open Safepay Widget (Package)
      final result = await Get.to(() => SafepayPaymentWidget(
        amount: totalPrice,
        tracker: tracker,
        token: token,
      ));

      if (result == true) {
        // Step 3: Payment successful - Now actually create the booking
        final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
        final startTimeStr = DateFormat('HH:mm').format(
          DateFormat('hh:mm a').parse(selectedSlots.first),
        );
        final endTimeStr = DateFormat('HH:mm').format(
          DateFormat('hh:mm a').parse(selectedSlots.last).add(const Duration(hours: 1)),
        );

        final bookingData = {
          'ground_id': ground['id'],
          'start_time': '$formattedDate $startTimeStr:00',
          'end_time': '$formattedDate $endTimeStr:00',
          'total_price': totalPrice,
          'players': players.value,
          'payment_method': 'safepay',
          'payment_status': 'paid',
        };

        final booking = await _bookingApiService.createBooking(bookingData);
        
        // Finalize if needed (some backends require a separate call)
        try {
          await _bookingApiService.finalizePayment(booking.id);
        } catch (_) {}

        AppUtils.showSuccess(message: 'Payment and booking successful!');
        Get.offAllNamed('/');
        selectedSlots.clear();
      } else {
        AppUtils.showInfo(title: 'Cancelled', message: 'Payment cancelled. Booking was not completed.');
      }
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> initiatePayment(int bookingId, double amount) async {
    try {
      final response = await _safepayService.initiateCheckout(
        amount: amount,
      );
      
      final tracker = response?['tracker'];

      if (tracker != null) {
        final token = response?['token'];
        Get.to(() => SafepayPaymentWidget(
              amount: amount,
              tracker: tracker,
              token: token,
            ));
        AppUtils.showSuccess(message: 'Payment initiated successfully');
      }
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> verifyPayment(String token) async {
    try {
      final isValid = await _safepayService.verifyPayment(token);
      if (isValid) {
        AppUtils.showSuccess(message: 'Payment verified successfully');
        Get.offAllNamed('/user-bookings');
      } else {
        AppUtils.showError(message: 'Payment verification failed');
      }
    } catch (e) {
      AppUtils.showError(message: 'Payment verification error: $e');
    }
  }
}
