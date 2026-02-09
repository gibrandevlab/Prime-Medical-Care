import 'package:flutter/material.dart';
import '../model/dokter.dart';
import 'dokter_update_form.dart';
import 'dokter_antrian_page.dart';
import 'doctor_schedule_page.dart';
import '../service/dokter_service.dart';
import '../helpers/user_info.dart';
import '../helpers/app_theme.dart';
import '../widget/detail_row.dart';
import '../widget/card_container.dart';
import '../widget/section_header.dart';

class DokterDetail extends StatefulWidget {
  final Dokter dokter;
  final int index;

  const DokterDetail({super.key, required this.dokter, required this.index});

  @override
  State<DokterDetail> createState() => _DokterDetailState();
}

class _DokterDetailState extends State<DokterDetail> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profil Dokter", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card Profil
            CardContainer(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.medical_services_rounded, size: 45, color: AppColors.primary),
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
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      widget.dokter.namaPoli ?? "Poli Umum",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Dashboard Operasional (Jadwal & Antrian)
            CardContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Operasional"),
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
            CardContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DetailRow(icon: Icons.badge, label: "NIP", value: widget.dokter.nip),
                  const Divider(height: 24),
                  DetailRow(icon: Icons.phone_android, label: "Telepon", value: widget.dokter.nomorTelepon),
                  const Divider(height: 24),
                  DetailRow(icon: Icons.email, label: "Email", value: widget.dokter.email ?? '-', isLast: true),
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
