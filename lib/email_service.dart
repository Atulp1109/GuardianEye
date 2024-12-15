import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendEmailWithCredentials(String recipientEmail, String email, String password) async {
    final smtpServer = gmail('your.email@gmail.com', 'yourpassword');

    final message = Message()
      ..from = Address('your.email@gmail.com', 'Your Name')
      ..recipients.add(recipientEmail) // Use the recipient's email address here
      ..subject = 'Your Credentials'
      ..html = '''
        <h1>Your Credentials</h1>
        <p>Email: $email</p>
        <p>Password: $password</p>
      ''';

    try {
      final sendReport = await send(message, smtpServer);

      // Check if sendReport is not null to ensure no errors occurred
      if (sendReport != null) {
        print('Email sent successfully!');
      } else {
        print('Failed to send email.');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
