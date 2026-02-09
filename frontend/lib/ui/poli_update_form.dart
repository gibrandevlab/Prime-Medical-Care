import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

class PoliUpdateForm extends StatefulWidget {
  final Poli poli;
  const PoliUpdateForm({super.key, required this.poli});

  @override
  State<PoliUpdateForm> createState() => _PoliUpdateFormState();
}

class _PoliUpdateFormState extends State<PoliUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _namaPoliCtrl.text = widget.poli.namaPoli;
    _keteranganCtrl.text = widget.poli.keterangan ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ubah Data Poli", style: TextStyle(fontFamily: 'Tahoma')),
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
                icon: Icons.edit_location_alt_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Keterangan",
                controller: _keteranganCtrl,
                maxLines: 3,
                validator: (value) => null, // Optional
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
      final poliBaru = Poli(
        id: widget.poli.id,
        namaPoli: _namaPoliCtrl.text,
        keterangan: _keteranganCtrl.text.isEmpty ? null : _keteranganCtrl.text,
      );
      try {
        await PoliService().update(poliBaru, poliBaru.id!);
        if (mounted) Navigator.pop(context, poliBaru);
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
        }
      }
    }
  }
}
