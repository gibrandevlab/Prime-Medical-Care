import 'package:flutter/material.dart';
import '../model/poli.dart';
import 'poli_item.dart';
import 'poli_form.dart';
import 'poli_detail.dart';
import '../widget/sidebar.dart';
import '../service/poli_service.dart';
import '../helpers/user_info.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});
  @override
  State<PoliPage> createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage> {
  final PoliService _service = PoliService();
  late Future<List<Poli>> _futurePoli;

  final Color _primaryTeal = const Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _load();
  }

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

  void _load() {
    setState(() {
      _futurePoli = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background abu muda
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          "Data Poli",
          style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryTeal,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      floatingActionButton: _canEdit
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFD4AF37),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PoliForm()),
                );
                if (result != null) _load();
              },
              icon: const Icon(Icons.add_business_rounded, color: Colors.white),
              label: const Text(
                "Tambah Poli",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: FutureBuilder<List<Poli>>(
        future: _futurePoli,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: _primaryTeal),
            );
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
                "Belum ada data poli",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final poli = list[index];
              return PoliItem(
                poli: poli,
                onTap: () async {
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PoliDetail(poli: poli, index: index),
                    ),
                  );
                  if (hasil != null) _load();
                },
              );
            },
          );
        },
      ),
    );
  }
}
