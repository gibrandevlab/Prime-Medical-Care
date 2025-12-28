import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';

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

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

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
    _passwordCtrl.text = widget.pasien.password ?? ''; // Fix: Handle null password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Ubah Data Pasien", style: TextStyle(fontFamily: 'Tahoma')),
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
              _buildField("Nomor RM", _rmCtrl, icon: Icons.credit_card, readOnly: true),
              const SizedBox(height: 16),
              _buildField("NIK (16 digit)", _nikCtrl, icon: Icons.badge_outlined, keyboardType: TextInputType.number, maxLength: 16),
              const SizedBox(height: 16),
              _buildField("Nama Lengkap", _namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildField("Tanggal Lahir", _tglLahirCtrl, icon: Icons.calendar_today_outlined, readOnly: true, onTap: _pickTanggal),
              const SizedBox(height: 16),
              _buildField("Nomor Telepon", _telpCtrl, icon: Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField("Alamat", _alamatCtrl, icon: Icons.home_outlined, maxLines: 2),
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
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
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
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label wajib diisi';
        if (label.contains('NIK') && value.length != 16) return 'NIK harus 16 digit';
        return null;
      },
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
