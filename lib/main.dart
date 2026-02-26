import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_wrapper.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'services/profile_completion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize profile completion service
  final profileService = ProfileCompletionService();
  await profileService.initialize();

  // Initialize app state provider
  await initializeAppState();

  // Initialize auth notifier
  await initializeAuthNotifier();
  
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateNotifier>.value(
          value: appStateProvider,
        ),
        ChangeNotifierProvider<AuthNotifier>.value(
          value: authNotifier,
        ),
      ],
      child: MaterialApp(
        title: 'RESQ Mobile',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
