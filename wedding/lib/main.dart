// main.dart
import 'package:flutter/material.dart';
import 'screens/admin/category.dart';
import 'screens/admin/profile.dart';
import 'screens/admin/home.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/client/home_client.dart';
import 'screens/client/profile_client.dart';
import 'screens/client/category_client.dart';
import 'widgets/main_wrapper.dart'; // Add this import
import 'screens/intro_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/client/settings/terms_conditions_screen.dart';
import 'screens/client/settings/privacy_policy_screen.dart';
import 'screens/client/settings/help_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(), // Light theme
            darkTheme: ThemeData.dark(), // Dark theme
            themeMode: themeProvider.themeMode, // Use provider's theme mode
            initialRoute: '/Intro',
            routes: {
              '/Intro': (context) => const IntroScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/category': (context) => const CategoryScreen(),
              '/Login': (context) => const LoginScreen(),
              '/Signup': (context) => const SignupScreen(),
              '/homeclient': (context) => const HomeClientScreen(),
              '/profileclient': (context) => const ProfileClientScreen(),
              '/categoryclient': (context) => const CategoryClientScreen(),
              '/mainwrapper': (context) => const MainWrapper(), // Add this route
              '/Onboarding': (context) => const OnboardingScreen(),
              '/terms': (context) => const TermsConditionsScreen(),
              '/privacy': (context) => const PrivacyPolicyScreen(),
              '/help-support': (context) => const HelpSupportScreen(),
            },
          );
        },
      ),
    );
  }
}