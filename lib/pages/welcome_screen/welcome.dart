import 'package:flutter/material.dart';
import 'package:myits_sarprass/pages/login-register/login_page.dart';
import 'package:myits_sarprass/pages/login-register/register_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // --- STATIC VARIABLE (Ingatan Global) ---
  // Variabel ini tidak akan hilang meskipun widget di-refresh oleh AuthGate.
  // false = Animasi intro belum pernah jalan (Awal buka aplikasi).
  // true = Animasi sudah pernah jalan (Balik dari register/logout).
  static bool _hasPlayedIntro = false;

  // --- ANIMATION STATE ---
  bool _showKey = false;
  bool _moveKeyToSide = false;
  bool _showText = false;
  bool _hideLogoBeforeSlide = false;
  double _blueHeight = 0.0;
  
  // --- UI MODE STATE ---
  bool _isFormOpen = false;
  bool _showLoginForm = true; 
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    // Jalankan logika pengecekan saat layar dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAnimationLogic();
    });
  }

  Future<void> _checkAnimationLogic() async {
    final double screenHeight = MediaQuery.of(context).size.height;

    // KONDISI 1: Jika Intro SUDAH pernah diputar (User habis Register / Logout)
    // Langsung set tampilan akhir dan BUKA form login.
    if (_hasPlayedIntro) {
      setState(() {
        // Set posisi aset seolah animasi sudah selesai
        _showKey = true;
        _moveKeyToSide = true;
        _showText = true;
        _hideLogoBeforeSlide = true;
        
        // Background biru langsung full
        _blueHeight = screenHeight;
        
        // UI Akhir aktif
        _animationCompleted = true;
        
        // LANGSUNG BUKA FORM LOGIN
        _isFormOpen = true; 
        _showLoginForm = true; 
      });
      return; // Stop, jangan jalankan animasi lagi
    }

    // KONDISI 2: Jika Intro BELUM pernah diputar (Baru buka aplikasi)
    // Jalankan animasi dari nol.
    await _startIntroAnimation(screenHeight);
    
    // Tandai bahwa intro sudah selesai diputar
    _hasPlayedIntro = true;
  }

  Future<void> _startIntroAnimation(double screenHeight) async {
    // 1. Delay Awal
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _showKey = true);
    
    // 2. Geser Kunci
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _moveKeyToSide = true;
        _showText = true;
      });
    }
    
    // 3. Tahan sebentar
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _hideLogoBeforeSlide = true); 
    
    // 4. Slide Background
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      setState(() {
        _blueHeight = screenHeight;
        _animationCompleted = true; // Selesai intro
      });
    }
  }

  // --- LOGIC FORM ---
  void _openLogin() {
    setState(() {
      _isFormOpen = true;
      _showLoginForm = true;
    });
  }

  void _openRegister() {
    setState(() {
      _isFormOpen = true;
      _showLoginForm = false;
    });
  }

  void _closeForm() {
    setState(() {
      _isFormOpen = false;
      FocusScope.of(context).unfocus(); // Tutup keyboard
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double fullHeight = size.height;
    final double fullWidth = size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Posisi Logo: Naik jika form open
    double logoTopPosition = _isFormOpen ? 60 : (fullHeight / 2) - 60;
    double logoScale = _isFormOpen ? 0.7 : 1.0; 

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // ---------------------------------------------
          // LAYER 1: BACKGROUND BIRU (Dasar)
          // ---------------------------------------------
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              width: fullWidth,
              height: _blueHeight, 
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/bg_welcome.png',
                    width: fullWidth,
                    height: fullHeight,
                    fit: BoxFit.cover,
                  ),
                  Container(color: const Color(0xFF003875).withOpacity(0.85)),
                ],
              ),
            ),
          ),

          // ---------------------------------------------
          // LAYER 2: LOGO (ANIMATED)
          // ---------------------------------------------
          if (_animationCompleted)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: logoTopPosition,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isFormOpen ? _closeForm : null, 
                child: AnimatedScale(
                  scale: logoScale,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: 120,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      child: Image.asset(
                        'assets/images/logo-full.png', 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Intro Logos (Hanya muncul jika intro belum selesai)
          if (!_animationCompleted) _buildIntroAnimationLogos(),

          // ---------------------------------------------
          // LAYER 3: TOMBOL AWAL (Login / Register)
          // ---------------------------------------------
          if (_animationCompleted)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: _isFormOpen ? -200 : 80, 
              left: 30,
              right: 30,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _isFormOpen ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: _isFormOpen, 
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _openLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF003875),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _openRegister,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("MyITSSarpras Versi 1.0.0", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // ---------------------------------------------
          // LAYER 4: SLIDE UP FORM CONTAINER
          // ---------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            bottom: _isFormOpen ? 0 : -fullHeight, 
            left: 0,
            right: 0,
            height: fullHeight * 0.75, 
            
            child: IgnorePointer(
              ignoring: !_isFormOpen, 
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: keyboardHeight), 
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showLoginForm
                          ? LoginPage(
                              key: const ValueKey('login'), 
                              onSignUpPressed: _openRegister, 
                            )
                          : RegisterPage(
                              key: const ValueKey('register'),
                              onSignInPressed: _openLogin, 
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Intro Animation
  Widget _buildIntroAnimationLogos() {
    const double containerWidth = 320.0;
    const double containerHeight = 100.0;
    const double textHeight = 80.0;
    const double keySizeBig = 100.0;
    const double keySizeSmall = 80.0;
    const double keyEndPositionLeft = 195.0;
    const double keyStartPosLeft = (containerWidth - keySizeBig) / 2;
    const double keyTopBig = (containerHeight - keySizeBig) / 2;
    const double keyTopSmall = (containerHeight - keySizeSmall) / 2;

    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _hideLogoBeforeSlide ? 0.0 : 1.0,
        child: SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showText ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Image.asset(
                    'assets/images/text-sarana-biru.png',
                    height: textHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.fastOutSlowIn,
                left: _moveKeyToSide ? keyEndPositionLeft : keyStartPosLeft,
                top: _moveKeyToSide ? keyTopSmall : keyTopBig,
                width: _moveKeyToSide ? keySizeSmall : keySizeBig,
                height: _moveKeyToSide ? keySizeSmall : keySizeBig,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showKey ? 1.0 : 0.0,
                  child: Image.asset(
                    'assets/images/kunci-biru.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}