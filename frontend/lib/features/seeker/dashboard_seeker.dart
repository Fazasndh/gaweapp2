import 'package:flutter/material.dart';
import 'package:gawe_app/main.dart';
import 'package:gawe_app/features/seeker/job_listing_screen.dart';
import 'package:gawe_app/features/seeker/job_detail_screen.dart';
import 'package:gawe_app/features/seeker/notifications_screen.dart';
import 'package:gawe_app/features/shared/profile_screen.dart';
import 'package:gawe_app/features/shared/settings_screen.dart';
import 'package:gawe_app/features/shared/messages_screen.dart';
import 'package:gawe_app/features/seeker/SavedAndAppliedScreen.dart';
import 'package:gawe_app/features/auth/screens/login.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Loading...';
  List<dynamic> _recentJobs = [];
  bool _isLoadingJobs = true;
  final ApiService _apiService = ApiService();

  // STATE BARU UNTUK STATISTIK
  int _appliedCount = 0;
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // MENGGABUNGKAN PROSES LOADING AGAR EFISIEN
  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String storedName = prefs.getString('user_name') ?? 'Seeker';

    try {
      // Tarik pekerjaan dan statistik secara berurutan
      List<dynamic> jobsFromApi = await _apiService.fetchJobs();
      Map<String, dynamic>? stats = await _apiService.getDashboardStats();

      if (mounted) {
        setState(() {
          _userName = storedName;
          _recentJobs = jobsFromApi;
          _appliedCount = stats?['total_applied'] ?? 0;
          _savedCount = stats?['total_saved'] ?? 0;
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      print("LOG Error Initialize Dashboard: $e");
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: theme.iconTheme.color,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color,
            ),
          ),
          IconButton(
            onPressed: () => _showColorPalette(context),
            icon: Icon(Icons.palette_outlined, color: theme.iconTheme.color),
          ),
          IconButton(
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            icon: Icon(Icons.dark_mode_outlined, color: theme.iconTheme.color),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const JobListingScreen(title: "Search Jobs"),
                  ),
                );
                _initializeData(); // Refresh setelah kembali
              },
              child: _buildSearchBar(context),
            ),

            const SizedBox(height: 25),
            _buildPromoBanner(primaryColor),
            const SizedBox(height: 20),

            // KOTAK STATISTIK YANG SUDAH DINAMIS
            _buildStatsGrid(context),

            const SizedBox(height: 30),

            // HEADER CATEGORIES (Tanpa tombol More)
            Text(
              "Job Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 15),
            _buildCategoryList(),

            const SizedBox(height: 30),

            // HEADER RECENT JOBS DENGAN ASYNC AWAIT REFRESH
            _buildSectionHeader("Recent Jobs", context, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const JobListingScreen(title: "All Jobs"),
                ),
              );
              _initializeData(); // Refresh setelah kembali
            }),
            const SizedBox(height: 15),
            _buildRecentJobList(context),
          ],
        ),
      ),
    );
  }

  void _showColorPalette(BuildContext context) {
    final List<Map<String, dynamic>> colors = [
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Pink', 'color': Colors.pink},
      {'name': 'Yellow', 'color': Colors.yellow.shade700},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Deeppurple', 'color': Colors.deepPurple},
      {'name': 'Lightblue', 'color': Colors.lightBlue},
      {'name': 'Teal', 'color': Colors.teal},
      {'name': 'Lime', 'color': Colors.lime.shade700},
      {'name': 'Deeporange', 'color': Colors.deepOrange},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 25,
                runSpacing: 25,
                alignment: WrapAlignment.center,
                children: colors.map((colorData) {
                  final Color itemColor = colorData['color'];
                  return ValueListenableBuilder<Color>(
                    valueListenable: primaryColorNotifier,
                    builder: (context, currentColor, _) {
                      bool isSelected = currentColor.value == itemColor.value;
                      return GestureDetector(
                        onTap: () {
                          primaryColorNotifier.value = itemColor;
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: 70,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                colorData['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 15, top: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF333333),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 30),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Gawee',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    Icons.home,
                    "Home",
                    true,
                    context,
                    () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(Icons.person, "Profile", false, context, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(Icons.mail, "Messages", false, context, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagesScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(
                    Icons.settings,
                    "Settings",
                    false,
                    context,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // LOGIKA LOGOUT BARU
                  _buildDrawerItem(
                    Icons.logout,
                    "Logout",
                    false,
                    context,
                    () async {
                      // Tutup drawer terlebih dahulu
                      Navigator.pop(context);
                      
                      // Tampilkan dialog loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // Proses penghapusan token
                      final success = await _apiService.logout();

                      if (context.mounted) {
                        Navigator.pop(context); // Tutup dialog loading

                        if (success) {
                          // Navigasi absolut ke layar Login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal logout. Periksa koneksi internet Anda.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, bottom: 30, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gawee Job Portal",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "App Version 1.3",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected,
    BuildContext context,
    VoidCallback onTap,
  ) {
    final iconTextColor = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade400;
    final bgColor = isSelected
        ? Theme.of(context).primaryColor.withOpacity(0.08)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5, right: 25),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 35,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 25),
            Icon(icon, color: iconTextColor, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: iconTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String initials = "U";
    if (_userName != 'Loading...' && _userName.isNotEmpty) {
      List<String> nameParts = _userName.trim().split(' ');
      if (nameParts.length > 1) {
        initials =
            nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        initials = nameParts[0][0].toUpperCase();
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              _userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(width: 10),
          Text(
            "Find job by category or title...",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Recommended Jobs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "See our recommendations job for you based your skills",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.computer, size: 70, color: Colors.white38),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    if (_isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // TOMBOL NAVIGASI APPLY
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SavedAndAppliedScreen(initialIndex: 0),
              ),
            ),
            child: _buildStatCard(
              _appliedCount.toString(),
              "Jobs Applied",
              context,
            ),
          ),
        ),
        const SizedBox(width: 15),
        // TOMBOL NAVIGASI SAVED
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SavedAndAppliedScreen(initialIndex: 1),
              ),
            ),
            child: _buildStatCard(
              _savedCount.toString(),
              "Saved Jobs",
              context,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String count, String label, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    VoidCallback onTapMore,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        InkWell(
          onTap: onTapMore,
          child: Text(
            "More",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {"name": "Full-Stack Dev", "color": const Color(0xFF007BFF)},
      {"name": "Data Analyst", "color": const Color(0xFF00A884)},
      {"name": "UI/UX Designer", "color": const Color(0xFFFF9800)},
      {"name": "IT Auditor", "color": const Color(0xFFE91E63)},
    ];
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: categories[index]["color"] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              categories[index]["name"] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentJobList(BuildContext context) {
    if (_isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Belum ada lowongan tersedia dari server MySQL.",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentJobs.length,
      itemBuilder: (context, index) {
        final job = _recentJobs[index];
        return GestureDetector(
          // DAFTAR PEKERJAAN DENGAN ASYNC AWAIT REFRESH
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job),
              ),
            );
            _initializeData(); // Refresh setelah kembali dari detail lowongan
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.work,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? 'Posisi Tidak Diketahui',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${job['user']?['name'] ?? job['company_name'] ?? 'Perusahaan'} - ${job['location'] ?? 'Lokasi'}",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        job['salary_range'] ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}