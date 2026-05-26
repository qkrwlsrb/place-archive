// [Presentation Layer] — 앱 루트, Provider 설정 및 인증 기반 라우팅 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'application/view_models/auth_view_model.dart';
import 'application/view_models/capsule_view_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/capsule_repository.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/theme/app_theme.dart';

class PlaceArchiveApp extends StatelessWidget {
  const PlaceArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CapsuleViewModel(CapsuleRepository()),
        ),
      ],
      child: MaterialApp(
        title: '장소 기억 아카이브',
        theme: AppTheme.light,
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// 인증 상태에 따라 로그인 화면 / 지도 화면을 자동으로 전환
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthViewModel>().status;

    switch (status) {
      case AuthStatus.initial:
        // Firebase 초기화 중 스플래시
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return const MapScreen();
      default:
        return const LoginScreen();
    }
  }
}
