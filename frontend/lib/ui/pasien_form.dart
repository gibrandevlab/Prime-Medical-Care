import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';

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
              
              CustomTextField(
                label: "NIK (16 digit)",
                controller: _nikCtrl,
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'NIK wajib diisi';
                  if (value.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Nama Lengkap",
                controller: _namaCtrl,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Tanggal Lahir (YYYY-MM-DD)",
                controller: _tglLahirCtrl,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickTanggal,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Nomor Telepon",
                controller: _telpCtrl,
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Alamat",
                controller: _alamatCtrl,
                icon: Icons.home_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Email",
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Password",
                controller: _passwordCtrl,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 30),
              PrimaryButton(
                text: "Simpan Data",
                onPressed: _simpan,
              ),
            ],
          ),
        ),
      ),
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
