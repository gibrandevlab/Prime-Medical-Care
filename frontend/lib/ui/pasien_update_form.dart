import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class PasienUpdateForm extends StatefulWidget {
  final Pasien pasien;
  const PasienUpdateForm({super.key, required this.pasien});

  @override
  State<PasienUpdateForm> createState() => _PasienUpdateFormState();
}

class _PasienUpdateFormState extends State<PasienUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaCtrl = TextEditingController();
  final _rmCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaCtrl.text = widget.pasien.nama;
    _rmCtrl.text = widget.pasien.nomorRm;
    _nikCtrl.text = widget.pasien.nik;
    _alamatCtrl.text = widget.pasien.alamat;
    _emailCtrl.text = widget.pasien.email ?? '';
    _tglLahirCtrl.text = widget.pasien.tanggalLahir;
    _telpCtrl.text = widget.pasien.nomorTelepon;
    _passwordCtrl.text = widget.pasien.password ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ubah Data Pasien", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: AppColors.primary,
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
              CustomTextField(
                label: "Nomor RM",
                controller: _rmCtrl,
                icon: Icons.credit_card,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "NIK (16 digit)",
                controller: _nikCtrl,
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
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
                label: "Tanggal Lahir",
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
                validator: (value) => null, // Optional on update
              ),
              
              const SizedBox(height: 30),
              PrimaryButton(
                text: "Simpan Perubahan",
                onPressed: _simpanPerubahan,
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
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
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

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      final pasienBaru = Pasien(
        id: widget.pasien.id,
        nomorRm: _rmCtrl.text,
        nik: _nikCtrl.text,
        nama: _namaCtrl.text,
        tanggalLahir: _tglLahirCtrl.text,
        nomorTelepon: _telpCtrl.text,
        alamat: _alamatCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        final result = await PasienService().update(pasienBaru, pasienBaru.id!);
        if (mounted) {
          if (result != null) {
            Navigator.pop(context, result);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Gagal update data pasien")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
        }
      }
    }
  }
}
