/// Email Configuration for SMTP
///
/// IMPORTANT: Configure your email provider settings here
class EmailConfig {
  // ============================================
  // 📧 SMTP CONFIGURATION - REPLACE WITH YOUR DETAILS
  // ============================================

  /// SMTP Server (e.g., smtp.gmail.com, smtp.office365.com)
  static const String smtpServer = 'smtp.gmail.com';

  /// SMTP Port (usually 587 for TLS, 465 for SSL)
  static const int smtpPort = 587;

  /// Use SSL/TLS
  static const bool useSSL = false; // false for TLS (port 587), true for SSL (port 465)

  /// Your Email Address (sender)
  /// Example: 'your-email@gmail.com'
  static const String senderEmail = 'ayarimahdi287@gmail.com';

  /// Your Email Password or App-Specific Password
  /// For Gmail: Create App Password at https://myaccount.google.com/apppasswords
  /// Example: 'abcd efgh ijkl mnop'
  static const String senderPassword = 'jrsvqcazenfvtwnx';

  /// Sender Name (shown in emails)
  static const String senderName = 'GoBeyond Travel';

  /// Company Info
  static const String companyName = 'GoBeyond Travel';
  static const String companyWebsite = 'https://gobeyond.travel';
  static const String supportEmail = 'support@gobeyond.travel';
  static const String supportPhone = '+1 (800) 123-4567';

  // ============================================
  // EMAIL TEMPLATES
  // ============================================

  /// Enable email notifications
  static const bool enableEmails = true;

  /// Enable test mode (prints email instead of sending)
  static const bool testMode = false;
}

// ============================================
// 📧 HOW TO CONFIGURE FOR GMAIL
// ============================================
//
// 1. Go to: https://myaccount.google.com/security
// 2. Enable "2-Step Verification"
// 3. Go to: https://myaccount.google.com/apppasswords
// 4. Create "App Password" for "Mail"
// 5. Copy the 16-character password
// 6. Paste it in senderPassword above (with spaces is OK)
//
// Example:
// senderEmail: 'john.doe@gmail.com'
// senderPassword: 'abcd efgh ijkl mnop'
//
// ============================================
// 📧 OTHER PROVIDERS
// ============================================
//
// Outlook/Office365:
// - smtpServer: 'smtp.office365.com'
// - smtpPort: 587
// - useSSL: false
//
// Yahoo:
// - smtpServer: 'smtp.mail.yahoo.com'
// - smtpPort: 465 or 587
// - useSSL: true (for 465) or false (for 587)
//
// Custom SMTP:
// - Contact your email provider for settings

