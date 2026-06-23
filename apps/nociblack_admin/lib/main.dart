import 'package:flutter/material.dart';

import 'core/config/app_environment.dart';
import 'core/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromEnvironment();
  await const SupabaseInitializer().initialize(environment);

  runApp(const NociBlackAdminApp());
}

class NociBlackAdminApp extends StatelessWidget {
  const NociBlackAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NociBlacK Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.black)),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('NociBlacK Admin'),
      ),
      body: const Center(child: Text('NociBlacK Admin')),
    );
  }
}
