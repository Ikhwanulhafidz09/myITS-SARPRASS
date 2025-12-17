import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan import ini sesuai dengan struktur project Anda
import '../main.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Warna Utama sesuai Desain
  final Color _itsBlue = const Color(0xFF003875); 
  final Color _itsGreenBg = const Color(0xFFE3FCEF);
  final Color _itsGreenText = const Color(0xFF006644);

  // Variable nama user
  final supabase = Supabase.instance.client;
  String _userName = "Mahasiswa ITS"; 

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Mengambil nama user dari database
  Future<void> _fetchUserName() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final data = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', userId)
            .single();
        if (mounted) {
          setState(() {
            _userName = data['full_name'] ?? "Mahasiswa ITS";
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil nama: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // 1. HEADER PROFILE
              // ============================================
              Row(
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF4C6EF5), // Biru agak terang sesuai Figma
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  // Teks Welcome & Nama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome,",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _userName, // Nama dinamis
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Notifikasi dengan Badge Merah
                  Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 28, color: Colors.black87),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ============================================
              // 2. HEADER RIWAYAT
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: _itsBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Riwayat Peminjaman",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _itsBlue,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Aksi lihat semua
                      context.findAncestorStateOfType<MainScreenState>()?.onItemTapped(1);
                    },
                    child: const Text(
                      "Lihat Semua >",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ============================================
              // 3. KARTU PEMINJAMAN (CARD DETAIL)
              // ============================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1: Label Room & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Room", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _itsGreenBg,
                            borderRadius: BorderRadius.circular(20), // Pill shape
                          ),
                          child: Text(
                            "Dalam Peminjaman",
                            style: TextStyle(
                              color: _itsGreenText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Nama Ruangan
                    const Text(
                      "Teater A",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Detail Informasi (Icon + Text)
                    _buildDetailRow(Icons.calendar_today_outlined, "20/01/25 - 22/01/25"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.access_time, "13.00 - 18.00 WIB"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.people_outline, "150 Orang"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.monetization_on_outlined, "Rp160.000"),

                    const SizedBox(height: 16),

                    // Tombol Lihat Detail (Kanan Bawah)
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _itsBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            "Lihat Detail",
                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ============================================
              // 4. PENCARIAN CEPAT
              // ============================================
              Row(
                children: [
                  Icon(Icons.search, color: _itsBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Pencarian Cepat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _itsBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Input Field & Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Masukkan nama ruangan...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Filter (Garis tiga)
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(Icons.filter_list, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Tombol Cari Ruangan (Biru Besar)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Pindah ke tab Search
                    context.findAncestorStateOfType<MainScreenState>()?.onItemTapped(2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _itsBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Cari Ruangan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ============================================
              // 5. INFORMASI LAINNYA
              // ============================================
              Row(
                children: [
                  Icon(Icons.info_outline, color: _itsBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Informasi Lainnya",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _itsBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Grid Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard(
                      context, Icons.folder_open, "Alur\nPenjelasan", 0),
                  _buildInfoCard(context, Icons.chat_bubble_outline, "FAQ", 1),
                  _buildInfoCard(
                      context, Icons.support_agent, "Kirim\nPertanyaan", 2),
                ],
              ),

              const SizedBox(height: 30), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER KECIL ---

  // Helper untuk baris detail di kartu (Icon + Teks)
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Helper untuk Card Informasi Bawah
  Widget _buildInfoCard(BuildContext context, IconData icon, String label, int infoIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
           // Helper untuk pindah ke tab Info
           context.findAncestorStateOfType<MainScreenState>()?.openInfoPage(infoIndex);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 110, // Tinggi fixed agar rapi
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Background (Simulasi bentuk di Figma)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _itsBlue, // Biru ITS Solid
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2, // Spasi baris
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}