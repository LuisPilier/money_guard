import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login.dart'; // Importa tu pantalla Login aquí

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yjdqtsgywfnwttlkglon.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlqZHF0c2d5d2Zud3R0bGtnbG9uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAzMjg3NzAsImV4cCI6MjAzNTkwNDc3MH0.UP9u5LMzmQXjy_epwoBoKBqNu-Y-nP3mNEh7y2X0_-8',
  );

  await Hive.initFlutter();
  await Hive.openBox('userBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
      },
    );
  }
}
