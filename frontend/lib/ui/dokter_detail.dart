import 'package:flutter/material.dart';
import '../model/dokter.dart';
import 'dokter_update_form.dart';
import 'dokter_antrian_page.dart';
import 'doctor_schedule_page.dart';
import '../service/dokter_service.dart';
import '../helpers/user_info.dart';

class DokterDetail extends StatefulWidget {
  final Dokter dokter;
  final int index;

  const DokterDetail({super.key, required this.dokter, required this.index});

  @override
  State<DokterDetail> createState() => _DokterDetailState();
}

class _DokterDetailState extends State<DokterDetail> {
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _redDanger = const Color(0xFFE57373);
  final Color _indigoLink = const Color(0xFF3949AB);

  bool _canEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initRole();
  }

  Future<void> _initRole() async {
    final role = await UserInfo.getRole();
    if (!mounted) return;
    setState(() {
      _canEdit = role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Profil Dokter", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card Profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: _primaryTeal.withOpacity(0.1),
                    child: Icon(Icons.medical_services_rounded, size: 45, color: _primaryTeal),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.dokter.nama,
                    style: const TextStyle(
                      fontFamily: 'Tahoma', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      widget.dokter.namaPoli ?? "Poli Umum",
                      style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Dashboard Operasional (Jadwal & Antrian)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Operasional", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildActionButton("Jadwal Praktik", Icons.calendar_month, () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => DoctorSchedulePage(dokterId: widget.dokter.id)));
                      })),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionButton("Antrian Pasien", Icons.people_alt, () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => DokterAntrianPage(dokter: widget.dokter)));
                      })),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Card Detail Data
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _itemDetail(Icons.badge, "NIP", widget.dokter.nip),
                  const Divider(height: 24),
                  _itemDetail(Icons.phone_android, "Telepon", widget.dokter.nomorTelepon),
                  const Divider(height: 24),
                  _itemDetail(Icons.email, "Email", widget.dokter.email ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Admin Only)
            if (_canEdit)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goldAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      label: const Text("Ubah", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      onPressed: () async {
                        final hasil = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DokterUpdateForm(dokter: widget.dokter)),
                        );
                        if (hasil != null && mounted) Navigator.pop(context, hasil);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _redDanger,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                      label: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _indigoLink.withOpacity(0.1),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, color: _indigoLink),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: _indigoLink, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
        ],
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
      ],
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Dokter", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _redDanger),
            onPressed: () async {
              Navigator.pop(context);
              final success = await DokterService().delete(widget.dokter.id!);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context, 'hapus');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus')));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}