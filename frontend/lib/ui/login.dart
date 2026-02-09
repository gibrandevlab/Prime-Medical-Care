import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../helpers/user_info.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import 'beranda.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  
  bool _loading = false;
  
  // Controller untuk animasi
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Palet Warna Premium (Sama seperti Beranda)
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _darkTeal = const Color(0xFF004D40);

  @override
  void initState() {
    super.initState();
    // Setup Animasi Masuk
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _tryLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final resp = await dioClient.post(
        '/auth/login',
        data: {'email': _emailCtrl.text.trim(), 'password': _passwordCtrl.text},
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data ?? {};
        final token = data['token'] as String?;
        final role = data['role'] as String?;
        final pegawaiId = data['pegawaiId'];
        final dokterId = data['dokterId'];
        final pasienId = data['pasienId'];
        final user = data['user'] as Map<String, dynamic>?;

        if (token != null) await UserInfo.setToken(token);
        if (role != null) await UserInfo.setRole(role);
        
        // Save user name from response
        if (user != null && user['nama'] != null) {
          await UserInfo.setUserName(user['nama'].toString());
        }

        try {
          if (dokterId != null) {
            await UserInfo.setUserID(dokterId.toString());
          } else if (pegawaiId != null) {
            await UserInfo.setUserID(pegawaiId.toString());
          } else if (pasienId != null) {
            await UserInfo.setUserID(pasienId.toString());
          }
        } catch (_) {}

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Beranda()),
        );
        return;
      }
    } on DioException catch (e) {
      String message = 'Login gagal';
      if (e.response != null && e.response?.data != null) {
        final d = e.response?.data;
        if (d is Map && d['message'] != null)
          message = d['message'].toString();
        else if (d is String)
          message = d;
      }

      if (!mounted) return;
      _showErrorSnackBar(message);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Terjadi kesalahan server');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryTeal, _darkTeal],
              ),
            ),
          ),
          
          // 2. Dekorasi Lingkaran Pemanis
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. Konten Utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- LOGO / ICON ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.local_hospital_rounded,
                          size: 60,
                          color: _primaryTeal,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      const Text(
                        "Prime Care Medical",
                        style: TextStyle(
                          fontFamily: 'Tahoma',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        "Sistem Manajemen Klinik Terpadu",
                        style: TextStyle(
                          fontFamily: 'Tahoma',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- FORM CARD ---
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat Datang",
                                style: TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Silakan masuk ke akun Anda",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 30),

                              // Input Email
                              CustomTextField(
                                controller: _emailCtrl,
                                label: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                                  if (!v.contains('@')) return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),

                              // Input Password
                              CustomTextField(
                                controller: _passwordCtrl,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 30),

                              // Tombol Login
                              PrimaryButton(
                                text: "Masuk Sekarang",
                                isLoading: _loading,
                                onPressed: _tryLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        "v1.0.0 • Prime Care Team",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
