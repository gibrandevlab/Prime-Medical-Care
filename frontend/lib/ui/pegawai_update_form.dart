import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class PegawaiUpdateForm extends StatefulWidget {
  final Pegawai pegawai;
  const PegawaiUpdateForm({super.key, required this.pegawai});

  @override
  State<PegawaiUpdateForm> createState() => _PegawaiUpdateFormState();
}

class _PegawaiUpdateFormState extends State<PegawaiUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaCtrl.text = widget.pegawai.nama;
    _nipCtrl.text = widget.pegawai.nip;
    _emailCtrl.text = widget.pegawai.email ?? '';
    _tglCtrl.text = widget.pegawai.tanggalLahir;
    _telpCtrl.text = widget.pegawai.nomorTelepon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Ubah Data Pegawai",
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Tanggal Lahir",
                controller: _tglCtrl,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickTanggal,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Email",
                controller: _emailCtrl,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Password (kosongi jika tidak diubah)",
                controller: _passwordCtrl,
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  // password optional on update
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Konfirmasi Password",
                controller: _confirmCtrl,
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  // validation handled in _simpanPerubahan for comparison
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Nomor Telepon",
                controller: _telpCtrl,
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
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

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordCtrl.text.isNotEmpty &&
          _passwordCtrl.text != _confirmCtrl.text) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password dan konfirmasi tidak sama')),
          );
        return;
      }
      final pegawaiBaru = Pegawai(
        id: widget.pegawai.id, // Pertahankan ID lama
        nama: _namaCtrl.text,
        nip: _nipCtrl.text,
        tanggalLahir: _tglCtrl.text,
        nomorTelepon: _telpCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        final updated = await PegawaiService().update(
          pegawaiBaru,
          pegawaiBaru.id!,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui data pegawai')),
          );
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nipCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _tglCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    DateTime? initial;
    try {
      if (_tglCtrl.text.isNotEmpty) initial = DateTime.parse(_tglCtrl.text);
    } catch (_) {}
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null)
      _tglCtrl.text = picked.toIso8601String().split('T').first;
  }
}
