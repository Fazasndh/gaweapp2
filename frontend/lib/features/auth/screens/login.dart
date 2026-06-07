import 'package:flutter/material.dart';
import 'register.dart';
import '/features/seeker/dashboard_seeker.dart';
import '/services/api_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gawe_app/features/company/dashboard_company.dart';

// 1. DIUBAH JADI STATEFUL WIDGET
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. TAMBAH CONTROLLER UNTUK NANGKEP INPUTAN
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 3. TAMBAH STATE LOADING & PANGGIL API SERVICE
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // 4. LOGIKA UTAMA LOGIN
  void _handleLogin() async {
    // Validasi kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _apiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return; 
    setState(() {
      _isLoading = false;
    });

   if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil!'), backgroundColor: Colors.green),
      );
      final prefs = await SharedPreferences.getInstance();
      final String role = prefs.getString('user_role') ?? 'seeker';

      if (role == 'company') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompanyDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF9B51E0), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('Gawee', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF9B51E0), letterSpacing: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const SizedBox(height: 8),
              const Text('Sign in to continue your journey', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              
              // 5. MASUKKAN CONTROLLER KE DALAM TEXTFIELD
              _buildTextField(hintText: 'Email Address', controller: _emailController),
              const SizedBox(height: 16),
              _buildTextField(hintText: 'Password', isPassword: true, controller: _passwordController),
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              // 6. LOGIKA PERGANTIAN TOMBOL VS LOADING
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                  : ElevatedButton(
                      onPressed: _handleLogin, // Panggil fungsi eksekusi di sini
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('SIGN IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                    ),
                    
              const SizedBox(height: 40),
              const Center(child: Text('Don\'t have an account?', style: TextStyle(color: Colors.black87, fontSize: 14))),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CREATE AN ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF007BFF))),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 7. FUNGSI WIDGET BANTUAN DIUBAH UNTUK MENERIMA CONTROLLER
  Widget _buildTextField({required String hintText, bool isPassword = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        controller: controller, // Pasang selang penyedot datanya di sini
        obscureText: isPassword,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
      ),
    );
  }
}