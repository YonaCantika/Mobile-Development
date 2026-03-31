import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Diperlukan untuk efek blur (Glassmorphism)
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Untuk validasi input
  bool _obscureText = true; // Untuk toggle mata di password

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kita panggil provider di sini
    final authProvider = Provider.of<AuthProvider>(context);

    // Variabel warna utama agar konsisten
    const primaryColor = Color(0xFF0D47A1); // Blue 900
    const accentColor = Color(0xFF1976D2);  // Blue 700

    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang (Gradient atau Gambar)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
              // JIKA PAKAI GAMBAR ASSET, BUKA KOMENTAR DI BAWAH:
              // image: DecorationImage(
              //   image: AssetImage("assets/images/login_bg.png"),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),

          // Konten Utama
          Center(
            child: SingleChildScrollView( // Agar tidak error di layar kecil
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO DAN JUDUL
                    const Icon(Icons.face_retouching_natural, size: 80, color: primaryColor),
                    const SizedBox(height: 10),
                    const Text(
                      "KLIK WAJAH",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5),
                    ),
                    const Text(
                      "Smart Attendance System",
                      style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 40),

                    // KOTAK FORM (EFEK GLASSMORPHISM)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter( // EFEK BLUR KACA
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5), // Transparansi
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)), // Garis tepi halus
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // INPUT USERNAME
                                _buildTextField(
                                  controller: _userController,
                                  label: "Username",
                                  icon: Icons.person_outline,
                                  validator: (value) => value!.isEmpty ? 'Username harus diisi' : null,
                                ),
                                const SizedBox(height: 20),

                                // INPUT PASSWORD
                                _buildTextField(
                                  controller: _passController,
                                  label: "Password",
                                  icon: Icons.lock_outline,
                                  obscureText: _obscureText,
                                  // Tombol mata untuk toggle
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: accentColor),
                                    onPressed: () => setState(() => _obscureText = !_obscureText),
                                  ),
                                  validator: (value) => value!.isEmpty ? 'Password harus diisi' : null,
                                ),
                                const SizedBox(height: 30),

                                // TOMBOL LOGIN
                                authProvider.isLoading 
                                  ? const CircularProgressIndicator(color: primaryColor) 
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 5,
                                          shadowColor: primaryColor.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      await authProvider.login(_userController.text, _passController.text);
      
      if (mounted) {
        // PINDAH KE HALAMAN BARU
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
},
                                        child: const Text("MASUK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // FOOTER
                    const Text("© 2026 KlikWajah Inc. All Rights Reserved", style: TextStyle(color: accentColor, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER WIDGET UNTUK BIKIN INPUT FIELD LEBIH RAPI
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    const accentColor = Color(0xFF1976D2);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: accentColor),
        prefixIcon: Icon(icon, color: accentColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        // Gaya border saat diam
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentColor.withOpacity(0.3))),
        // Gaya border saat diklik
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentColor, width: 2)),
        // Gaya border saat error
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }
}