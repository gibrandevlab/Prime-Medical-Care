import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class PoliForm extends StatefulWidget {
  const PoliForm({super.key});
  @override
  State<PoliForm> createState() => _PoliFormState();
}

class _PoliFormState extends State<PoliForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tambah Poli Baru", style: TextStyle(fontFamily: 'Tahoma')),
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
                label: "Nama Poli",
                controller: _namaPoliCtrl,
                icon: Icons.local_hospital_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Keterangan",
                controller: _keteranganCtrl,
                icon: Icons.notes_outlined,
                maxLines: 3,
                validator: (value) => null, // Keterangan optional
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

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      final poli = Poli(
        namaPoli: _namaPoliCtrl.text, 
        keterangan: _keteranganCtrl.text.isEmpty ? null : _keteranganCtrl.text
      );
      try {
        await PoliService().add(poli);
        if (mounted) Navigator.pop(context, poli);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
        }
      }
    }
  }
}
