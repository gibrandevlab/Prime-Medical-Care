import 'package:flutter/material.dart';
import '../widget/custom_text_field.dart';
import '../widget/primary_button.dart';
import '../widget/card_container.dart';
import '../helpers/app_theme.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedRating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  
  final Color _goldAccent = const Color(0xFFD4AF37);

  void _submitRating() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon beri bintang terlebih dahulu.")));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Terima Kasih!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Masukan Anda sangat berharga bagi kami.", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Back to Home
              },
              child: const Text("Tutup", style: TextStyle(color: AppColors.primary)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Beri Penilaian", style: TextStyle(fontFamily: 'Tahoma')),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: CardContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bagaimana pengalaman Anda?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: _goldAccent,
                    ),
                    onPressed: () => setState(() => _selectedRating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              CustomTextField(
                label: "Komentar (Opsional)",
                hintText: "Tulis saran atau komentar Anda...",
                controller: _commentCtrl,
                maxLines: 4,
                icon: Icons.comment_outlined,
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: "KIRIM PENILAIAN",
                onPressed: _submitRating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
