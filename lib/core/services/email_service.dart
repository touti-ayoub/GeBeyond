import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import '../config/email_config.dart';

/// Email Service - Sends booking confirmations via SMTP
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  /// Send booking confirmation email
  Future<bool> sendBookingConfirmation({
    required String recipientEmail,
    required String recipientName,
    required String bookingReference,
    required String listingTitle,
    required String listingLocation,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    required String paymentIntentId,
  }) async {
    try {
      if (!EmailConfig.enableEmails) {
        if (kDebugMode) {
          print('📧 Email notifications disabled');
        }
        return false;
      }

      if (kDebugMode) {
        print('📧 Sending booking confirmation to: $recipientEmail');
      }

      // Generate email content
      final emailBody = _generateBookingConfirmationHTML(
        recipientName: recipientName,
        bookingReference: bookingReference,
        listingTitle: listingTitle,
        listingLocation: listingLocation,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        totalPrice: totalPrice,
        paymentIntentId: paymentIntentId,
      );

      final plainText = _generatePlainTextEmail(
        recipientName: recipientName,
        bookingReference: bookingReference,
        listingTitle: listingTitle,
        listingLocation: listingLocation,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        totalPrice: totalPrice,
      );

      // Create message
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(recipientEmail)
        ..subject = '✅ Booking Confirmed - ${bookingReference}'
        ..text = plainText
        ..html = emailBody;

      // Test mode - just print
      if (EmailConfig.testMode) {
        if (kDebugMode) {
          print('📧 [TEST MODE] Email would be sent to: $recipientEmail');
          print('📧 [TEST MODE] Subject: ${message.subject}');
          print('📧 [TEST MODE] Body:\n$plainText');
        }
        return true;
      }

      // Configure SMTP
      final smtpServer = EmailConfig.useSSL
          ? SmtpServer(
              EmailConfig.smtpServer,
              port: EmailConfig.smtpPort,
              ssl: true,
              username: EmailConfig.senderEmail,
              password: EmailConfig.senderPassword,
            )
          : gmail(EmailConfig.senderEmail, EmailConfig.senderPassword);

      // Send email
      final sendReport = await send(message, smtpServer);

      if (kDebugMode) {
        print('✅ Email sent successfully to: $recipientEmail');
        print('📧 Message ID: ${sendReport.toString()}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending email: $e');
      }
      return false;
    }
  }

  /// Generate HTML email template
  String _generateBookingConfirmationHTML({
    required String recipientName,
    required String bookingReference,
    required String listingTitle,
    required String listingLocation,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    required String paymentIntentId,
  }) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final checkInFormatted = dateFormat.format(checkIn);
    final checkOutFormatted = dateFormat.format(checkOut);
    final nights = checkOut.difference(checkIn).inDays;

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmation</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 28px;">✅ Payment Successful!</h1>
                            <p style="margin: 10px 0 0 0; color: #ffffff; font-size: 16px;">Your booking is confirmed</p>
                        </td>
                    </tr>
                    
                    <!-- Greeting -->
                    <tr>
                        <td style="padding: 30px 30px 20px 30px;">
                            <h2 style="margin: 0 0 15px 0; color: #333333; font-size: 22px;">Hello $recipientName! 👋</h2>
                            <p style="margin: 0; color: #666666; font-size: 16px; line-height: 1.6;">
                                Great news! Your payment has been processed successfully and your booking is confirmed. 
                                Get ready for an amazing experience!
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Booking Reference -->
                    <tr>
                        <td style="padding: 0 30px 20px 30px;">
                            <div style="background-color: #E3F2FD; border-left: 4px solid #2196F3; padding: 15px 20px; border-radius: 5px;">
                                <p style="margin: 0; color: #1976D2; font-size: 14px; font-weight: bold;">BOOKING REFERENCE</p>
                                <p style="margin: 5px 0 0 0; color: #1976D2; font-size: 24px; font-weight: bold; letter-spacing: 2px;">$bookingReference</p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Booking Details -->
                    <tr>
                        <td style="padding: 0 30px 20px 30px;">
                            <h3 style="margin: 0 0 15px 0; color: #333333; font-size: 18px;">📋 Booking Details</h3>
                            <table width="100%" cellpadding="10" cellspacing="0" style="border: 1px solid #e0e0e0; border-radius: 5px;">
                                <tr style="background-color: #f9f9f9;">
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Property:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        $listingTitle
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Location:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        📍 $listingLocation
                                    </td>
                                </tr>
                                <tr style="background-color: #f9f9f9;">
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Check-in:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        📅 $checkInFormatted
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Check-out:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        📅 $checkOutFormatted
                                    </td>
                                </tr>
                                <tr style="background-color: #f9f9f9;">
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Duration:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        🌙 $nights ${nights == 1 ? 'night' : 'nights'}
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666666; font-size: 14px;">
                                        <strong>Guests:</strong>
                                    </td>
                                    <td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #333333; font-size: 14px;">
                                        👥 $guests ${guests == 1 ? 'guest' : 'guests'}
                                    </td>
                                </tr>
                                <tr style="background-color: #E8F5E9;">
                                    <td style="padding: 12px; color: #2E7D32; font-size: 14px;">
                                        <strong>Total Paid:</strong>
                                    </td>
                                    <td style="padding: 12px; color: #2E7D32; font-size: 18px; font-weight: bold;">
                                        \$${totalPrice.toStringAsFixed(2)}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Payment Info -->
                    <tr>
                        <td style="padding: 0 30px 30px 30px;">
                            <div style="background-color: #F1F8E9; padding: 15px 20px; border-radius: 5px; border-left: 4px solid #4CAF50;">
                                <p style="margin: 0; color: #558B2F; font-size: 14px;">
                                    <strong>💳 Payment Confirmed</strong>
                                </p>
                                <p style="margin: 5px 0 0 0; color: #689F38; font-size: 12px;">
                                    Transaction ID: $paymentIntentId
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Next Steps -->
                    <tr>
                        <td style="padding: 0 30px 30px 30px;">
                            <h3 style="margin: 0 0 15px 0; color: #333333; font-size: 18px;">📝 What's Next?</h3>
                            <ul style="margin: 0; padding-left: 20px; color: #666666; font-size: 14px; line-height: 1.8;">
                                <li>You'll receive a reminder email 24 hours before check-in</li>
                                <li>Make sure to bring a valid ID for check-in</li>
                                <li>View your booking details anytime in the GoBeyond app</li>
                                <li>Contact us if you need any assistance</li>
                            </ul>
                        </td>
                    </tr>
                    
                    <!-- Support -->
                    <tr>
                        <td style="padding: 0 30px 30px 30px;">
                            <div style="background-color: #FFF3E0; padding: 15px 20px; border-radius: 5px;">
                                <p style="margin: 0 0 10px 0; color: #E65100; font-size: 14px; font-weight: bold;">
                                    Need Help? 🤝
                                </p>
                                <p style="margin: 0; color: #F57C00; font-size: 13px; line-height: 1.6;">
                                    📧 Email: ${EmailConfig.supportEmail}<br>
                                    📞 Phone: ${EmailConfig.supportPhone}<br>
                                    🌐 Website: ${EmailConfig.companyWebsite}
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f9f9f9; padding: 20px 30px; text-align: center; border-top: 1px solid #e0e0e0;">
                            <p style="margin: 0 0 10px 0; color: #666666; font-size: 14px;">
                                Thank you for choosing ${EmailConfig.companyName}!
                            </p>
                            <p style="margin: 0; color: #999999; font-size: 12px;">
                                This is an automated email. Please do not reply to this message.
                            </p>
                            <p style="margin: 10px 0 0 0; color: #999999; font-size: 11px;">
                                © ${DateTime.now().year} ${EmailConfig.companyName}. All rights reserved.
                            </p>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
