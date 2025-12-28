import 'package:flutter/material.dart';
import '../model/poli.dart';
import 'poli_update_form.dart';
import '../service/poli_service.dart';
import '../helpers/user_info.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;
  final int index;

  const PoliDetail({super.key, required this.poli, required this.index});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  final Color _primaryTeal = const Color(0xFF00695C);
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
      _canEdit = role == 'admin'; // Only admin can CRUD poli
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Detail Poli",
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
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _primaryTeal.withOpacity(0.1),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 40,
                      color: _primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 8),
                  const Text(
                    "Poliklinik Layanan Utama",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (widget.poli.keterangan != null && widget.poli.keterangan!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryTeal.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Keterangan:", style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTeal)),
                          const SizedBox(height: 4),
                          Text(widget.poli.keterangan!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Aksi (hanya untuk admin/petugas)
            if (_canEdit)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37), // Gold
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text(
                        "Ubah",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final hasilUbah = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoliUpdateForm(poli: widget.poli),
                          ),
                        );
                        if (hasilUbah != null && mounted) {
                          Navigator.pop(context, hasilUbah);
                        }
                      },
                    ),
                  ),
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
                      ),
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      label: const Text(
                        "Hapus",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Poli"),
        content: const Text("Apakah Anda yakin ingin menghapus poli ini?"),
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
