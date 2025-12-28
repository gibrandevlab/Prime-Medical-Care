import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import 'pegawai_update_form.dart';
import '../service/pegawai_service.dart';
import '../helpers/user_info.dart';

class PegawaiDetail extends StatefulWidget {
  final Pegawai pegawai;
  final int index;

  const PegawaiDetail({super.key, required this.pegawai, required this.index});

  @override
  State<PegawaiDetail> createState() => _PegawaiDetailState();
}

class _PegawaiDetailState extends State<PegawaiDetail> {
  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text(
          "Profil Pegawai",
          style: TextStyle(fontFamily: 'Tahoma'),
        ),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card Utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: _primaryTeal.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      size: 45,
                      color: _primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.pegawai.nama,
                    style: const TextStyle(
                      fontFamily: 'Tahoma',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "NIP: ${widget.pegawai.nip}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Detail Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _itemDetail(Icons.calendar_today_rounded, "Tanggal Lahir", widget.pegawai.tanggalLahir),
                  const Divider(height: 24),
                  _itemDetail(Icons.phone_rounded, "Telepon", widget.pegawai.nomorTelepon),
                  const Divider(height: 24),
                  _itemDetail(Icons.email_rounded, "Email", widget.pegawai.email),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Aksi
            if (_canEdit)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldAccent, // Gold
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
                          builder: (context) => PegawaiUpdateForm(pegawai: widget.pegawai),
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
                      backgroundColor: _redDanger, // Soft Red
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

  Widget _itemDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryTeal, size: 20),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
        ),
      ],
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Pegawai", style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus data pegawai ini? Data yang dihapus tidak dapat dikembalikan."),
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
              final success = await PegawaiService().delete(widget.pegawai.id!);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context, 'hapus');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus data pegawai')),
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