import 'package:flutter/material.dart';
import '../model/poli.dart';
import 'poli_update_form.dart';
import '../service/poli_service.dart';
import '../helpers/user_info.dart';
import '../helpers/app_theme.dart';
import '../widget/card_container.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;
  final int index;

  const PoliDetail({super.key, required this.poli, required this.index});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  // Palette
  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _redDanger = const Color(0xFFE57373);
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await UserInfo.getRole();
    if (mounted) setState(() => _canEdit = role == 'admin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detail Poli",
          style: TextStyle(fontFamily: 'Tahoma'),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main Info Card
            CardContainer(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.poli.namaPoli,
                    style: const TextStyle(
                      fontFamily: 'Tahoma',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (_canEdit)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text(
                      "Ubah",
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tahoma'),
                    ),
                    onPressed: () async {
                      final hasil = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoliUpdateForm(poli: widget.poli),
                        ),
                      );
                      if (hasil != null && mounted) {
                        Navigator.pop(context, hasil);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _redDanger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text(
                      "Hapus",
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tahoma'),
                    ),
                    onPressed: () => _konfirmasiHapus(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Poli", style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus poli ini? Data tidak dapat dikembalikan."),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redDanger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await PoliService().delete(widget.poli.id!);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context, 'hapus');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus data poli')),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
