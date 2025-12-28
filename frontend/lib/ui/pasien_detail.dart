import 'package:flutter/material.dart';
import '../model/pasien.dart';
import 'pasien_update_form.dart';
import 'medical_record_page.dart';
import 'medical_record_form.dart'; // <--- Tambahan
import '../service/pasien_service.dart';
import '../helpers/user_info.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;
  final int index;

  const PasienDetail({super.key, required this.pasien, required this.index});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  final _service = PasienService();
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _indigoMedical = const Color(0xFF3949AB); // Warna khusus medis
  bool _canEdit = false;
  bool _canDelete = false; // Only admin can delete

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initRole();
  }

  Future<void> _initRole() async {
    final role = await UserInfo.getRole();
    if (!mounted) return;
    setState(() {
      _canEdit = role == 'admin' || role == 'petugas';
      _canDelete = role == 'admin'; // Only admin can delete
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Detail Pasien",
          style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      // FAB KHUSUS DOKTER
      floatingActionButton: (_canEdit == false) // Asumsi: jika bukan admin/petugas, mungkin dokter
          ? FloatingActionButton.extended(
              backgroundColor: _indigoMedical,
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: const Text("Buat Rekam Medis", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                 // Butuh ID Dokter dll. Idealnya ambil dari UserInfo
                 final dokId = await UserInfo.getUserID();
                 if (dokId != null && mounted) {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (ctx) => MedicalRecordForm(
                       pasienId: widget.pasien.id!,
                       dokterId: int.tryParse(dokId),
                     ))
                   );
                 }
              },
            )
          : null,
      body: SingleChildScrollView(
        // ScrollView wajib agar tidak error di HP kecil
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // --- KARTU INFORMASI UTAMA ---
            _buildInfoCard(),

            const SizedBox(height: 24),

            // --- TOMBOL REKAM MEDIS (HIGHLIGHT) ---
            // Dibuat full width agar menonjol dan tidak sempit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigoMedical, // Warna beda biar kontras
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _indigoMedical.withOpacity(0.4),
                ),
                icon: const Icon(Icons.history_edu_rounded, size: 28),
                label: const Text(
                  "LIHAT REKAM MEDIS",
                  style: TextStyle(
                    fontFamily: 'Tahoma',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pastikan ID dikirim dengan aman
                      builder: (context) =>
                          MedicalRecordPage(pasienId: widget.pasien.id!),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            if (_canEdit)
              // --- TOMBOL ADMIN/PETUGAS (UBAH) & ADMIN ONLY (HAPUS) ---
              Row(
                children: [
                  Expanded(
                    flex: _canDelete ? 1 : 2, // Full width if no delete button
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37), // Gold
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text(
                        "Ubah Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PasienUpdateForm(pasien: widget.pasien),
                          ),
                        );
                        if (result != null && mounted) {
                          Navigator.pop(context, result);
                        }
                      },
                    ),
                  ),
                  if (_canDelete) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373), // Soft Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.delete_forever_rounded),
                        label: const Text(
                          "Hapus",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _konfirmasiHapus(context),
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 40), // Ruang kosong bawah
          ],
        ),
      ),
    );
  }

  // Widget Terpisah untuk Kartu Info agar Rapi
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Besar
          CircleAvatar(
            radius: 40,
            backgroundColor: _primaryTeal.withOpacity(0.1),
            child: Icon(Icons.person_rounded, size: 45, color: _primaryTeal),
          ),
          const SizedBox(height: 16),
          // Nama & RM
          Text(
            widget.pasien.nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              fontFamily: 'Tahoma',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "No. RM: ${widget.pasien.nomorRm}",
              style: const TextStyle(
                color: Color(0xFF8D6E03),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          // Detail Data
          _buildInfoRow(
            Icons.calendar_today_rounded,
            "Tanggal Lahir",
            widget.pasien.tanggalLahir,
          ),
          _buildInfoRow(
            Icons.phone_rounded,
            "Telepon",
            widget.pasien.nomorTelepon,
          ),
          _buildInfoRow(
            Icons.location_on_rounded,
            "Alamat",
            widget.pasien.alamat,
          ),
          // Jika ada email
          if (widget.pasien.email != null && widget.pasien.email!.isNotEmpty)
            _buildInfoRow(Icons.email_outlined, "Email", widget.pasien.email!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: _primaryTeal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Pasien?"),
        content: const Text("Data rekam medis ini akan dihapus permanen."),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
            ),
            onPressed: () async {
              await _service.delete(widget.pasien.id!);
              if (context.mounted) {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context, 'hapus'); // Kembali ke list
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
