import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../model/poli.dart';
import '../service/dokter_service.dart';
import '../service/poli_service.dart';

class DokterForm extends StatefulWidget {
  const DokterForm({super.key});
  @override
  State<DokterForm> createState() => _DokterFormState();
}

class _DokterFormState extends State<DokterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nipCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  
  // Poli Dropdown State
  List<Poli> _poliList = [];
  int? _selectedPoliId;
  bool _isLoadingPoli = true;

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadPoliData();
  }

  Future<void> _loadPoliData() async {
    try {
      final list = await PoliService().getAll();
      if (mounted) {
        setState(() {
          _poliList = list;
          _isLoadingPoli = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data Poli: $e')));
        setState(() => _isLoadingPoli = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Tambah Dokter", style: TextStyle(fontFamily: 'Tahoma')),
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
              
              // Poli Dropdown
              DropdownButtonFormField<int>(
                value: _selectedPoliId,
                items: _poliList.map((poli) {
                  return DropdownMenuItem<int>(
                    value: poli.id,
                    child: Text(poli.namaPoli, style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPoliId = val),
                 decoration: InputDecoration(
                  labelText: _isLoadingPoli ? "Memuat Poli..." : "Pilih Poli",
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  prefixIcon: Icon(Icons.local_hospital_outlined, color: _primaryTeal),
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
                validator: (val) => val == null ? 'Poli wajib dipilih' : null,
              ),

              const SizedBox(height: 16),
              _buildField("Nomor Telepon", _telpCtrl, icon: Icons.phone_android, keyboardType: TextInputType.phone),
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

  Widget _buildField(String label, TextEditingController controller, {
    IconData? icon, 
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
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
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPoliId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poli belum dipilih")));
        return;
      }
      
      final dokter = Dokter(
        nip: _nipCtrl.text,
        nama: _namaCtrl.text,
        poliId: _selectedPoliId!,
        namaPoli: "Poli", // Placeholder
        nomorTelepon: _telpCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      try {
        await DokterService().add(dokter);
        if (mounted) Navigator.pop(context, dokter);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
        }
      }
    }
  }
}
