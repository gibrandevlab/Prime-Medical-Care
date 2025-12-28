import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../service/dokter_service.dart';

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

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

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
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Ubah Data Dokter", style: TextStyle(fontFamily: 'Tahoma')),
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
              _buildField("NIP", _nipCtrl, icon: Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildField("Nama Dokter", _namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildField("ID Poli", _poliCtrl, icon: Icons.local_hospital_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField("Nomor Telepon", _telpCtrl, icon: Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField("Email", _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField("Password", _passwordCtrl, icon: Icons.lock_outline, obscureText: true, isRequired: false),
              
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

  Widget _buildField(String label, TextEditingController controller, {
    IconData? icon, 
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
      ),
      validator: (value) {
        if (!isRequired) return null;
        return (value == null || value.isEmpty) ? '$label wajib diisi' : null;
      },
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