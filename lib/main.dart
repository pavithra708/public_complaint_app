import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/file_complaint_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/all_complaints_screen.dart';
import 'screens/complaint_details_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/firebase_config.dart';
//import 'generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:public_complaint_app/generated/app_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';  
import 'package:public_complaint_app/generated/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase safely
  // For mobile, Firebase will use google-services.json automatically
  // For web, we need to provide options manually
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: FirebaseConfig.webConfig["apiKey"] ?? '',
        authDomain: FirebaseConfig.webConfig["authDomain"] ?? '',
        projectId: FirebaseConfig.webConfig["projectId"] ?? '',
        storageBucket: FirebaseConfig.webConfig["storageBucket"] ?? '',
        messagingSenderId: FirebaseConfig.webConfig["messagingSenderId"] ?? '',
        appId: FirebaseConfig.webConfig["appId"] ?? '',
      ),
    );
  } else {
    // Mobile platforms (Android/iOS) will use google-services.json automatically
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Public Complaint App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: Colors.blue,
              useMaterial3: true,
            ),

            // ✅ Localization setup
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.supportedLocales,

            // ✅ Navigation routes
            home: const AuthWrapper(),
            routes: {
              '/file_complaint': (context) => const FileComplaintScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/all_complaints': (context) => const AllComplaintsScreen(),
              '/admin_login': (context) => const AdminLoginScreen(),
              '/admin_dashboard': (context) => const AdminDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Ensure login redirection is stable
    if (authService.user != null) {
      if (authService.isAdminSession) {
        return const AdminDashboardScreen();
      }
      return const DashboardScreen();
    }

    return LoginScreen();
  }
}
