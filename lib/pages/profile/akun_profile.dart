import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi Picker

  // Controllers
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false; // Loading khusus upload foto
  String? _avatarUrl; // Variabel untuk menampung URL foto

  // Warna Gradient & Solid
  final Color _itsBlue = const Color(0xFF003875);
  final Gradient _purpleGradient = const LinearGradient(
    colors: [Color(0xFF6B46C1), Color(0xFF4C6EF5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- LOGIC 1: AMBIL DATA USER ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? "";

        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          setState(() {
            _nameController.text = data['full_name'] ?? "";
            _nrpController.text = data['NRP']?.toString() ?? ""; 
            _phoneController.text = data['phone_number']?.toString() ?? "";
            _avatarUrl = data['avatar_url']; // Ambil URL foto jika ada
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: UPLOAD FOTO ---
  Future<void> _pickAndUploadImage() async {
    try {
      // 1. Buka Galeri
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kompres sedikit biar ringan
        maxWidth: 800,
      );
      
      if (image == null) return; // Kalau user batal milih

      setState(() => _isUploadingImage = true);

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 2. Siapkan File & Nama Unik
      final imageBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // 3. Upload ke Supabase Storage (Bucket: avatars)
      // Pastikan Anda sudah membuat bucket 'avatars' di Dashboard Supabase!
      await supabase.storage.from('avatars').uploadBinary(
        fileName,
        imageBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );

      // 4. Ambil URL Publiknya
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // 5. Update UI
      setState(() {
        _avatarUrl = imageUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto berhasil diupload! Jangan lupa klik Simpan.')),
      );

    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload foto: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- LOGIC 3: SIMPAN PERUBAHAN KE DATABASE ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'avatar_url': _avatarUrl, // Simpan URL foto ke database
        }).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Kembali & Refresh halaman sebelumnya
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(context, false)),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await supabase.auth.signOut();
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Kembali", style: TextStyle(color: Colors.grey, fontSize: 16)),
        titleSpacing: -10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. AVATAR & GANTI FOTO ---
              Center(
                child: Column(
                  children: [
                    // Widget Lingkaran Foto
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _avatarUrl == null ? _purpleGradient : null,
                        color: Colors.grey.shade200,
                        image: _avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_avatarUrl!), // Tampilkan foto dari URL
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _isUploadingImage
                          ? const CircularProgressIndicator() // Loading saat upload
                          : (_avatarUrl == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tombol Ganti Foto
                    OutlinedButton(
                      onPressed: _isLoading || _isUploadingImage ? null : _pickAndUploadImage,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF003875)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: Text(
                        _isUploadingImage ? "Mengupload..." : "Ganti Foto",
                        style: const TextStyle(color: Color(0xFF003875), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. FORM INPUTS ---
              _buildLabel("Nama Lengkap"),
              _buildEditableField(controller: _nameController, icon: Icons.person, hint: "Masukkan nama lengkap"),
              const SizedBox(height: 20),

              _buildLabel("NRP"),
              _buildLockedField(controller: _nrpController, icon: Icons.fingerprint),
              const SizedBox(height: 20),

              _buildLabel("Email ITS"),
              _buildLockedField(controller: _emailController, icon: Icons.email),
              const SizedBox(height: 20),

              _buildLabel("Nomor Telepon"),
              Container(
                decoration: BoxDecoration(
                  gradient: _purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Text("+62", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              // --- 3. ACTIONS BUTTONS ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || _isUploadingImage ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _itsBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Hapus Akun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Color(0xFF003875), fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildEditableField({required TextEditingController controller, required IconData icon, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF003875)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLockedField({required TextEditingController controller, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: _purpleGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: const Icon(Icons.lock_outline, color: Colors.white70, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}