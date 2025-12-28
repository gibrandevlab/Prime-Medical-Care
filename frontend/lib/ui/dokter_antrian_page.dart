import 'dart:async';
import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../model/antrian.dart';
import 'medical_record_page.dart';
import '../service/antrian_service.dart';

class DokterAntrianPage extends StatefulWidget {
  final Dokter dokter;
  const DokterAntrianPage({super.key, required this.dokter});

  @override
  State<DokterAntrianPage> createState() => _DokterAntrianPageState();
}

class _DokterAntrianPageState extends State<DokterAntrianPage> {
  final AntrianService _service = AntrianService();
  late Future<List<AntrianModel>> _future;
  Timer? _timer;

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _load() {
    if (mounted) {
      setState(() {
        _future = _service.getByDokter(widget.dokter.id ?? 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text("Antrian Pasien", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: _primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<AntrianModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: _primaryTeal));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Tidak ada antrian saat ini"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _primaryTeal,
                    foregroundColor: Colors.white,
                    child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    item.namaPasien ?? "Pasien #${item.pasienId}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Status: ${item.status?.toUpperCase() ?? '-'}", 
                        style: TextStyle(color: _getColorStatus(item.status), fontWeight: FontWeight.w600)
                      ),
                      Text("Keluhan: ${item.keluhan ?? '-'}", maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) async {
                      if (val == 'lihat') {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => MedicalRecordPage(pasienId: item.pasienId)));
                      } else {
                        // Update status logic here
                        // await _service.updateStatus(item.id, val);
                        _load();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'sedang', child: Text('Panggil / Sedang Periksa')),
                      const PopupMenuItem(value: 'selesai', child: Text('Selesai')),
                      const PopupMenuItem(value: 'batal', child: Text('Batalkan')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'lihat', child: Text('Lihat Rekam Medis')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorStatus(String? status) {
    switch (status) {
      case 'menunggu': return Colors.orange;
      case 'sedang': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'batal': return Colors.red;
      default: return Colors.grey;
    }
  }
}