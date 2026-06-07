import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isUploading = false;

  // Data User
  String _userName = "Loading...";
  String _userEmail = "";
  
  // Data Profil
  String? _photoUrl;
  String? _resumeUrl;
  String _skillsText = "Belum ada data skill terdaftar.";
  String _phone = "Belum ada nomor telepon.";

  // File Memory (AMAN UNTUK WEB & ANDROID)
  Uint8List? _imageBytes; 
  String _resumeFileName = "Belum ada resume diunggah";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final profileData = await ApiService().getSeekerProfile();
      
      if (profileData != null && mounted) {
        setState(() {
          _userName = profileData['name'] ?? 'Nama Tidak Diketahui';
          _userEmail = profileData['email'] ?? 'Email Tidak Diketahui';
          _phone = profileData['phone'] ?? "Belum ada nomor telepon.";
          _skillsText = profileData['skills'] ?? "Belum ada data skill terdaftar.";
          _photoUrl = profileData['photo_url'];
          _resumeUrl = profileData['resume_url'];

          if (_resumeUrl != null) {
            _resumeFileName = _resumeUrl!.split('/').last;
          }
        });
      }
    } catch (e) {
      print("LOG Error Render Profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    // Di Web, ini akan mengembalikan file virtual di memori
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      // BACA SEBAGAI BYTES (Aman untuk Chrome)
      final bytes = await pickedFile.readAsBytes();
      
      setState(() {
        _imageBytes = bytes;
        _photoUrl = null; // Hapus URL lama agar UI memprioritaskan foto baru
      });
      
      await _uploadMultipartBytes('photo', bytes, pickedFile.name);
    }
  }

  Future<void> _pickAndUploadResume() async {
    FilePickerResult? result =
    await FilePicker.pickFiles( 
      type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true, 
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      setState(() => _resumeFileName = fileName);
      
      await _uploadMultipartBytes('resume', bytes, fileName);
    } else {
      print("LOG: Batal pilih file atau gagal baca byte.");
    }
  }

  // LOGIKA UPLOAD BARU (MENGGUNAKAN BYTES, BUKAN PATH FILE)
  Future<void> _uploadMultipartBytes(String fieldName, Uint8List bytes, String fileName) async {
    setState(() => _isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/profile/update'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // MENGGUNAKAN FROMBYTES
      request.files.add(http.MultipartFile.fromBytes(
        fieldName, 
        bytes,
        filename: fileName, 
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berkas berhasil diunggah!'), backgroundColor: Colors.green),
          );
          _fetchProfileData(); // Refresh data dari server
        }
      } else {
        throw Exception('Server menolak. HTTP: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    final nickname = _userName.split(' ').first;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. FOTO PROFIL
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                            ],
                            // MENGGUNAKAN MEMORYIMAGE UNTUK PREVIEW BYTES
                            image: _imageBytes != null
                                ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                                : (_photoUrl != null
                                    ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                                    : null),
                          ),
                          child: (_imageBytes == null && _photoUrl == null)
                              ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                              : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. NAMA PANGGILAN
                  Text(
                    nickname,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 30),

                  // 3. DATA DIRI LENGKAP
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Data Diri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataRow(Icons.badge, "Nama Lengkap", _userName, theme),
                        const Divider(height: 24),
                        _buildDataRow(Icons.email, "Email", _userEmail, theme),
                        const Divider(height: 24),
                        _buildDataRow(Icons.phone, "Nomor HP", _phone, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 4. SKILLS
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Keahlian (Skills)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur edit teks menyusul')));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      _skillsText,
                      style: TextStyle(fontSize: 15, height: 1.5, color: theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // INDIKATOR UPLOAD GLOBAL
                  if (_isUploading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text("Sedang memproses berkas..."),
                    const SizedBox(height: 20),
                  ],

                  // 5. UPLOAD RESUME
                  GestureDetector(
                    onTap: _pickAndUploadResume,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Upload Resume / CV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  _resumeFileName,
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.upload_file, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ],
    );
  }
}