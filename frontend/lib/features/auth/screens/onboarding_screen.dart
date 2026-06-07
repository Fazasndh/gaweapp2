import 'package:flutter/material.dart';
import 'package:gawe_app/features/auth/screens/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/G1.png",
      "title": "Mulai Langkah Barumu",
      "text":
          "Eksplorasi ribuan peluang karier dari perusahaan\nterbaik yang sesuai dengan minat dan potensimu.",
    },
    {
      "image": "assets/images/G2.png",
      "title": "Rekomendasi Cerdas",
      "text":
          "Sistem pintar kami akan mencarikan lowongan\npekerjaan yang paling cocok dengan keahlianmu.",
    },
    {
      "image": "assets/images/G3.png",
      "title": "Lamar Satu Ketukan",
      "text":
          "Kirim profil dan CV-mu ke berbagai perusahaan\nimpian dengan mudah, cepat, dan tanpa ribet.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeaderLogo(),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(
                    image: onboardingData[index]["image"]!,
                    title: onboardingData[index]["title"]!,
                    text: onboardingData[index]["text"]!,
                  );
                },
              ),
            ),

            // Indikator Titik
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => _buildDotIndicator(index: index),
              ),
            ),
            const SizedBox(height: 30),

            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (WAJIB ADA SEMUA AGAR TIDAK ERROR) ---

  Widget _buildHeaderLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9B51E0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.work_outline, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gawee',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9B51E0),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent({
    required String image,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 250,
            fit: BoxFit.contain,
            // Error handling jika gambar tidak ditemukan
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.red),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: _currentPage == index ? 24 : 16,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF007BFF)
            : const Color(0xFFD1D1E9),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            // Pastikan nama class di file role_selection.dart adalah RoleSelectionScreen
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'GET STARTED',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
