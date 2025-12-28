import 'package:flutter/material.dart';
import '../service/schedule_service.dart';
import '../service/dokter_service.dart';
import '../model/dokter.dart';
import '../helpers/user_info.dart';
import '../widget/sidebar.dart';
import '../helpers/app_theme.dart';

class DoctorSchedulePage extends StatefulWidget {
  final int? dokterId; 
  const DoctorSchedulePage({super.key, this.dokterId});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> with SingleTickerProviderStateMixin {
  final _scheduleSvc = ScheduleService();
  final _dokterSvc = DokterService();
  
  late TabController _tabController;
  List<Dokter> _dokters = [];
  int? _selectedDokterId;
  
  List<dynamic> _baseSchedules = [];
  List<dynamic> _overrides = [];
  bool _loading = true;

  // Palette removed, using AppTheme
  // final Color _primaryTeal = const Color(0xFF00695C);
  // final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDokterId = widget.dokterId;
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (_selectedDokterId == null) {
      final role = await UserInfo.getRole();
      if (role == 'admin') {
        final d = await _dokterSvc.getAll();
        setState(() => _dokters = d);
      }
    } else {
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    if (_selectedDokterId == null) return;
    setState(() => _loading = true);
    try {
      final response = await _scheduleSvc.getSchedules(_selectedDokterId!);
      final ovr = await _scheduleSvc.getOverrides(_selectedDokterId!);
      setState(() {
        // Fix: Extract 'base' array from response Map
        _baseSchedules = (response['base'] ?? []) as List<dynamic>;
        _overrides = ovr;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
         if (didPop) return;
         // Back button goes to Home (Beranda)
         Navigator.pushReplacementNamed(context, '/'); 
      },
      child: Scaffold(
        backgroundColor: AppColors.background, // Standard BG
        drawer: const Sidebar(), // Added Drawer for burger menu
        floatingActionButton: _isRoleAdmin() ? FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: AppColors.accent, // Use Accent
          onPressed: _showAddOverrideDialog,
        ) : null,
        appBar: AppBar(
          title: const Text("Jadwal Praktik", style: TextStyle(fontFamily: 'Tahoma')),
          backgroundColor: AppColors.primary, // Standard Primary
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Jadwal Rutin", icon: Icon(Icons.calendar_today)),
              Tab(text: "Jadwal Khusus", icon: Icon(Icons.event_note)),
            ],
          ),
        ),
        body: Column(
          children: [
            if (widget.dokterId == null && _dokters.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Pilih Dokter",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: _selectedDokterId,
                  items: _dokters.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nama))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedDokterId = val);
                    _loadSchedule();
                  },
                ),
              ),
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBaseList(),
                      _buildOverrideList(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseList() {
    if (_baseSchedules.isEmpty) {
      return Center(child: Text("Tidak ada jadwal rutin", style: TextStyle(color: Colors.grey[600])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _baseSchedules.length,
      itemBuilder: (ctx, i) {
        final item = _baseSchedules[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.access_time_filled, color: AppColors.primary),
            ),
            title: Text("Hari: ${_dayName(item['day_of_week'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${item['start_time']} - ${item['end_time']}"),
          ),
        );
      },
    );
  }

  Widget _buildOverrideList() {
    if (_overrides.isEmpty) {
      return Center(child: Text("Tidak ada jadwal khusus/cuti", style: TextStyle(color: Colors.grey[600])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _overrides.length,
      itemBuilder: (ctx, i) {
        final item = _overrides[i];
        final isAvailable = item['is_available'] == 1 || item['is_available'] == true;
        final start = item['start_date'] ?? item['date'];
        final end = item['end_date'] ?? item['date'];
        final note = item['note'] ?? '-';
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAvailable ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.block,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
            title: Text("$start s/d $end", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(isAvailable 
                        ? "Masuk: ${item['start_time'] ?? '00:00'} - ${item['end_time'] ?? '00:00'}" 
                        : "CUTI / TIDAK PRAKTIK"),
                    Text("Catatan: $note", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]
            ),
            trailing: _isRoleAdmin() ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _deleteOverride(item['id']),
            ) : null,
          ),
        );
      },
    );
  }

  Future<void> _deleteOverride(int id) async {
     // Implementasi delete logic disini
     await _scheduleSvc.deleteOverride(id);
     _loadSchedule();
  }

  String _dayName(dynamic day) {
    if (day == null) return '-';
    // Mapping 1 (Monday) - 7 (Sunday) or 0 (Sunday) - 6 (Saturday)
    // Assuming backend sends ISO info (1-7) or 0-6. Let's assume 1=Senin usually in this context or verify.
    // If integer: 
    int d = int.tryParse(day.toString()) ?? 0;
    const days = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"]; // 0-6
    // If backend uses 1=Senin, 7=Minggu.
    // Standard JS GetDay() is 0=Sunday.
    if (d >= 0 && d < 7) return days[d]; // 0=Minggu, 1=Senin...
    if (d == 7) return "Minggu";
    return day.toString();
  }

  bool _isRoleAdmin() {
    return _dokters.isNotEmpty; 
  }

  Future<void> _showAddOverrideDialog() async {
      if (_selectedDokterId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih dokter terlebih dahulu")));
          return;
      }
      
      final startDateCtrl = TextEditingController();
      final endDateCtrl = TextEditingController();
      final noteCtrl = TextEditingController();
      bool isAvailable = false;

      await showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
           title: const Text("Tambah Override Jadwal"),
           content: SingleChildScrollView( // Prevent overflow
            child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                   controller: startDateCtrl, 
                   decoration: const InputDecoration(labelText: "Tanggal Mulai (YYYY-MM-DD)"),
                   onTap: () async {
                       DateTime? picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                       if(picked != null) startDateCtrl.text = picked.toIso8601String().split('T')[0];
                   }
               ),
               TextField(
                   controller: endDateCtrl, 
                   decoration: const InputDecoration(labelText: "Tanggal Selesai (Opsional)"),
                   onTap: () async {
                       DateTime? picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                       if(picked != null) endDateCtrl.text = picked.toIso8601String().split('T')[0];
                   }
               ),
               TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: "Catatan")),
               // Use StatefulBuilder for Checkbox inside Dialog
               StatefulBuilder(builder: (ctx, setStateInner) {
                   return CheckboxListTile(
                       title: const Text("Available (Masuk)"),
                       value: isAvailable,
                       onChanged: (v) => setStateInner(() => isAvailable = v ?? false)
                   );
               })
             ]
            )
           ),
           actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
               ElevatedButton(
                   onPressed: () async {
                       if(startDateCtrl.text.isEmpty) return;
                       await _scheduleSvc.addOverride(
                           dokterId: _selectedDokterId!,
                           startDate: startDateCtrl.text,
                           endDate: endDateCtrl.text.isEmpty ? null : endDateCtrl.text,
                           isAvailable: isAvailable,
                           note: noteCtrl.text
                       );
                       if (mounted) Navigator.pop(ctx);
                       _loadSchedule();
                   }, 
                   child: const Text("Simpan")
               )
           ]
        )
      );
  }
}