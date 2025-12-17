import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'akun_profile.dart'; // Pastikan import halaman edit profile benar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Warna Utama
  final Color _itsBlue = const Color(0xFF003875);
  final supabase = Supabase.instance.client;

  String _fullName = "Memuat...";
  String _email = "";
  String? _avatarUrl; // Variabel baru untuk menampung URL foto

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // UPDATE: Ambil avatar_url juga
  Future<void> _fetchProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final email = user.email ?? "-";
        
        // Perbaikan di sini: select('full_name, avatar_url')
        final data = await supabase
            .from('profiles')
            .select('full_name, avatar_url') 
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _email = email;
            // Simpan URL foto ke variabel
            _avatarUrl = data?['avatar_url'];

            if (data != null && data['full_name'] != null) {
              _fullName = data['full_name'];
            } else {
              _fullName = email.split('@')[0]; 
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil profil: $e");
    }
  }

  Future<void> _signOut() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await supabase.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              // ==========================================
              // 1. HEADER PROFILE (Avatar + Identitas)
              // ==========================================
              Center(
                child: Column(
                  children: [
                    // UPDATE: Logic Tampilan Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Kalau ada foto, hapus gradient biar ga tabrakan warnanya
                        // Kalau tidak ada foto, tampilkan gradient ungu-biru
                        gradient: _avatarUrl != null 
                            ? null 
                            : const LinearGradient(
                                colors: [Color(0xFF6B46C1), Color(0xFF4C6EF5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _avatarUrl != null ? Colors.grey.shade200 : null,
                        boxShadow: [
                          BoxShadow(
                            color: _itsBlue.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        // Tampilkan Gambar dari URL
                        image: _avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Kalau tidak ada foto, tampilkan ikon user putih
                      // Kalau ada foto, kosongkan child (karena sudah ada background image)
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      _email,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    Text(
                      _fullName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _itsBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // ==========================================
              // 2. MENU LIST
              // ==========================================
              
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: "Akun",
                subtitle: "Ganti Password, Edit Data Akun",
                onTap: () async {
                  // UPDATE: Tunggu hasil dari halaman edit
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                  
                  // Jika result == true (berarti ada tombol simpan yang ditekan), refresh data
                  if (result == true) {
                    _fetchProfileData(); 
                  }
                },
              ),
              
              _buildDivider(),

              _buildProfileMenuItem(
                icon: Icons.history,
                title: "Riwayat Peminjaman",
                subtitle: "Lihat peminjaman yang sudah selesai",
                onTap: () {},
              ),

              _buildDivider(),

              _buildProfileMenuItem(
                icon: Icons.logout_outlined,
                title: "Keluar",
                subtitle: "Keluar dari akun",
                onTap: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        height: 40,
        width: 40,
        alignment: Alignment.centerLeft,
        child: Icon(icon, color: Colors.black, size: 26),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
      height: 24, 
    );
  }
}