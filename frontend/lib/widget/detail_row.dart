import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: Colors.grey[600], fontFamily: 'Tahoma')),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Tahoma',
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }
}
