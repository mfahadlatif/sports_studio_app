import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class PaymentController extends GetxController {
  final RxBool isProcessingPayment = false.obs;
  final RxBool isVerifyingPayment = false.obs;
  final Rxn<Booking> currentBooking = Rxn<Booking>();
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxString paymentToken = ''.obs;
  final RxMap<String, dynamic> paymentData = <String, dynamic>{}.obs;

  final PaymentApiService _paymentApiService = PaymentApiService();
  final BookingApiService _bookingApiService = BookingApiService();
  final TransactionApiService _transactionApiService = TransactionApiService();

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
      AppUtils.showError(message: 'Failed to fetch transactions: $e');
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
      // FIX 1: Backend only accepts {amount, currency} — not booking_id or callback_url
      final response = await _paymentApiService.initiateSafepayPayment({
        'amount': amount,
        'currency': 'PKR',
      });

      // FIX 1: Backend returns {tracker, environment, sandbox_url, production_url}
      final tracker = response['tracker'];
      final env = response['environment'] ?? 'sandbox';

      if (tracker == null) {
        AppUtils.showError(
          message: 'Failed to get payment tracker from Safepay',
        );
        return;
      }

      final checkoutBase = env == 'sandbox'
          ? 'https://sandbox.api.getsafepay.com/checkout/pay'
          : 'https://api.getsafepay.com/checkout/pay';

      final checkoutUrl =
          '$checkoutBase?tracker=$tracker&environment=$env&source=mobile';

      paymentToken.value = tracker;
      paymentData.value = response;

      // Navigate to payment WebView page
      final result = await Get.toNamed(
        '/payment-webview',
        arguments: {
          'url': checkoutUrl,
          'bookingId': bookingId,
          'amount': amount,
        },
      );

      if (result == true) {
        // Payment completed in WebView — finalize booking
        await _bookingApiService.finalizePayment(bookingId);
        AppUtils.showSuccess(message: 'Payment successful! Booking confirmed.');
        Get.offAllNamed('/my-bookings');
      } else {
        AppUtils.showInfo(
          title: 'Cancelled',
          message: 'Payment was cancelled.',
        );
      }
    } catch (e) {
      AppUtils.showError(message: 'Payment initiation failed: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> verifySafepayPayment(String token) async {
    isVerifyingPayment.value = true;
    try {
      // FIX 1: Pass token to backend verify endpoint
      final response = await _paymentApiService.verifySafepayPayment(token);

      if (response['status'] == 'valid') {
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
      AppUtils.showError(message: 'Payment verification failed: $e');
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
      AppUtils.showError(message: 'Failed to cancel payment: $e');
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

  @override
  void onClose() {
    super.onClose();
  }
}
