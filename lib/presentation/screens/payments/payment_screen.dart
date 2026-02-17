import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sports_studio/core/theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final String tracker;
  final Function(Map<String, dynamic>) onPaymentComplete;
  final VoidCallback onPaymentCancel;

  const PaymentScreen({
    super.key,
    required this.tracker,
    required this.onPaymentComplete,
    required this.onPaymentCancel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    // Construct checkout URL
    // In Sandbox: https://sandbox.api.getsafepay.com/checkout/pay?tracker=...
    // In Production: https://api.getsafepay.com/checkout/pay?tracker=...

    // Since we are mocking the tracker, this URL might not load correctly,
    // but the WebView integration is correct.
    // If we use a mocked tracker 'track_123', Safepay will 404.
    // So for DEV, if tracker starts with 'track_', we might want to load a dummy success page?
    // Or just let it fail but explain.

    final url = WebUri(
      "https://sandbox.api.getsafepay.com/checkout/pay?tracker=${widget.tracker}",
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onPaymentCancel,
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: url),
        initialSettings: InAppWebViewSettings(
          isInspectable: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllow: "camera; microphone",
          allowsLinkPreview: false,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          if (url != null) {
            final String urlString = url.toString();
            // Check for success/cancel Redirects
            // Safepay redirects to the success/cancel URL configured in the dashboard.
            // We assume standard params or specific path.

            // For Manual Integration, standard is often ?success=true or similar.
            // Or we look for the specific domain we set.

            // MOCK LOGIC for 'track_' dummy tracker:
            if (widget.tracker.startsWith('track_')) {
              // Inject a button or auto-complete for testing?
              // Or just assume user will likely Cancel since page is 404.
            }
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url!;
          final urlString = uri.toString();

          // Check for redirect triggers
          if (urlString.contains('success') ||
              urlString.contains('payment_success')) {
            widget.onPaymentComplete({});
            return NavigationActionPolicy.CANCEL;
          }

          if (urlString.contains('cancel') ||
              urlString.contains('payment_cancel')) {
            widget.onPaymentCancel();
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
