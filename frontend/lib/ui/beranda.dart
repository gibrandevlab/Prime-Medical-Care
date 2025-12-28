import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
import 'poli_page.dart';
import 'pegawai_page.dart';
import 'pasien_page.dart';
import 'dokter_page.dart';
import 'antrian_page.dart';
import 'approval_page.dart'; 
import 'rating_page.dart'; 
import 'pasien_dashboard.dart';
import '../helpers/user_info.dart';
import '../service/antrian_service.dart';
import '../service/pasien_service.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});
  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  String? _role;
  String? _username;
  bool _isLoading = true;

  // Palette
  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final role = await UserInfo.getRole();
    final user = await UserInfo.getUsername(); // Asumsi ada method getUsername
    if (mounted) {
      setState(() {
        _role = role;
        _username = user ?? "User";
        _isLoading = false;
      });
      _loadStats(); // Fetch stats data
      
      // Redirect pasien to their dashboard
      if (role == 'pasien' && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const PasienDashboard()),
          );
        });
      }
    }
  }

  // Stats Data
  int _stat1 = 0;
  int _stat2 = 0;
  String _label1 = "Stat 1";
  String _label2 = "Stat 2";

  Future<void> _loadStats() async {
    if (_role == 'pasien') return;

    try {
      if (_role == 'dokter') {
         // Dokter: Antrian Saya, Selesai
         _label1 = "Antrian Saya";
         _label2 = "Selesai";
         final uid = await UserInfo.getUserID();
         if (uid != null) {
            final list = await AntrianService().getByDokter(int.parse(uid));
            if (mounted) {
              setState(() {
                 _stat1 = list.where((x) => x.status == 'Menunggu' || x.status == 'Dipanggil').length;
                 _stat2 = list.where((x) => x.status == 'Selesai').length;
              });
            }
         }
      } else if (_role == 'petugas') {
         // Petugas: Antrian Pending, Total Pasien
         _label1 = "Antrian Pending";
         _label2 = "Total Pasien";
         final antrian = await AntrianService().getAntrian();
         final pasien = await PasienService().getAll();
         if (mounted) {
            setState(() {
               _stat1 = antrian.where((x) => x.status == 'Menunggu').length;
               _stat2 = pasien.length;
            });
         }
      } else if (_role == 'admin') {
         // Admin: Antrian Hari Ini, Total Pegawai/Dokter? Spec: "Pending Approval"
         _label1 = "Antrian Hari Ini";
         _label2 = "User"; // Placeholder for Pending Approval if service missing
         
         final antrian = await AntrianService().getAntrian();
         // Filter today
         final now = DateTime.now();
         final todayCount = antrian.length; // Simplified for now, filtering date requires parsing
         
         if (mounted) setState(() {
            _stat1 = todayCount;
            _stat2 = 0; // Approval service implementation pending
         });
      }
    } catch (e) {
       print("Failed to load stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgLight,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgLight,
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Klinik Utama", style: TextStyle(fontFamily: 'Tahoma', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: _primaryTeal,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Welcome Section
          Text(
            "Selamat Datang, ${_username ?? '...'}",
            style: const TextStyle(
              fontFamily: 'Tahoma',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Anda login sebagai: ${_role?.toUpperCase() ?? '...'}",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),

          const SizedBox(height: 32),

          // STATS CARDS
          if (_role != 'pasien')
            _buildStatsRow(),
          if (_role != 'pasien')
            const SizedBox(height: 24),

          // MENU GRID
          _buildFilteredGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(_label1, _stat1.toString(), Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(_label2, _stat2.toString(), Colors.blue)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFilteredGrid() {
    List<Widget> cards = [];

    // Role-based Menu Logic from Spec
    if (_role == 'dokter') {
       cards.add(_buildMenuCard("Antrian Saya", Icons.assignment_ind_rounded, const AntrianPage()));
       cards.add(_buildMenuCard("Data Pasien", Icons.person_outline_rounded, const PasienPage()));
       cards.add(_buildMenuCard("Rating Layanan", Icons.star_rounded, const RatingPage()));
    } 
    else if (_role == 'petugas') {
       cards.add(_buildMenuCard("Antrian Pasien", Icons.confirmation_number_rounded, const AntrianPage()));
       cards.add(_buildMenuCard("Data Pasien", Icons.person_outline_rounded, const PasienPage()));
       cards.add(_buildMenuCard("Data Poli", Icons.local_hospital_rounded, const PoliPage()));
       cards.add(_buildMenuCard("Rating Layanan", Icons.star_rounded, const RatingPage()));
    }
    else if (_role == 'admin') {
       cards.add(_buildMenuCard("Antrian Pasien", Icons.confirmation_number_rounded, const AntrianPage()));
       cards.add(_buildMenuCard("Data Pasien", Icons.person_outline_rounded, const PasienPage()));
       cards.add(_buildMenuCard("Data Poli", Icons.local_hospital_rounded, const PoliPage()));
       cards.add(_buildMenuCard("Data Dokter", Icons.medical_services_rounded, const DokterPage()));
       cards.add(_buildMenuCard("Data Pegawai", Icons.people_alt_rounded, const PegawaiPage()));
       cards.add(_buildMenuCard("Approval", Icons.verified_user_rounded, const ApprovalPage()));
       cards.add(_buildMenuCard("Rating Layanan", Icons.star_rounded, const RatingPage()));
    }

    return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: cards,
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Widget page) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: _primaryTeal),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Tahoma',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
