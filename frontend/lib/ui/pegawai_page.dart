import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../widget/sidebar.dart';
import 'pegawai_item.dart';
import 'pegawai_form.dart';
import 'pegawai_detail.dart';
import '../service/pegawai_service.dart';
import '../helpers/user_info.dart';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  State<PegawaiPage> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  final PegawaiService _service = PegawaiService();
  late Future<List<Pegawai>> _futurePegawai;
  bool _isAdmin = false;

  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _goldAccent = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _checkRole();
    _load();
  }

  Future<void> _checkRole() async {
    final role = await UserInfo.getRole();
    if (mounted) setState(() => _isAdmin = role == 'admin');
  }

  void _load() {
    setState(() {
      _futurePegawai = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          "Data Pegawai",
          style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryTeal,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      floatingActionButton: !_isAdmin ? null : FloatingActionButton.extended(
        backgroundColor: _goldAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PegawaiForm()),
          );
          if (result != null) _load();
        },
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          "Tambah Pegawai",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tahoma',
          ),
        ),
      ),
      body: FutureBuilder<List<Pegawai>>(
        future: _futurePegawai,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryTeal));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data pegawai",
                style: TextStyle(color: Colors.grey, fontFamily: 'Tahoma'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final pegawai = list[index];
              return PegawaiItem(
                pegawai: pegawai,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PegawaiDetail(pegawai: pegawai, index: index),
                    ),
                  );
                  if (result != null) _load();
                },
              );
            },
          );
        },
      ),
    );
  }
}