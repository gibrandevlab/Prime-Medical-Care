import 'package:flutter/material.dart';
import '../service/schedule_service.dart';
import '../helpers/user_info.dart';
import '../widget/sidebar.dart';
import '../helpers/app_theme.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> with SingleTickerProviderStateMixin {
  final _scheduleSvc = ScheduleService();
  late TabController _tabCtrl;
  
  List<dynamic> _requests = [];
  bool _loading = true;
  String? _userRole;
  int? _userId;

  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _substitutes = [];
  int? _selectedSubstituteId;
  bool _loadingSubstitutes = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _userRole = await UserInfo.getRole();
    final idStr = await UserInfo.getUserID();
    _userId = idStr != null ? int.tryParse(idStr) : null;
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    // For Admin: Get Pending Requests
    // For Doctor: Get Overrides (filtered for their own leaves)
    
    try {
      if (_userRole == 'admin') {
         final list = await _scheduleSvc.getPendingRequests();
         if (mounted) setState(() => _requests = list);
      } else if (_userId != null) {
         final list = await _scheduleSvc.getOverrides(_userId!);
         // Filter to only show 'Pending' or 'Rejected' or Leaves (is_available = false)
         // But logic might differ. For now, let's show all overrides that are NOT 'Available' or have specific notes
         final leaves = list.where((item) => item['is_available'] == false || item['is_available'] == 0 || item['status'] == 'Pending').toList();
         if (mounted) setState(() => _requests = leaves);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
         if (didPop) return;
         Navigator.pushReplacementNamed(context, '/'); // Back to Home
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const Sidebar(), // Add Drawer
        appBar: AppBar(
          title: const Text("Pengajuan Cuti / Jadwal", style: TextStyle(fontFamily: 'Tahoma')),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "Daftar Pengajuan"),
              Tab(text: "Buat Pengajuan"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildList(),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_requests.isEmpty) return const Center(child: Text("Belum ada data pengajuan"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (ctx, i) {
        final item = _requests[i];
        final status = item['status'] ?? 'Pending';
        final isPending = status == 'Pending';
        // Handle variations in field names depending on endpoint (getPending vs getOverrides)
        final requester = item['Requester'];
        final dokterName = requester?['Dokter']?['nama'] ?? requester?['nama'] ?? item['dokter_name'] ?? '-';
        final note = item['note'] ?? '-';
        final start = item['start_date'] ?? item['date'];
        final end = item['end_date'] ?? item['date'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dokter: $dokterName", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _statusColor(status)),
                      ),
                      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Tanggal: $start s/d $end"),
                Text("Alasan: $note"),
                
                if (_userRole == 'admin' && isPending) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _approve(item['id'], false),
                        child: const Text("Tolak", style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () => _approve(item['id'], true),
                        child: const Text("Setujui", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _loadSubstitutes() async {
    if (_startDate == null || _userId == null) return;
    
    setState(() => _loadingSubstitutes = true);
    try {
        final dateStr = _startDate!.toIso8601String().split('T')[0];
        final list = await _scheduleSvc.getAvailableSubstitutes(_userId!, dateStr);
        if (mounted) {
            setState(() {
                _substitutes = list;
                // Reset selection if not in list
                if (_selectedSubstituteId != null && !list.any((d) => d['id'] == _selectedSubstituteId)) {
                    _selectedSubstituteId = null;
                }
            });
        }
    } finally {
        if (mounted) setState(() => _loadingSubstitutes = false);
    }
  }

  Widget _buildForm() {
    if (_userRole != 'dokter') {
      return const Center(child: Text("Hanya Dokter yang dapat membuat pengajuan cuti disini. Admin harap gunakan menu Override Jadwal."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Form Pengajuan Cuti / Libur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            ListTile(
              title: Text(_startDate == null ? "Pilih Tanggal Mulai" : "Mulai: ${_startDate.toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.grey)),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (date != null) {
                    setState(() => _startDate = date);
                    _loadSubstitutes();
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(_endDate == null ? "Pilih Tanggal Selesai" : "Selesai: ${_endDate.toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.grey)),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: _startDate ?? DateTime.now(), lastDate: DateTime(2030));
                if (date != null) setState(() => _endDate = date);
              },
            ),
            const SizedBox(height: 12),
            
            // Substitute Doctor Dropdown
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Dokter Pengganti (Opsional)",
                border: const OutlineInputBorder(),
                suffixIcon: _loadingSubstitutes ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              ),
              value: _selectedSubstituteId,
              items: [
                const DropdownMenuItem<int>(value: null, child: Text("Tidak ada pengganti")),
                ..._substitutes.map((d) => DropdownMenuItem<int>(
                  value: d['id'], 
                  child: Text("${d['nama']} (${d['schedule'] != null ? 'Available' : 'N/A'})")
                )).toList(),
              ],
              onChanged: (val) => setState(() => _selectedSubstituteId = val),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: "Alasan", border: OutlineInputBorder()),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white
              ),
              onPressed: _submit,
              child: const Text("AJUKAN"),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'Approved') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal mulai")));
        return;
      }
      
      final res = await _scheduleSvc.requestOverride(
        dokterId: _userId!,
        startDate: _startDate!.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
        isAvailable: false,
        note: _reasonCtrl.text,
        substituteDokterId: _selectedSubstituteId,
      );

      // Check for 'id' or 'message' to confirm success, API returns object on success
      if (res['id'] != null || (res['message'] != null && !res.containsKey('error'))) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengajuan berhasil dikirim"), backgroundColor: Colors.green));
           _reasonCtrl.clear();
           setState(() {
             _startDate = null;
             _endDate = null;
             _selectedSubstituteId = null;
             _substitutes = [];
           });
           _tabCtrl.animateTo(0);
           _loadRequests();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${res['message'] ?? 'Error'}")));
      }
    }
  }

  Future<void> _approve(int id, bool approved) async {
     // Assuming admin ID is handled by backend or auth service
     // But requestOverride expects adminId. Let's fetch it.
     final adminId = await UserInfo.getUserID();
     if(adminId == null) return;

     final success = await _scheduleSvc.approveOverride(id, approved, int.parse(adminId));
     if (success) {
       _loadRequests();
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approved ? "Disetujui" : "Ditolak")));
     }
  }
}
