import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionHeader({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: color ?? Colors.black87,
            fontFamily: 'Tahoma',
          )
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
