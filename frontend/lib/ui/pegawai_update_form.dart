import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';

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

  final Color _primaryTeal = const Color(0xFF00695C);

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
      appBar: AppBar(
        title: const Text(
          "Ubah Data Pegawai",
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
              _buildField("Nama Pegawai", _namaCtrl, Icons.person_outline),
              _buildField(
                "NIP",
                _nipCtrl,
                Icons.badge_outlined,
                isNumber: true,
              ),
              _buildField(
                "Tanggal Lahir",
                _tglCtrl,
                Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickTanggal,
              ),
              _buildField("Email", _emailCtrl, Icons.email_outlined),
              _buildPasswordField(
                "Password (kosongi jika tidak diubah)",
                _passwordCtrl,
              ),
              _buildPasswordField("Konfirmasi Password", _confirmCtrl),
              _buildField(
                "Nomor Telepon",
                _telpCtrl,
                Icons.phone_android_outlined,
                isNumber: true,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: _simpanPerubahan,
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primaryTeal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: _primaryTeal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          // password optional on update
          return null;
        },
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
