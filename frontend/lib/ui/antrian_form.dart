import 'package:flutter/material.dart';
import '../service/antrian_service.dart';
import '../service/pasien_service.dart';
import '../service/poli_service.dart';
import '../service/dokter_service.dart';
import '../model/pasien.dart';
import '../model/poli.dart';
import '../model/dokter.dart';
import '../model/antrian.dart';

class AntrianForm extends StatefulWidget {
  const AntrianForm({super.key});
  @override
  State<AntrianForm> createState() => _AntrianFormState();
}

class _AntrianFormState extends State<AntrianForm> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanCtrl = TextEditingController();
  
  // Services
  final _antrianSvc = AntrianService();
  final _pasienSvc = PasienService();
  final _poliSvc = PoliService();
  final _dokterSvc = DokterService();

  // Data Source
  List<Pasien> _pasiens = [];
  List<Poli> _polis = [];
  List<Dokter> _dokters = [];
  List<Dokter> _filteredDokters = [];

  // Selections
  int? _selectedPasien;
  int? _selectedPoli;
  int? _selectedDokter;

  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await _pasienSvc.getAll();
    final pl = await _poliSvc.getAll();
    final d = await _dokterSvc.getAll();
    setState(() {
      _pasiens = p;
      _polis = pl;
      _dokters = d;
    });
  }

  void _onPoliChanged(int? poliId) {
    setState(() {
      _selectedPoli = poliId;
      _selectedDokter = null; // Reset dokter
      if (poliId != null) {
        _filteredDokters = _dokters.where((doc) => doc.poliId == poliId).toList();
      } else {
        _filteredDokters = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Daftar Antrian Baru", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown Pasien
              _buildDropdown<int>(
                label: "Pilih Pasien",
                value: _selectedPasien,
                items: _pasiens.map((e) => DropdownMenuItem(value: e.id, child: Text("${e.nama} (RM: ${e.nomorRm})"))).toList(),
                onChanged: (val) => setState(() => _selectedPasien = val),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              // Dropdown Poli
              _buildDropdown<int>(
                label: "Pilih Poli Tujuan",
                value: _selectedPoli,
                items: _polis.map((e) => DropdownMenuItem(value: e.id, child: Text(e.namaPoli))).toList(),
                onChanged: _onPoliChanged,
                icon: Icons.local_hospital_outlined,
              ),
              const SizedBox(height: 16),

              // Dropdown Dokter (Filtered)
              _buildDropdown<int>(
                label: "Pilih Dokter (Opsional)",
                value: _selectedDokter,
                items: _filteredDokters.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nama))).toList(),
                onChanged: (val) => setState(() => _selectedDokter = val),
                icon: Icons.medical_services_outlined,
                enabled: _selectedPoli != null,
              ),
              const SizedBox(height: 16),

              // Keluhan
              TextFormField(
                controller: _keluhanCtrl,
                maxLines: 3,
                cursorColor: _primaryTeal,
                decoration: InputDecoration(
                  labelText: "Keluhan Utama",
                  prefixIcon: Icon(Icons.note_alt_outlined, color: _primaryTeal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v!.isEmpty ? "Keluhan wajib diisi" : null,
              ),

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
                onPressed: _submit,
                child: const Text("DAFTAR ANTRIAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Tahoma')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label, 
    required T? value, 
    required List<DropdownMenuItem<T>> items, 
    required ValueChanged<T?> onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? _primaryTeal : Colors.grey),
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
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      validator: (v) => v == null ? "$label wajib dipilih" : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation: Ensure pasien and poli are selected
    if (_selectedPasien == null || _selectedPoli == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasien dan Poli wajib dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final antrian = AntrianModel(
      pasienId: _selectedPasien!, // Safe after validation
      poliId: _selectedPoli!, // Safe after validation
      dokterId: _selectedDokter,
      keluhan: _keluhanCtrl.text,
      status: 'Menunggu',
    );

    try {
      // Convert to JSON before sending to service
      await _antrianSvc.create(antrian.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antrian berhasil didaftarkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}