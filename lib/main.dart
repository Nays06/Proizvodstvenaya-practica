import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/sets_screen.dart';
import 'screens/edit_set_screen.dart';
import 'screens/learn_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/sets_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SetsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: auth.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          initialRoute: auth.isAuthenticated ? '/sets' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/sets': (context) => const SetsScreen(),
            '/edit_set': (context) => const EditSetScreen(),
            '/learn': (context) => const LearnScreen(),
          },
        ),
      ),
    );
  }
}