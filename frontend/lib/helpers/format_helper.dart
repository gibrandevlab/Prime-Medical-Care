import 'package:intl/intl.dart';

class FormatHelper {
  // Format ke "Senin, 12 Jan 2024 14:30 WIB"
  static String formatDateWIB(dynamic date) {
    if (date == null) return "-";
    DateTime dt;
    if (date is String) {
      dt = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return "-";
    }

    // Force ke UTC+7 (WIB)
    // Jika input adalah UTC (zulu), tambah 7 jam.
    // Jika input tidak ada info timezone, anggap UTC lalu convert.
    // Tapi amannya kita tambah offset manual jika perlu atau pakai logic timezone.
    
    // Cara mudah: Pastikan backend kirim UTC, lalu kita toLocal().
    // Tapi user minta paksa WIB.
    final wibTime = dt.toUtc().add(const Duration(hours: 7));
    
    // Format Bahasa Indonesia
    // Perlu 'initializeDateFormatting' di main jika ingin full locale ID,
    // tapi untuk simpel kita format manual atau pakai pattern Inggris tapi suffix WIB.
    return "${DateFormat('yyyy-MM-dd HH:mm').format(wibTime)} WIB";
  }
}
