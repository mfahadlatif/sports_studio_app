import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> selectedSlots = <String>[].obs;

  final RxList<String> availableSlots = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
    '10:00 PM',
  ].obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlots.clear();
  }

  void toggleSlot(String slot) {
    if (selectedSlots.contains(slot)) {
      selectedSlots.remove(slot);
    } else {
      selectedSlots.add(slot);
    }
  }

  double get totalPrice {
    return selectedSlots.length * 3000.0;
  }
}
