import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Override colors for black & white theme
    final primaryColor = Colors.black;
    final onPrimaryColor = Colors.white;
    final secondaryColor = Colors.white;
    final onSurfaceColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.05),
              secondaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            color: secondaryColor,
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Policy',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: ${DateTime.now().toString().substring(0, 10)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: onSurfaceColor.withOpacity(0.6),
                      ),
                    ),
                    const Divider(
                      height: 32,
                      thickness: 1.2,
                      color: Colors.black12,
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '1. Information We Collect',
                      'We collect information you provide directly to us, including:\n'
                          '• Personal information (name, email, phone number)\n'
                          '• Wedding details (date, venue, preferences)\n'
                          '• Payment information (processed securely by our partners)\n'
                          '• Communications with service providers',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '2. How We Use Your Information',
                      'We use the information we collect to:\n'
                          '• Provide, maintain, and improve our services\n'
                          '• Connect you with wedding service providers\n'
                          '• Process transactions and send related information\n'
                          '• Send you technical notices and support messages\n'
                          '• Respond to your comments and questions',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '3. Information Sharing',
                      'We may share your information with:\n'
                          '• Wedding service providers to facilitate bookings\n'
                          '• Third-party vendors who provide services on our behalf\n'
                          '• As required by law or to protect our rights\n'
                          '• In connection with a business transfer or merger',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '4. Data Security',
                      'We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '5. Your Choices',
                      'You can:\n'
                          '• Update your account information in the app settings\n'
                          '• Opt-out of promotional communications\n'
                          '• Request deletion of your account by contacting us',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '6. Children\'s Privacy',
                      'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '7. Changes to This Policy',
                      'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '8. Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us at: privacy@weddingplannerapp.com',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(
    ThemeData theme,
    Color primaryColor,
    Color onSurfaceColor,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }
}
