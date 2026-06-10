import 'package:flutter/material.dart';
import '/services/api_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk Form Input
  final _nameCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _industryCtrl.dispose();
    _locCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _apiService.getCompanyProfile(); 
      if (data != null && mounted) {
        setState(() {
          _nameCtrl.text = data['company_name'] ?? '';
          _industryCtrl.text = data['industry'] ?? '';
          _locCtrl.text = data['location'] ?? '';
          _descCtrl.text = data['description'] ?? '';
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final success = await _apiService.updateCompanyProfile({
      'company_name': _nameCtrl.text.trim(),
      'industry': _industryCtrl.text.trim(),
      'location': _locCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    });
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _isEditMode = false; // Kembali ke tampilan detail biasa setelah sukses
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan profil."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Perusahaan", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
  if (!_isLoading)
    Padding(
      padding: const EdgeInsets.only(right: 16.0), // Menyeimbangkan jarak dengan sisi kiri layar (16dp)
      child: Center( // Memaksa tombol berada tepat di tengah secara vertikal di dalam AppBar
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero, 
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            setState(() => _isEditMode = !_isEditMode);
          },
          icon: Icon(
            _isEditMode ? Icons.close : Icons.edit, 
            color: theme.primaryColor, 
            size: 16 
          ),
          label: Text(
            _isEditMode ? "Batal" : "Edit", 
            style: TextStyle(
              color: theme.primaryColor, 
              fontWeight: FontWeight.bold, 
              fontSize: 14
            )
          ),
        ),
      ),
    )
],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Banner Atas (Konsisten di kedua mode)
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.business, size: 45, color: theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 30),

                // KONDISIONAL TAMPILAN: JIKA EDIT MODE AKTIF, TAMPILKAN FORM
                _isEditMode ? _buildEditForm(theme) : _buildViewProfile(),
              ],
            ),
          ),
    );
  }

  // 1. TAMPILAN DETAIL STATIS (VIEW MODE)
  Widget _buildViewProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoData("Nama Perusahaan", _nameCtrl.text, Icons.business_center),
        _infoData("Industri / Bidang Bisnis", _industryCtrl.text, Icons.category),
        _infoData("Lokasi Kantor Pusat", _locCtrl.text, Icons.location_on),
        _infoData("Deskripsi Perusahaan", _descCtrl.text, Icons.description, isParagraph: true),
      ],
    );
  }

  // 2. TAMPILAN FORM INPUTAN (EDIT MODE)
  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _field("Nama Perusahaan", _nameCtrl, true, Icons.business_center),
          _field("Industri / Bidang Bisnis", _industryCtrl, false, Icons.category),
          _field("Lokasi Kantor Pusat", _locCtrl, false, Icons.location_on),
          _field("Deskripsi Singkat Perusahaan", _descCtrl, false, Icons.description, maxLines: 5),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  // Helper Komponen Teks Detail Statis
  Widget _infoData(String label, String value, IconData icon, {bool isParagraph = false}) {
    final displayValue = value.isEmpty ? "Belum diisi" : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: isParagraph ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  displayValue, 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: isParagraph ? FontWeight.normal : FontWeight.bold, 
                    color: Colors.black87,
                    height: isParagraph ? 1.5 : 1.2
                  ),
                  textAlign: isParagraph ? TextAlign.justify : TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Komponen Text Field
  Widget _field(String label, TextEditingController ctrl, bool isRequired, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(icon, size: 20),
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
        ),
        validator: (v) => (isRequired && (v == null || v.trim().isEmpty)) ? "Bagian ini wajib diisi" : null,
      ),
    );
  }
}