import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../widget/sidebar.dart';
import 'pasien_item.dart';
import 'pasien_form.dart';
import 'pasien_detail.dart';
import '../service/pasien_service.dart';
import '../helpers/user_info.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({super.key});

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  final PasienService _service = PasienService();
  late Future<List<Pasien>> _futurePasien;

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
      _canEdit = role == 'admin' || role == 'petugas';
    });
  }

  void _load() {
    setState(() {
      _futurePasien = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          "Data Pasien",
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
                  MaterialPageRoute(builder: (context) => const PasienForm()),
                );
                if (result != null) _load();
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: const Text(
                "Pasien Baru",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tahoma',
                ),
              ),
            )
          : null,
      body: FutureBuilder<List<Pasien>>(
        future: _futurePasien,
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
                "Belum ada data pasien",
                style: TextStyle(color: Colors.grey, fontFamily: 'Tahoma'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final pasien = list[index];
              return PasienItem(
                pasien: pasien,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasienDetail(pasien: pasien, index: index),
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