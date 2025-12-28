import 'dart:async';
import 'package:flutter/material.dart';
import '../service/antrian_service.dart';
import '../model/antrian.dart';
import 'antrian_form.dart';
import '../widget/sidebar.dart';
import '../helpers/user_info.dart';
import 'medical_record_form.dart';
import 'medical_record_page.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({super.key});
  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final AntrianService _service = AntrianService();
  late Future<List<AntrianModel>> _future;
  Timer? _timer;
  bool _isPasien = false;
  bool _isDokter = false;
  int? _dokterId;

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _goldAccent = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _checkRole();
    // Initialize _future directly without setState (widget just created)
    _future = _service.getAntrian();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  Future<void> _checkRole() async {
    final role = await UserInfo.getRole();
    final uid = await UserInfo.getUserID();
    if (mounted) {
      setState(() {
        _isPasien = role == 'pasien';
        _isDokter = role == 'dokter';
        if (_isDokter && uid != null) _dokterId = int.tryParse(uid);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _load() {
    // Correct pattern: Call service outside setState, assign result inside
    Future<List<AntrianModel>> data;
    if (_isDokter && _dokterId != null) {
       data = _service.getByDokter(_dokterId!);
    } else {
       data = _service.getAntrian();
    }
    
    if (mounted) {
      setState(() {
        _future = data;
      });
    }
  }

  Future<void> _handleTap(AntrianModel item) async {
    if (!_isDokter || item.id == null) return;
    
    // Auto-update status to 'Dipanggil' if 'Menunggu'
    if (item.status == 'Menunggu' && item.id != null) {
      try {
        await _service.updateStatus(item.id!, 'Dipanggil');
      } catch (e) {
        // Ignore error, proceed to page
        print("Gagal update status: $e");
      }
    }

    // Open Medical Record Page (History + Add)
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (c) => MedicalRecordPage(
         pasienId: item.pasienId,
         dokterId: _dokterId, 
         poliId: item.poliId,
         antrianId: item.id
      ))
    );
    
    // Always reload to reflect status changes
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _isDokter ? Colors.indigo : _primaryTeal;
    final title = _isDokter ? "Antrian Pasien Saya" : "Manajemen Antrian";

    return Scaffold(
      backgroundColor: _bgLight,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: headerColor,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      floatingActionButton: _isDokter 
        ? null 
        : FloatingActionButton.extended(
            backgroundColor: _goldAccent,
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (c) => const AntrianForm()));
              _load();
            },
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            label: const Text("Daftar Antrian", style: TextStyle(color: Colors.white, fontFamily: 'Tahoma', fontWeight: FontWeight.bold)),
          ),
      body: FutureBuilder<List<AntrianModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: _primaryTeal));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada antrian.", style: TextStyle(color: Colors.grey, fontFamily: 'Tahoma')));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  onTap: () => _handleTap(item),
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: _primaryTeal.withOpacity(0.1),
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  title: Text(
                    item.namaPasien ?? "Pasien #${item.pasienId}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tahoma'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Poli: ${item.namaPoli ?? '-'}"),
                      const SizedBox(height: 4),
                      Text("Nomor Antrian: ${item.ticketNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (item.keluhan != null) Text("Keluhan: ${item.keluhan}", maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      _statusBadge(item.status),
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

  Widget _statusBadge(String? status) {
    // Normalize status to lowercase for comparison
    final normalizedStatus = (status ?? 'Menunggu').toLowerCase();
    
    Color color;
    String displayText = status ?? 'Menunggu';
    
    switch (normalizedStatus) {
      case 'selesai':
        color = Colors.green;
        break;
      case 'dipanggil':
        color = Colors.blue;
        break;
      case 'batal':
        color = Colors.red;
        break;
      case 'menunggu':
      default:
        color = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayText.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}