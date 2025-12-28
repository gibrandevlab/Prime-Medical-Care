import 'package:flutter/material.dart';
import '../model/dokter.dart';
import '../widget/sidebar.dart';
import 'dokter_item.dart';
import 'dokter_form.dart';
import 'dokter_detail.dart';
import '../service/dokter_service.dart';
import '../helpers/user_info.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  final DokterService _service = DokterService();
  late Future<List<Dokter>> _futureDokter;

  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _goldAccent = const Color(0xFFD4AF37);

  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

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

  void _load() {
    setState(() {
      _futureDokter = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          "Data Dokter",
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
      floatingActionButton: _canEdit
          ? FloatingActionButton.extended(
              backgroundColor: _goldAccent,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DokterForm()),
                );
                if (result != null) _load();
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: const Text(
                "Tambah Dokter",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tahoma',
                ),
              ),
            )
          : null,
      body: FutureBuilder<List<Dokter>>(
        future: _futureDokter,
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
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data dokter",
                style: TextStyle(color: Colors.grey, fontFamily: 'Tahoma'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final dokter = list[index];
              return DokterItem(
                dokter: dokter,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DokterDetail(dokter: dokter, index: index),
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