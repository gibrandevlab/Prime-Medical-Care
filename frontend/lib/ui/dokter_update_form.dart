import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../service/dokter_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class DokterUpdateForm extends StatefulWidget {
  final Dokter dokter;
  const DokterUpdateForm({super.key, required this.dokter});

  @override
  State<DokterUpdateForm> createState() => _DokterUpdateFormState();
}

class _DokterUpdateFormState extends State<DokterUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nipCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _poliCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nipCtrl.text = widget.dokter.nip;
    _namaCtrl.text = widget.dokter.nama;
    _emailCtrl.text = widget.dokter.email ?? '';
    _poliCtrl.text = widget.dokter.poliId?.toString() ?? '';
    _telpCtrl.text = widget.dokter.nomorTelepon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ubah Data Dokter", style: TextStyle(fontFamily: 'Tahoma')),
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
                label: "NIP",
                controller: _nipCtrl,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Nama Dokter",
                controller: _namaCtrl,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "ID Poli",
                controller: _poliCtrl,
                icon: Icons.local_hospital_outlined,
                keyboardType: TextInputType.number,
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
                validator: (value) {
                  // Not required for update
                  return null;
                },
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
      final dokterBaru = Dokter(
        id: widget.dokter.id,
        nip: _nipCtrl.text,
        nama: _namaCtrl.text,
        poliId: int.tryParse(_poliCtrl.text) ?? widget.dokter.poliId,
        namaPoli: widget.dokter.namaPoli,
        nomorTelepon: _telpCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        await DokterService().update(dokterBaru, dokterBaru.id!);
        if (mounted) Navigator.pop(context, dokterBaru);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
        }
      }
    }
  }
}
 