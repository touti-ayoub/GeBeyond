import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import '../config/stripe_config.dart';

/// Stripe Payment Service
/// Handles all payment operations with Stripe API
class StripePaymentService {
  static final StripePaymentService _instance = StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  final Dio _dio = Dio();
  bool _isInitialized = false;

  /// Initialize Stripe with publishable key
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set Stripe publishable key
      Stripe.publishableKey = StripeConfig.publishableKey;

      // Set merchant identifier for Apple Pay
      Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;

      // Set return URL for 3D Secure
      Stripe.urlScheme = 'gobeyond';

      if (kDebugMode) {
        print('✅ Stripe initialized successfully');
        print('📝 Mode: ${StripeConfig.isTestMode ? "TEST" : "LIVE"}');
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Stripe: $e');
      }
      rethrow;
    }
  }

  /// Create Payment Intent on backend/Stripe API
  ///
  /// In production, this should be done on your backend server
  /// For now, we're calling Stripe API directly (demo purposes only)
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents
      final amountInCents = toCents(amount);

      if (kDebugMode) {
        print('💳 Creating payment intent for \$$amount ($amountInCents cents)');
      }

      // Validate amount
      if (amountInCents < StripeConfig.minimumPaymentAmount) {
        throw Exception('Amount is below minimum (${StripeConfig.minimumPaymentAmount} cents)');
      }
      if (amountInCents > StripeConfig.maximumPaymentAmount) {
        throw Exception('Amount exceeds maximum (${StripeConfig.maximumPaymentAmount} cents)');
      }

      // Call Stripe API to create payment intent
      // ⚠️ WARNING: In production, this should be on your backend!
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': amountInCents,
          'currency': currency.toLowerCase(),
          'description': description ?? 'GoBeyond Travel Booking',
          'metadata': metadata ?? {},
          'automatic_payment_methods[enabled]': 'true',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (kDebugMode) {
        print('✅ Payment intent created: ${response.data['id']}');
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating payment intent: $e');
      }
      rethrow;
    }
  }

  /// Process payment with payment sheet
  Future<PaymentResult> processPayment({
    required double amount,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (kDebugMode) {
        print('💰 Processing payment: \$$amount');
      }

      // Step 1: Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: StripeConfig.currency,
        description: description,
        metadata: metadata,
      );

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: StripeConfig.companyName,
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF2196F3),
            ),
          ),
          googlePay: StripeConfig.enableGooglePay
              ? const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: StripeConfig.isTestMode,
                )
              : null,
          applePay: StripeConfig.enableApplePay
              ? const PaymentSheetApplePay(
                  merchantCountryCode: 'US',
                )
              : null,
        ),
      );

      if (kDebugMode) {
        print('✅ Payment sheet initialized');
      }

      // Step 3: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      if (kDebugMode) {
        print('✅ Payment successful!');
      }

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntent['id'],
        amount: amount,
        currency: StripeConfig.currency,
      );
    } on StripeException catch (e) {
      if (kDebugMode) {
        print('❌ Stripe error: ${e.error.message}');
      }

      return PaymentResult(
        success: false,
        error: e.error.message ?? 'Payment failed',
        errorCode: e.error.code.name,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Payment error: $e');
      }

      return PaymentResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Verify payment status
  Future<bool> verifyPayment(String paymentIntentId) async {
    try {
      final response = await _dio.get(
        'https://api.stripe.com/v1/payment_intents/$paymentIntentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
          },
        ),
      );

      final status = response.data['status'];
      if (kDebugMode) {
        print('💳 Payment status: $status');
      }

      return status == 'succeeded';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying payment: $e');
      }
      return false;
    }
  }

  /// Refund payment
  Future<bool> refundPayment({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final data = {
        'payment_intent': paymentIntentId,
        if (amount != null) 'amount': toCents(amount),
        if (reason != null) 'reason': reason,
      };

      final response = await _dio.post(
        'https://api.stripe.com/v1/refunds',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (kDebugMode) {
        print('✅ Refund processed: ${response.data['id']}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing refund: $e');
      }
      return false;
    }
  }
}

/// Payment Result Model
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final double? amount;
  final String? currency;
  final String? error;
  final String? errorCode;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.amount,
    this.currency,
    this.error,
    this.errorCode,
  });

  @override
  String toString() {
    if (success) {
      return 'PaymentResult(success: true, paymentIntentId: $paymentIntentId, amount: \$$amount $currency)';
    } else {
      return 'PaymentResult(success: false, error: $error, errorCode: $errorCode)';
    }
  }
}

