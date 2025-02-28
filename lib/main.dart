import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/themes/app_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 可在此添加全局状态管理Provider
      ],
      child: MaterialApp(
        title: '词根记忆法',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const OnboardingPage(),
      ),
    );
  }
}