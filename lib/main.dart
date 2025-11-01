import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/screens/login_page.dart'; // Import LoginPage
import 'package:ipcam/screens/products_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import for desktop
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Import for web
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Use the web-specific factory
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Use the FFI factory for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await DatabaseHelper().database; // Initialize the database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة المتجر',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', ''), // Arabic, no country code
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const ProductsPage(),
    );
  }
}
