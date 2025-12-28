import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';

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

  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text(
          "Tambah Pegawai",
          style: TextStyle(fontFamily: 'Tahoma'),
        ),
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
              _buildField("Nama Pegawai", _namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildField("NIP", _nipCtrl, icon: Icons.badge_outlined),
              const SizedBox(height: 16),
              // Field Tanggal Lahir (Read Only + DatePicker)
              _buildField("Tanggal Lahir (YYYY-MM-DD)", _tglCtrl, 
                icon: Icons.calendar_today_outlined, 
                readOnly: true,
                onTap: _pickTanggal
              ),
              const SizedBox(height: 16),
              _buildField("Nomor Telepon", _telpCtrl, icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone),
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

  // Widget Helper untuk Input Field Konsisten
  Widget _buildField(String label, TextEditingController controller, {
    IconData? icon, 
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
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
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
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
            colorScheme: ColorScheme.light(primary: _primaryTeal),
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