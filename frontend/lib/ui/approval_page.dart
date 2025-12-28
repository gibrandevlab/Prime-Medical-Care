import 'package:flutter/material.dart';
import '../service/schedule_service.dart';
import '../helpers/user_info.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});
  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final _scheduleSvc = ScheduleService();
  List<dynamic> _requests = [];
  bool _loading = true;

  final Color _primaryTeal = const Color(0xFF00695C);
  final Color _bgLight = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    final requests = await _scheduleSvc.getPendingRequests();
    if (mounted) {
      setState(() {
        _requests = requests;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: Text("Approval Jadwal (${_requests.length})", style: const TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: _primaryTeal,
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _primaryTeal))
          : _requests.isEmpty
              ? const Center(child: Text("Tidak ada permintaan pending.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dokter: ${req['dokter_name'] ?? 'Unknown'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(height: 20),
                            _infoRow("Tanggal", req['date']),
                            if (req['start_time'] != null && req['end_time'] != null)
                               _infoRow("Jam", "${req['start_time']} - ${req['end_time']}"),
                            if (req['substitute_name'] != null)
                               _infoRow("Pengganti", req['substitute_name']),
                            _infoRow("Alasan", req['reason'] ?? '-'),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _handleApproval(req['id'], false),
                                    icon: const Icon(Icons.close),
                                    label: const Text("Tolak"),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryTeal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _handleApproval(req['id'], true),
                                    icon: const Icon(Icons.check),
                                    label: const Text("Setujui"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _handleApproval(int requestId, bool approved) async {
    final adminId = await UserInfo.getUserID();
    if (adminId == null) return;
    
    // Perhatikan: Sesuaikan parameter ID admin jika service membutuhkan int/string
    final success = await _scheduleSvc.approveOverride(requestId, approved, int.parse(adminId.toString()));
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(approved ? "Jadwal disetujui" : "Jadwal ditolak"),
        backgroundColor: approved ? Colors.green : Colors.red,
      ));
      _loadRequests();
    }
  }
}