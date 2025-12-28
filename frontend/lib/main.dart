import 'package:flutter/material.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/login.dart';
import 'helpers/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await UserInfo.getToken();
  runApp(PrimeCareApp(token: token));
}

class PrimeCareApp extends StatelessWidget {
  final String? token;

  const PrimeCareApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prime Care Medical',
      theme: AppTheme.lightTheme,
      home: token != null ? const Beranda() : const LoginPage(),
    );
  }
}
