import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../model/poli.dart';
import '../service/dokter_service.dart';
import '../service/poli_service.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../helpers/app_theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tambah Dokter", style: TextStyle(fontFamily: 'Tahoma')),
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
              
              // Poli Dropdown (Manual styling to match CustomTextField)
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
                  prefixIcon: const Icon(Icons.local_hospital_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val == null ? 'Poli wajib dipilih' : null,
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
