import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
        title: const Text('Terms & Conditions'),
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
                        Icon(Icons.gavel, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Terms & Conditions',
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
                      '1. Acceptance of Terms',
                      'By accessing and using Wedding Planner App, you accept and agree to be bound by the terms and provisions of this agreement.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '2. User Responsibilities',
                      'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '3. Service Providers',
                      'We connect users with wedding service providers. We are not responsible for the quality of services provided by third-party vendors. All bookings and agreements are between you and the service provider.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '4. Payments and Cancellations',
                      'Payment processing is handled through secure third-party providers. Cancellation policies vary by service provider and will be clearly stated before booking.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '5. Intellectual Property',
                      'All content included on this app, such as text, graphics, logos, images, and software, is the property of Wedding Planner App or its content suppliers and protected by international copyright laws.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '6. Limitation of Liability',
                      'Wedding Planner App shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use of or inability to use the service.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '7. Changes to Terms',
                      'We reserve the right to modify these terms at any time. We will provide notice of significant changes through our app or via email.',
                    ),
                    _section(
                      theme,
                      primaryColor,
                      onSurfaceColor,
                      '8. Governing Law',
                      'These terms shall be governed by and construed in accordance with the laws of the country in which our company is registered, without regard to its conflict of law provisions.',
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
