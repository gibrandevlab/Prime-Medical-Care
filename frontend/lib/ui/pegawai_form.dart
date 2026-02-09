import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class PegawaiForm extends StatefulWidget {
  const PegawaiForm({super.key});

  @override
  State<PegawaiForm> createState() => _PegawaiFormState();
}

class _PegawaiFormState extends State<PegawaiForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _tglCtrl = TextEditingController(); // Tanggal Lahir
  final _telpCtrl = TextEditingController(); // Nomor Telepon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Tambah Pegawai",
          style: TextStyle(fontFamily: 'Tahoma'),
        ),
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
                label: "Nama Pegawai",
                controller: _namaCtrl,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "NIP",
                controller: _nipCtrl,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              // Field Tanggal Lahir (Read Only + DatePicker)
              CustomTextField(
                label: "Tanggal Lahir (YYYY-MM-DD)",
                controller: _tglCtrl,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickTanggal,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Nomor Telepon",
                controller: _telpCtrl,
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
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
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      final pegawai = Pegawai(
        nama: _namaCtrl.text,
        nip: _nipCtrl.text,
        tanggalLahir: _tglCtrl.text,
        nomorTelepon: _telpCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        final created = await PegawaiService().add(pegawai);
        if (created != null && mounted) {
          Navigator.pop(context, created);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan data pegawai')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        }
      }
    }
  }
}
