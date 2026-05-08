import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _loggedInEmailKey = 'logged_in_email';

  String? _pfpPath;
  String _username = '';
  String _email = '';

  // Ang pfp key kay naka-base sa email para lain ang pfp kada account
  String get _pfpKey => 'profile_picture_path_${_email.toLowerCase()}';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_loggedInEmailKey) ?? '';
    final username = AuthService.currentUser?.displayName ??
        await AuthService.getUsername(email);
    final pfpKey = 'profile_picture_path_${email.toLowerCase()}';
    final pfp = prefs.getString(pfpKey);

    if (mounted) {
      setState(() {
        _pfpPath = pfp;
        _username = username;
        _email = email;
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3D3D3D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white, size: 24.sp),
              title: Text('Choose from Gallery',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp)),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white, size: 24.sp),
              title: Text('Take a Photo',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp)),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Ma save ang pfp based sa email na gigamit
  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        // email based key
        await prefs.setString(_pfpKey, image.path);
        if (mounted) {
          setState(() => _pfpPath = image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not access gallery or camera. Please check app permissions in your phone settings.',
              style: TextStyle(fontSize: 13.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3D3D3D),
        title: Text('Log Out',
            style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () async {
              // Logic nga mo sign out sa FIREBASE authentication
              await AuthService.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(_loggedInEmailKey);
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Log Out',
                style: TextStyle(color: Colors.redAccent, fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      bottomNavigationBar: Container(
        height: 65.h,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(color: Color(0xFF3D3D3D), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.grey, size: 28.sp),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.menu_book, color: Colors.grey, size: 28.sp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 28.sp),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -30.h,
            left: 40.w,
            child: Container(
              width: 170.w,
              height: 170.h,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 230, 230),
                borderRadius: BorderRadius.circular(180.r),
              ),
            ),
          ),
          Positioned(
            top: -80.h,
            left: 70.w,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(140.r),
              ),
            ),
          ),
          Positioned(
            top: -30.h,
            left: -50.w,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(120.r),
              ),
            ),
          ),
          Positioned(
            top: -60.h,
            right: -75.w,
            child: Container(
              width: 170.w,
              height: 170.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160.r),
              ),
            ),
          ),
          Positioned(
            bottom: -135.h,
            right: -75.w,
            child: Container(
              width: 170.w,
              height: 170.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160.r),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      SizedBox(height: 20.h),
                      Transform.translate(
                        offset: Offset(-14.w, -6.h),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 37.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Log-out sa kilid
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          width: 42.w,
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D3D),
                            borderRadius: BorderRadius.circular(21.r),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.h),
                // Profile picture sa tunga
                Center(
                  child: GestureDetector(
                    onTap: _pickProfilePicture,
                    child: Stack(
                      children: [
                        Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3.w,
                            ),
                            color: const Color(0xFF1A1A1A),
                          ),
                          child: ClipOval(
                            child: _pfpPath != null &&
                                    File(_pfpPath!).existsSync()
                                ? Image.file(
                                    File(_pfpPath!),
                                    fit: BoxFit.cover,
                                  ): 
                                  Icon(
                                    Icons.person,
                                    size: 100.sp,
                                    color: Colors.black54,
                                  ),
                          ),
                        ),
                        // Camera icon 
                        Positioned(
                          bottom: 4.h,
                          right: 4.w,
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 2.w,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Username ug email
                Center(
                  child: Column(
                    children: [
                      Text(
                        _username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _email,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // Settings row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D3D),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Downloads, Security',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}