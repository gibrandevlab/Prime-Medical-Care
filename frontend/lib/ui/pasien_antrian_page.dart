import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';
import '../service/antrian_service.dart';
import '../model/antrian.dart';
import '../helpers/user_info.dart';

class PasienAntrianPage extends StatefulWidget {
  const PasienAntrianPage({super.key});

  @override
  State<PasienAntrianPage> createState() => _PasienAntrianPageState();
}

class _PasienAntrianPageState extends State<PasienAntrianPage> {
  List<AntrianModel> _antrianList = [];
  bool _isLoading = true;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final antrianService = AntrianService();
      final list = await antrianService.getAll(status: _filterStatus);
      
      setState(() {
        _antrianList = list;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading antrian: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Dipanggil':
        return AppColors.accent;
      case 'Selesai':
        return AppColors.success;
      case 'Batal':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu':
        return Icons.hourglass_empty_rounded;
      case 'Dipanggil':
        return Icons.notifications_active_rounded;
      case 'Selesai':
        return Icons.check_circle_rounded;
      case 'Batal':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Antrian Saya', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'Semua' ? null : value;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Semua', child: Text('Semua Status')),
              const PopupMenuItem(value: 'Menunggu', child: Text('Menunggu')),
              const PopupMenuItem(value: 'Dipanggil', child: Text('Dipanggil')),
              const PopupMenuItem(value: 'Selesai', child: Text('Selesai')),
              const PopupMenuItem(value: 'Batal', child: Text('Batal')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.accent,
              child: _antrianList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _antrianList.length,
                      itemBuilder: (context, index) {
                        final antrian = _antrianList[index];
                        return _buildAntrianCard(antrian);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada antrian',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus != null 
                ? 'Tidak ada antrian dengan status $_filterStatus'
                : 'Anda belum memiliki antrian',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntrianCard(AntrianModel antrian) {
    final statusColor = _getStatusColor(antrian.status);
    final statusIcon = _getStatusIcon(antrian.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.itemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ticket number and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.confirmation_number_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Antrian',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        antrian.ticketNumber,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        antrian.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.person_rounded,
                  label: 'Pasien',
                  value: antrian.pasien?.nama ?? '-',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.local_hospital_rounded,
                  label: 'Poli',
                  value: antrian.poli?.namaPoli ?? '-',
                ),
                if (antrian.dokter != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.medical_services_rounded,
                    label: 'Dokter',
                    value: antrian.dokter?.nama ?? '-',
                  ),
                ],
                if (antrian.scheduledAt != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Jadwal',
                    value: _formatDateTime(antrian.scheduledAt!),
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Dibuat',
                  value: _formatDateTime(antrian.createdAt ?? DateTime.now()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }
}
