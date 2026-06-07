import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IP Localhost (Hanya berfungsi untuk testing di Chrome/Web atau Emulator)
  // Ganti ke IP Jaringan (misal: 192.168.1.5) jika testing di HP Fisik.
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Mendaftarkan pengguna baru ke database Laravel.
  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, 
          'role': role,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('LOG [Register]: Sukses mendaftarkan $role.');
        return true;
      } else {
        print('LOG [Register]: Gagal. HTTP ${response.statusCode}');
        print('LOG [Register Error]: ${response.body}');
        return false;
      }
    } catch (e) {
      print('LOG [Register Exception]: $e');
      return false;
    }
  }

  /// Mengirim kredensial untuk login dan menyimpan token di SharedPreferences.
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email);

        if (data['user'] != null && data['user']['name'] != null) {
          await prefs.setString('user_name', data['user']['name']);
          final String userRole = data['user']['role'] ?? 'seeker';
          await prefs.setString('user_role', userRole);
        }

        print('LOG [Login]: Autentikasi berhasil. Token tersimpan.');
        return true;
      } else {
        print('LOG [Login]: Gagal. HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('LOG [Login Exception]: $e');
      return false;
    }
  }

  /// Mengambil semua daftar lowongan pekerjaan (Public/Sesuai Auth)
  Future<List<dynamic>> fetchJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        print('LOG [Fetch Jobs]: Token tidak ditemukan. Akses ditolak.');
        return []; 
      }

      final response = await http.get(
        Uri.parse('$baseUrl/jobs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] ?? []; 
      } else {
        print('LOG [Fetch Jobs]: Gagal. HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('LOG [Fetch Jobs Exception]: $e');
      return [];
    }
  }

  /// Mengirim data lowongan baru ke server (Hanya untuk role Company)
  Future<bool> postJob(String title, String location, String description, String salaryRange, String jobType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // Proteksi mandiri, pastikan token ada sebelum nembak API
      if (token == null || token.isEmpty) {
        print('LOG [Post Job]: DIBATALKAN. Token kosong.');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/jobs'), 
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'location': location,
          'description': description,
          'salary_range': salaryRange,
          'job_type': jobType,
        }),
      ).timeout(const Duration(seconds: 10));

      // Evaluasi response secara absolut
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('LOG [Post Job]: SUKSES. Data masuk ke DB.');
        return true;
      } else {
        // INI ADALAH KUNCI DIAGNOSA LU
        print('LOG [Post Job SERVER MENOLAK]: HTTP ${response.statusCode}');
        print('LOG [Post Job ALASAN]: ${response.body}');
        return false;
      }
    } catch (e) {
      print('LOG [Post Job Exception]: $e');
      return false;
    }
  }

  /// Mengambil daftar lowongan yang diposting oleh user yang sedang login
  Future<List<dynamic>> getMyJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/my-jobs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] ?? [];
      } else {
        print('LOG [My Jobs]: Gagal. HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('LOG [My Jobs Exception]: $e');
      return [];
    }
  }

  /// Menghapus lowongan berdasarkan ID
  Future<bool> deleteJob(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('LOG [Delete Job]: ID $jobId berhasil dihapus.');
        return true;
      } else {
        print('LOG [Delete Job Error]: HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('LOG [Delete Job Exception]: $e');
      return false;
    }
  }

  /// Memperbarui data lowongan berdasarkan ID
  Future<bool> updateJob(int jobId, Map<String, dynamic> jobData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(jobData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('LOG [Update Job]: Sukses memperbarui ID $jobId.');
        return true;
      } else {
        print('LOG [Update Job Error]: HTTP ${response.statusCode}');
        print('LOG [Update Job Body]: ${response.body}');
        return false;
      }
    } catch (e) {
      print('LOG [Update Job Exception]: $e');
      return false;
    }
  }

  /// Keluar dari sesi aplikasi dan menghapus token lokal
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5)); 
      }
      
      await prefs.clear(); 
      print('LOG [Logout]: Sukses membersihkan sesi lokal.');
      return true;
    } catch (e) {
      print('LOG [Logout Exception]: $e');
      // Pastikan sesi lokal tetap dihapus meski server error
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    }
  }
  /// Mengambil data profil lengkap (User + SeekerProfile)
  Future<Map<String, dynamic>?> getSeekerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        print('LOG [Get Profile]: Token kosong.');
        return null;
      }
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('LOG [Get Profile Error]: HTTP ${response.statusCode}');
        print('LOG [Get Profile Response]: ${response.body}');
        return null;
      }
    } catch (e) {
      print('LOG [Get Profile Exception]: $e');
      return null;
    }
  }
}