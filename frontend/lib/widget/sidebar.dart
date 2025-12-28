import 'package:flutter/material.dart';
import '../ui/beranda.dart';
import '../ui/poli_page.dart';
import '../ui/antrian_page.dart';
import '../ui/pegawai_page.dart';
import '../ui/pasien_page.dart';
import '../ui/dokter_page.dart';
import '../ui/login.dart';
import '../ui/pasien_dashboard.dart';
import '../ui/pasien_antrian_page.dart';
import '../helpers/user_info.dart';
import '../service/dokter_service.dart';
import '../model/dokter.dart';
import '../ui/dokter_antrian_page.dart';
import '../ui/doctor_schedule_page.dart';
import '../ui/approval_page.dart';
import '../ui/leave_request_page.dart';
import '../helpers/app_theme.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _role;
  String _userName = "Memuat...";
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await UserInfo.getRole();
    String name = "Memuat...";
    String email = "";
    final userId = await UserInfo.getUserID();
    
    // Default name based on role if not found
    if (role == 'admin') name = "Administrator";
    if (role == 'petugas') name = "Petugas";

    if (role == 'dokter' && userId != null) {
      try {
        final ds = DokterService();
        final d = await ds.getById(int.parse(userId));
        if (d != null) {
          name = d.nama;
          email = d.email ?? '';
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _role = role;
        _userName = name;
        _userEmail = email;
      });
    }
  }

  Future<void> _signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await UserInfo.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Role checks
    final isAdmin = _role == 'admin';
    final isPetugas = _role == 'petugas';
    final isDokter = _role == 'dokter';

    return Drawer(
      backgroundColor: AppColors.background, // Dark Sidebar
      child: Column(
        children: [
          _buildPremiumHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _PremiumMenuItem(
                  icon: Icons.dashboard_rounded,
                  title: "Beranda",
                  onTap: () {
                    if (_role == 'pasien') {
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const PasienDashboard()));
                    } else {
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const Beranda()));
                    }
                  },
                ),

                // SECTION: OPERASIONAL (Admin & Petugas)
                if (isAdmin || isPetugas) ...[
                  _buildSectionLabel("OPERASIONAL KLINIK"),
                  _PremiumMenuItem(
                    icon: Icons.personal_injury_rounded,
                    title: "Pendaftaran Pasien",
                    routeName: '/pasien',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const PasienPage(), settings: const RouteSettings(name: '/pasien'))),
                  ),
                   _PremiumMenuItem(
                    icon: Icons.monitor_heart_rounded,
                    title: "Monitor Antrian",
                    routeName: '/antrian',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const AntrianPage(), settings: const RouteSettings(name: '/antrian'))),
                  ),
                   _PremiumMenuItem(
                    icon: Icons.calendar_month_rounded, 
                    title: "Jadwal Dokter",
                    routeName: '/jadwal',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const DoctorSchedulePage(), settings: const RouteSettings(name: '/jadwal'))),
                  ),
                ],

                // SECTION: DATA MASTER (Admin & Petugas)
                if (isAdmin || isPetugas) ...[
                  _buildSectionLabel("DATA MASTER"),
                   _PremiumMenuItem(
                    icon: Icons.local_hospital_rounded,
                    title: "Katalog Poli",
                    routeName: '/poli',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const PoliPage(), settings: const RouteSettings(name: '/poli'))),
                  ),
                   _PremiumMenuItem(
                    icon: Icons.medical_services_rounded,
                    title: "Direktori Dokter",
                    routeName: '/dokter',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const DokterPage(), settings: const RouteSettings(name: '/dokter'))),
                  ),
                ],

                // SECTION: ADMINISTRASI SDM (Admin Only)
                if (isAdmin) ...[
                  _buildSectionLabel("ADMINISTRASI SDM"),
                  _PremiumMenuItem(
                    icon: Icons.people_alt_rounded,
                    title: "Data Pegawai",
                    routeName: '/pegawai',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const PegawaiPage(), settings: const RouteSettings(name: '/pegawai'))),
                  ),
                  _PremiumMenuItem(
                    icon: Icons.fact_check_rounded, // Improved Icon
                    title: "Persetujuan Jadwal",
                    routeName: '/approval',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const ApprovalPage(), settings: const RouteSettings(name: '/approval'))),
                  ),
                ],

                // SECTION: AREA DOKTER (Dokter Only)
                if (isDokter) ...[
                  _buildSectionLabel("AREA DOKTER"),
                   _PremiumMenuItem(
                    icon: Icons.assignment_ind_rounded,
                    title: "Daftar Antrian",
                    routeName: '/antrian', 
                    onTap: () {
                         Navigator.pop(context); // Close drawer
                         Navigator.pushReplacement( // Replace current page
                            context, 
                            MaterialPageRoute(builder: (c) => const AntrianPage(), settings: const RouteSettings(name: '/antrian'))
                         );
                    },
                  ),
                  _PremiumMenuItem(
                    icon: Icons.calendar_today_rounded,
                    title: "Jadwal Praktik",
                    routeName: '/dokter/jadwal',
                    onTap: () async {
                      final idStr = await UserInfo.getUserID();
                      if (idStr != null && mounted) {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (c) => DoctorSchedulePage(dokterId: int.tryParse(idStr)),
                            settings: const RouteSettings(name: '/dokter/jadwal'),
                          ),
                        );
                      }
                    },
                  ),
                  _PremiumMenuItem(
                    icon: Icons.beach_access_rounded,
                    title: "Ajukan Cuti",
                    routeName: '/dokter/cuti',
                    onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (c) => const LeaveRequestPage(), settings: const RouteSettings(name: '/dokter/cuti'))
                        );
                    },
                  ),
                  // Read Only Access for Info
                  _PremiumMenuItem(
                    icon: Icons.person_search_rounded,
                    title: "Cari Pasien",
                    routeName: '/pasien',
                    onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (c) => const PasienPage(), settings: const RouteSettings(name: '/pasien'))
                        );
                    },
                  ),
                ],

                // SECTION: AREA PASIEN (Pasien Only)
                if (_role == 'pasien') ...[
                  _buildSectionLabel("AREA PASIEN"),
                  // Dashboard removed (Already covered by Beranda)
                  _PremiumMenuItem(
                  _PremiumMenuItem(
                    icon: Icons.queue_rounded,
                    title: "Antrian Saya",
                    routeName: '/pasien/antrian',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (c) => const PasienAntrianPage(), settings: const RouteSettings(name: '/pasien/antrian'))),
                  ),
                ],

                const Divider(color: Colors.white10, height: 40),

                _PremiumMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Keluar",
                  isDanger: true,
                  onTap: _signOut,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Prime Care v1.0",
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.background],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
        boxShadow: [
           BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5)
           )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 30, color: AppColors.background),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? "Loading...", // Changed from _userName
                  style: const TextStyle(
                    color: Colors.white, // Always White on Gradient
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma'
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (_role ?? '').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent, // Gold accent
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;
  final String? routeName;

  const _PremiumMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
    this.routeName,
  });

  @override
  State<_PremiumMenuItem> createState() => _PremiumMenuItemState();
}

class _PremiumMenuItemState extends State<_PremiumMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Check Active State
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = widget.routeName != null && currentRoute == widget.routeName;

    Color iconColor = widget.isDanger
        ? AppColors.danger
        : (isActive ? AppColors.accent : AppColors.textSecondary);
        
    Color textColor = widget.isDanger 
        ? AppColors.danger 
        : (isActive ? AppColors.accent : AppColors.textOnBg); // TextOnBg (White)

    if (_isPressed) {
      iconColor = widget.isDanger ? AppColors.danger : AppColors.accent;
      textColor = AppColors.accent;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive || _isPressed ? AppColors.surface.withOpacity(0.1) : Colors.transparent, // White transparency
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: (isActive || _isPressed) ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Tahoma'
                ),
              ),
            ),
            if (isActive || (_isPressed && !widget.isDanger))
               const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 12)
          ],
        ),
      ),
    );
  }
}
