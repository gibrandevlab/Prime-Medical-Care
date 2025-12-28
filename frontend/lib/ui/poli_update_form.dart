import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';

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
  
  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _namaPoliCtrl.text = widget.poli.namaPoli;
    _keteranganCtrl.text = widget.poli.keterangan ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Ubah Data Poli", style: TextStyle(fontFamily: 'Tahoma')),
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
              _buildField("Nama Poli", _namaPoliCtrl),
              const SizedBox(height: 16),
              _buildField("Keterangan", _keteranganCtrl, maxLines: 3),
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
                onPressed: _simpanPerubahan,
                child: const Text(
                  "SIMPAN PERUBAHAN", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Tahoma')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: _primaryTeal,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: maxLines == 1 ? Icon(Icons.edit_location_alt_outlined, color: _primaryTeal) : null,
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
      ),
      validator: (value) => (value == null || value.isEmpty) && label == "Nama Poli" ? '$label wajib diisi' : null,
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