''';
  }

  /// Generate plain text email (fallback)
  String _generatePlainTextEmail({
    required String recipientName,
    required String bookingReference,
    required String listingTitle,
    required String listingLocation,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
  }) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final nights = checkOut.difference(checkIn).inDays;

    return '''
✅ PAYMENT SUCCESSFUL - BOOKING CONFIRMED

Hello $recipientName!

Great news! Your payment has been processed successfully and your booking is confirmed.

BOOKING REFERENCE: $bookingReference

BOOKING DETAILS:
─────────────────────────────────────
Property: $listingTitle
Location: $listingLocation
Check-in: ${dateFormat.format(checkIn)}
Check-out: ${dateFormat.format(checkOut)}
Duration: $nights ${nights == 1 ? 'night' : 'nights'}
Guests: $guests ${guests == 1 ? 'guest' : 'guests'}
Total Paid: \$${totalPrice.toStringAsFixed(2)}
─────────────────────────────────────

WHAT'S NEXT?
• You'll receive a reminder email 24 hours before check-in
• Make sure to bring a valid ID for check-in
• View your booking details anytime in the GoBeyond app
• Contact us if you need any assistance

NEED HELP?
Email: ${EmailConfig.supportEmail}
Phone: ${EmailConfig.supportPhone}
Website: ${EmailConfig.companyWebsite}

Thank you for choosing ${EmailConfig.companyName}!

This is an automated email. Please do not reply to this message.

© ${DateTime.now().year} ${EmailConfig.companyName}. All rights reserved.
''';
  }
}

