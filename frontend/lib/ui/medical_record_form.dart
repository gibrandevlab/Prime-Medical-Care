import 'package:flutter/material.dart';
import '../service/medical_record_service.dart';

class MedicalRecordForm extends StatefulWidget {
  final int pasienId;
  final int? dokterId;
  final int? poliId;
  final int? antrianId;

  const MedicalRecordForm({
    super.key,
    required this.pasienId,
    this.dokterId,
    this.poliId,
    this.antrianId,
  });

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _anamnesaCtl = TextEditingController();
  final _diagnosaCtl = TextEditingController();
  final _tindakanCtl = TextEditingController();
  final _resepCtl = TextEditingController();
  final _svc = MedicalRecordService();
  bool _saving = false;

  @override
  void dispose() {
    _anamnesaCtl.dispose();
    _diagnosaCtl.dispose();
    _tindakanCtl.dispose();
    _resepCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final payload = {
      'pasienId': widget.pasienId,
      if (widget.dokterId != null) 'dokterId': widget.dokterId,
      if (widget.poliId != null) 'poliId': widget.poliId,
      if (widget.antrianId != null) 'antrianId': widget.antrianId,
      'anamnesa': _anamnesaCtl.text.trim(),
      'diagnosa': _diagnosaCtl.text.trim(),
      'tindakan': _tindakanCtl.text.trim(),
      'resep': _resepCtl.text.trim(),
      'visitDate': DateTime.now().toIso8601String(),
    };

    final created = await _svc.create(payload);
    setState(() => _saving = false);
    if (created != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rekam medis tersimpan')));
        Navigator.pop(context, created);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan rekam medis')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Rekam Medis')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _anamnesaCtl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Anamnesa'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Isi anamnesa' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosaCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Diagnosa'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tindakanCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Tindakan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resepCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Resep'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
