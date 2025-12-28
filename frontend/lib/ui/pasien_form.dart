import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';

class PasienForm extends StatefulWidget {
  const PasienForm({super.key});

  @override
  State<PasienForm> createState() => _PasienFormState();
}

class _PasienFormState extends State<PasienForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController(); // NIK field
  final _alamatCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Registrasi Pasien", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card about auto-generated RM
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nomor RM akan dibuat otomatis oleh sistem',
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildField("NIK (16 digit)", _nikCtrl, 
                icon: Icons.badge_outlined, 
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              _buildField("Nama Lengkap", _namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildField("Tanggal Lahir (YYYY-MM-DD)", _tglLahirCtrl, 
                icon: Icons.calendar_today_outlined, 
                readOnly: true, 
                onTap: _pickTanggal
              ),
              const SizedBox(height: 16),
              _buildField("Nomor Telepon", _telpCtrl, icon: Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField("Alamat", _alamatCtrl, icon: Icons.home_outlined, maxLines: 2),
              const SizedBox(height: 16),
              _buildField("Email", _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField("Password", _passwordCtrl, icon: Icons.lock_outline, obscureText: true),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: _primaryTeal.withOpacity(0.4),
                ),
                onPressed: _simpan,
                child: const Text(
                  "SIMPAN DATA", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Tahoma')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {
    IconData? icon, 
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: _primaryTeal,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: icon != null ? Icon(icon, color: _primaryTeal) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryTeal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        counterText: '', // Hide character counter
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label wajib diisi';
        }
        // NIK validation
        if (label.contains('NIK') && value.length != 16) {
          return 'NIK harus 16 digit';
        }
        return null;
      },
    );
  }

  Future<void> _pickTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: _primaryTeal)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLahirCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      final pasien = Pasien(
        nomorRm: '', // Will be auto-generated by backend
        nik: _nikCtrl.text,
        nama: _namaCtrl.text,
        tanggalLahir: _tglLahirCtrl.text,
        nomorTelepon: _telpCtrl.text,
        alamat: _alamatCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        final result = await PasienService().add(pasien);
        if (mounted && result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pasien berhasil didaftarkan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, result);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mendaftar pasien: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
