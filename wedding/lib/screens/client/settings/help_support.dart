import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Function to launch email
  Future<void> _sendEmail() async {
    final mailtoLink = Mailto(
      to: ['support@weddingplannerapp.com'],
      subject: 'Wedding Planner App Support',
      body: 'Hello Wedding Planner Team,\n\nI need assistance with:',
    );
    await launchUrl(
      Uri.parse(
        'mailto:${mailtoLink.to}?subject=${mailtoLink.subject}&body=${mailtoLink.body}',
      ),
    );
  }

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 50, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to assist you with any questions or issues',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact options
            Text(
              'Contact Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            // Email support
            Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.grey[700]),
                title: Text(
                  'Email Support',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                subtitle: Text(
                  'Get response within 24 hours',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onTap: _sendEmail,
              ),
            ),

            // Call support
            Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.grey[700]),
                title: Text(
                  'Call Support',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                subtitle: Text(
                  'Mon-Fri, 9AM-5PM',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onTap: () => _makePhoneCall('+1-800-WED-PLAN'),
              ),
            ),

            // Live chat
            Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.grey[700]),
                title: Text(
                  'Live Chat',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                subtitle: Text(
                  'Chat with our support team',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onTap: () {
                  // Implement live chat functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Live chat will be available soon',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // FAQ section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              color: Colors.white,
              elevation: 1,
              child: ExpansionTile(
                title: Text(
                  'How do I book a service provider?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'To book a service provider, browse through the categories, select a provider you like, check their availability, and proceed with the booking process. You\'ll need to provide your wedding date and details.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: Colors.white,
              elevation: 1,
              child: ExpansionTile(
                title: Text(
                  'Can I cancel or modify a booking?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Yes, you can cancel or modify bookings through the "My Bookings" section. Please note that cancellation policies vary by service provider and may include fees depending on how close your cancellation is to the wedding date.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: Colors.white,
              elevation: 1,
              child: ExpansionTile(
                title: Text(
                  'How do payments work?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'We accept various payment methods including credit cards and digital wallets. Most bookings require a deposit to secure your date, with the balance due closer to your wedding date. All payments are processed securely.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: Colors.white,
              elevation: 1,
              child: ExpansionTile(
                title: Text(
                  'What if I have issues with a vendor?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'If you experience any issues with a vendor, please contact our support team immediately. We will mediate between you and the vendor to resolve the issue. Our team is committed to ensuring your wedding planning experience is smooth and stress-free.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: Colors.white,
              elevation: 1,
              child: ExpansionTile(
                title: Text(
                  'How do I create and manage my wedding checklist?',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'The app automatically generates a personalized wedding checklist based on your wedding date. You can access it from the dashboard, mark tasks as completed, add custom tasks, and set reminders for important deadlines.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Additional resources
            Text(
              'Additional Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.library_books, color: Colors.grey[700]),
                title: Text(
                  'Wedding Planning Guide',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onTap: () {
                  // Navigate to wedding planning guide
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Wedding planning guide will open',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
              ),
            ),

            Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.video_library, color: Colors.grey[700]),
                title: Text(
                  'Video Tutorials',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onTap: () {
                  // Navigate to video tutorials
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Video tutorials will open',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Support hours
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Hours',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Emergency support is available for urgent wedding-related issues outside these hours.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
