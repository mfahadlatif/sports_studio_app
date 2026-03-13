import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/services/safepay_service.dart';
import 'package:sports_studio/widgets/safepay_payment_widget.dart';

class PaymentController extends GetxController {
  final RxBool isProcessingPayment = false.obs;
  final RxBool isVerifyingPayment = false.obs;
  final Rxn<Booking> currentBooking = Rxn<Booking>();
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxString paymentToken = ''.obs;
  final RxMap<String, dynamic> paymentData = <String, dynamic>{}.obs;

  final BookingApiService _bookingApiService = BookingApiService();
  final TransactionApiService _transactionApiService = TransactionApiService();
  final SafepayService _safepayService = Get.find<SafepayService>();

  @override
  void onInit() {
    super.onInit();
    final booking = Get.arguments;
    if (booking != null) {
      currentBooking.value = booking;
      fetchTransactions();
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final transactionList = await _transactionApiService
          .getUserTransactions();
      transactions.value = transactionList;
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> initiateSafepayPayment({
    required int bookingId,
    required double amount,
    String? callbackUrl,
  }) async {
    if (amount <= 0) {
      AppUtils.showError(message: 'Invalid payment amount');
      return;
    }

    isProcessingPayment.value = true;
    try {
      final response = await _safepayService.initiateCheckout(
        amount: amount,
      );

      if (response == null) return;

      final tracker = response['tracker'];
      final token = response['token'];

      if (tracker == null) {
        AppUtils.showError(message: 'Failed to initialize payment with Safepay');
        return;
      }

      paymentToken.value = tracker;

      // Navigate to Safepay Checkout Package Widget
      final result = await Get.to(
        () => SafepayPaymentWidget(
          amount: amount,
          tracker: tracker,
          token: token,
        ),
      );

      if (result == true) {
        // Payment completed — finalize booking
        await _bookingApiService.finalizePayment(bookingId);
        AppUtils.showSuccess(message: 'Payment successful! Booking confirmed.');
        Get.offAllNamed('/landing');
      } else {
        AppUtils.showInfo(
          title: 'Cancelled',
          message: 'Payment was cancelled.',
        );
      }
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> verifySafepayPayment(String token) async {
    isVerifyingPayment.value = true;
    try {
      final isValid = await _safepayService.verifyPayment(token);

      if (isValid) {
        AppUtils.showSuccess(message: 'Payment verified successfully!');
        if (currentBooking.value != null) {
          await _bookingApiService.finalizePayment(currentBooking.value!.id);
        }
        Get.offAllNamed('/my-bookings');
      } else {
        AppUtils.showError(
          message: 'Payment could not be verified. Please contact support.',
        );
      }
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isVerifyingPayment.value = false;
    }
  }

  Future<void> getTransaction(int transactionId) async {
    try {
      final transaction = await _transactionApiService.getTransaction(
        transactionId,
      );
      // Navigate to transaction details or update current transaction data
      Get.toNamed('/transaction-details', arguments: transaction);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch transaction: $e');
    }
  }

  Future<void> retryPayment() async {
    if (currentBooking.value == null) {
      AppUtils.showError(message: 'No booking available for retry');
      return;
    }

    await initiateSafepayPayment(
      bookingId: currentBooking.value!.id,
      amount: currentBooking.value!.totalPrice,
    );
  }

  Future<void> cancelPayment() async {
    try {
      // This would depend on your backend API for payment cancellation
      // You might need to implement a cancel payment endpoint
      AppUtils.showSuccess(message: 'Payment cancelled');
      Get.offAllNamed('/my-bookings');
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  void setBooking(Booking booking) {
    currentBooking.value = booking;
  }

  void clearPaymentData() {
    paymentData.clear();
    paymentToken.value = '';
  }

  bool get hasPendingPayment {
    return paymentToken.value.isNotEmpty;
  }

  bool get isPaymentProcessing {
    return isProcessingPayment.value || isVerifyingPayment.value;
  }

  String get formattedAmount {
    if (currentBooking.value != null) {
      return 'PKR ${currentBooking.value!.totalPrice.toStringAsFixed(2)}';
    }
    return 'PKR 0.00';
  }

  Transaction? getTransactionById(int transactionId) {
    try {
      return transactions.firstWhereOrNull((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  List<Transaction> getCompletedTransactions() {
    return transactions.where((t) => t.status == 'completed').toList();
  }

  List<Transaction> getPendingTransactions() {
    return transactions.where((t) => t.status == 'pending').toList();
  }

  List<Transaction> getFailedTransactions() {
    return transactions.where((t) => t.status == 'failed').toList();
  }

  double getTotalSpent() {
    return transactions
        .where((t) => t.status == 'completed')
        .fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
  }

  void refreshTransactions() {
    fetchTransactions();
  }

}
