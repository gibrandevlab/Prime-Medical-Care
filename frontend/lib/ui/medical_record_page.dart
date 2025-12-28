import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../service/medical_record_service.dart';
import '../service/antrian_service.dart';
import 'medical_record_form.dart';
import '../model/medical_record.dart';
import '../helpers/format_helper.dart';
import '../helpers/app_theme.dart';

class MedicalRecordPage extends StatefulWidget {
  final int pasienId;
  final int? dokterId;
  final int? poliId;
  final int? antrianId;

  const MedicalRecordPage({
     super.key, 
     required this.pasienId,
     this.dokterId,
     this.poliId,
     this.antrianId,
  });

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  final _svc = MedicalRecordService();
  final _antrianSvc = AntrianService();
  final ScrollController _scrollController = ScrollController();
  
  List<MedicalRecordModel> _records = [];
  bool _loading = true;
  int _lastFocusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
    // Gunakan listener untuk update UI hanya saat scroll
    _scrollController.addListener(_handleScrollEffect);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollEffect() {
    if (!_scrollController.hasClients) return;
    const double itemExtent = 160.0;
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double centerPoint = _scrollController.offset + (viewportHeight / 2);
    
    int newIndex = ((centerPoint - 80) / itemExtent).floor();
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= _records.length) newIndex = _records.length - 1;

    if (newIndex != _lastFocusedIndex) {
      if (mounted) {
         HapticFeedback.selectionClick();
         setState(() {
           _lastFocusedIndex = newIndex;
         });
      }
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _svc.listByPasien(widget.pasienId);
      if (!mounted) return;
      list.sort((a, b) => b.visitDate.compareTo(a.visitDate));
      setState(() {
        _records = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Medis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _records.isEmpty
              ? _buildEmptyState()
              : AnimationLimiter(
                  // KUNCI: Key ditambahkan agar limiter tidak reset saat setState
                  key: ValueKey(_records.length),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      final isLeft = index % 2 == 0;
                      final bool isFocused = index == _lastFocusedIndex;

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 1000),
                        child: SlideAnimation(
                          // Efek meluncur dari samping
                          horizontalOffset: isLeft ? -300.0 : 300.0,
                          curve: Curves.easeOutQuart,
                          child: FadeInAnimation(
                            child: _buildTimelineRow(record, isLeft, index == _records.length - 1, isFocused),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: (widget.dokterId != null) 
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("Analisis Baru", style: TextStyle(color: Colors.white, fontFamily: 'Tahoma')),
              onPressed: () async {
                 final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => MedicalRecordForm(
                       pasienId: widget.pasienId,
                       dokterId: widget.dokterId,
                       poliId: widget.poliId,
                       antrianId: widget.antrianId
                    ))
                 );
                 
                 if (result != null) {
                    _load(); // Reload list
                    // If integrated with Antrian, update status
                    if (widget.antrianId != null) {
                       await _antrianSvc.updateStatus(widget.antrianId!, 'Selesai');
                       if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Status antrian diperbarui ke Selesai"))
                          );
                       }
                    }
                 }
              },
            )
          : null,
    );
  }

  Widget _buildTimelineRow(MedicalRecordModel record, bool isLeft, bool isLast, bool isFocused) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: isLeft ? _buildCard(record, isLeft, isFocused) : const SizedBox.shrink()),
          
          // Garis & Bulatan Tengah
          SizedBox(
            width: 40,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isFocused ? 22 : 10,
                  height: isFocused ? 22 : 10,
                  decoration: BoxDecoration(
                    color: isFocused ? AppColors.accent : Colors.white12,
                    shape: BoxShape.circle,
                    border: Border.all(color: isFocused ? Colors.white : Colors.transparent, width: 2),
                    boxShadow: isFocused 
                        ? [BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)] 
                        : [],
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.white10)),
              ],
            ),
          ),

          Expanded(child: !isLeft ? _buildCard(record, isLeft, isFocused) : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCard(MedicalRecordModel record, bool isLeft, bool isFocused) {
    return GestureDetector(
      onTap: () => _showDetail(record),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFocused ? AppColors.itemBackground : AppColors.itemBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isFocused ? AppColors.accent : Colors.white.withOpacity(0.05),
            width: 2
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time_filled, size: 12, color: isFocused ? AppColors.accent : Colors.white24),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    FormatHelper.formatDateWIB(record.visitDate),
                    style: TextStyle(
                      color: isFocused ? AppColors.accent : Colors.white24, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.diagnosa ?? "Diagnosa",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              record.anamnesa ?? "-",
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(MedicalRecordModel record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text("Detail Kunjungan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Divider(height: 30),
            _detailRow(Icons.event, "Tanggal", FormatHelper.formatDateWIB(record.visitDate)),
            _detailRow(Icons.medical_services, "Diagnosa", record.diagnosa ?? "-"),
            _detailRow(Icons.description, "Keluhan", record.anamnesa ?? "-"),
            _detailRow(Icons.medication, "Resep", record.resep ?? "-"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
          ])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Belum ada riwayat medis.", style: TextStyle(color: Colors.white38)));
  }
}