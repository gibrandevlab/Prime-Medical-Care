import 'package:flutter/material.dart';
import '../model/dokter.dart';

class DokterItem extends StatelessWidget {
  final Dokter dokter;
  final VoidCallback? onTap;

  const DokterItem({super.key, required this.dokter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Avatar / Icon Dokter
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Color(0xFF00695C),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 20),
                // Info Dokter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dokter.nama,
                        style: const TextStyle(
                          fontFamily: 'Tahoma',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.local_hospital, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            dokter.namaPoli ?? "Poli Umum",
                            style: const TextStyle(
                              fontFamily: 'Tahoma',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00695C), // Highlight Poli
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Panah
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFD4AF37), // Gold accent
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}