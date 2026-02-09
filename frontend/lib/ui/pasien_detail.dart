import 'package:flutter/material.dart';
import '../model/pasien.dart';
import 'pasien_update_form.dart';
import 'medical_record_page.dart';
import 'medical_record_form.dart';
import '../service/pasien_service.dart';
import '../helpers/user_info.dart';
import '../helpers/app_theme.dart';
import '../widget/card_container.dart';
import '../widget/detail_row.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;
  final int index;

  const PasienDetail({super.key, required this.pasien, required this.index});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  final _service = PasienService();
  final Color _indigoMedical = const Color(0xFF3949AB);
  bool _canEdit = false;
  bool _canDelete = false;

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
      _canDelete = role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detail Pasien",
          style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: (!_canEdit) 
          ? FloatingActionButton.extended(
              backgroundColor: _indigoMedical,
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: const Text("Buat Rekam Medis", style: TextStyle(color: Colors.white)),
              onPressed: () async {
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // --- KARTU INFORMASI UTAMA ---
            _buildInfoCard(),

            const SizedBox(height: 24),

            // --- TOMBOL REKAM MEDIS ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigoMedical,
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
                      builder: (context) =>
                          MedicalRecordPage(pasienId: widget.pasien.id!),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            if (_canEdit)
              Row(
                children: [
                  Expanded(
                    flex: _canDelete ? 1 : 2,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return CardContainer(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, size: 45, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
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
          
          DetailRow(icon: Icons.calendar_today_rounded, label: "Tanggal Lahir", value: widget.pasien.tanggalLahir),
          const SizedBox(height: 16),
          DetailRow(icon: Icons.phone_rounded, label: "Telepon", value: widget.pasien.nomorTelepon),
          const SizedBox(height: 16),
          DetailRow(icon: Icons.location_on_rounded, label: "Alamat", value: widget.pasien.alamat),
          if (widget.pasien.email != null && widget.pasien.email!.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(top: 16),
               child: DetailRow(icon: Icons.email_outlined, label: "Email", value: widget.pasien.email!),
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
                Navigator.pop(context);
                Navigator.pop(context, 'hapus');
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
