import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MotivationPage extends StatelessWidget {
  const MotivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final List<String> quotes = [
      'Kesuksesan adalah hasil dari kebiasaan kecil yang dilakukan setiap hari.',
      'Jangan menunda pekerjaan, lakukan sekarang juga!',
      'Fokus pada satu tugas, selesaikan, lalu lanjutkan ke tugas berikutnya.',
      'Setiap hari adalah kesempatan baru untuk menjadi lebih baik.',
      'Produktivitas bukan tentang bekerja lebih keras, tapi lebih cerdas.',
    ];
    final List<String> tips = [
      'Buat daftar prioritas tugas setiap pagi.',
      'Gunakan teknik Pomodoro: kerja 25 menit, istirahat 5 menit.',
      'Matikan notifikasi yang tidak penting saat bekerja.',
      'Review pencapaianmu di akhir hari.',
      'Jangan lupa istirahat dan jaga kesehatan.',
    ];
    final today = DateTime.now().day;
    final quote = quotes[today % quotes.length];
    final tip = tips[today % tips.length];
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    Theme.of(context).textTheme.titleLarge?.color ?? Colors.black;
    final primaryColor = Theme.of(context).primaryColor;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivasi & Tips',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: primaryColor),
                      const SizedBox(height: 24),
                      Text(
                        '"$quote"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Tips Produktivitas Hari Ini',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            tip,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontSize: 16, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
