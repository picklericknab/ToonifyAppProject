import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonifyapp/screens/history_screen.dart';
import 'package:toonifyapp/screens/profile_screen.dart';
import '../reader/app_description.dart';
import 'home_screen.dart';
import 'romance_screen.dart';
import 'action_screen.dart';
import 'horror_screen.dart';
import 'search_screen.dart';

class PopularScreen extends StatefulWidget {
  const PopularScreen({super.key});

  @override
  State<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  // Size sa mga box usba lang
  static const double boxBorderRadius = 20.0;
  static const double wideBannerHeight = 160.0;
  static const double mediumBoxSize = 130.0;
  static const double boxSpacing = 28.0;

  List<Map<String, dynamic>> popularList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPopularManga();
  }

  Future<String?> fetchCoverUrl(String mangaId, String coverId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mangadex.org/cover/$coverId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileName = data['data']['attributes']['fileName'];
        return 'https://uploads.mangadex.org/covers/$mangaId/$fileName.256.jpg';
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa cover: $e');
    }
    return null;
  }

  // Popular section gikan sa MangaDEX
  Future<void> fetchPopularManga() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=20&order[relevance]=desc&includes[]=cover_art&contentRating[]=safe&hasAvailableChapters=true&availableTranslatedLanguage[]=en',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

        List<Map<String, dynamic>> results = [];
        for (final manga in mangaList) {
          if (results.length >= 5) break;

          final mangaId = manga['id'];
          final relationships = manga['relationships'] as List;
          final coverRel = relationships.firstWhere(
            (r) => r['type'] == 'cover_art',
            orElse: () => null,
          );

          String? coverUrl;
          if (coverRel != null) {
            coverUrl = await fetchCoverUrl(mangaId, coverRel['id']);
          }

          results.add({
            'id': mangaId,
            'title': manga['attributes']['title']['en'] ??
                manga['attributes']['title'].values.first,
            'coverUrl': coverUrl,
          });
        }

        if (mounted) {
          setState(() {
            popularList = results;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa popular manga: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildLoadingBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF454545),
        borderRadius: BorderRadius.circular(boxBorderRadius.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildCoverImage({
    required String? coverUrl,
    required double width,
    required double height,
    Map<String, dynamic>? mangaData,
  }) {
    if (coverUrl == null) {
      return _buildLoadingBox(width: width, height: height);
    }
    return GestureDetector(
      onTap: mangaData != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppDescription(
                    mangaId: mangaData['id'],
                    title: mangaData['title'],
                    coverUrl: mangaData['coverUrl'] ?? '',
                  ),
                ),
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(boxBorderRadius.r),
        child: CachedNetworkImage(
          imageUrl: coverUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _buildLoadingBox(width: width, height: height),
          // Error icon basta way sud
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF454545),
              borderRadius: BorderRadius.circular(boxBorderRadius.r),
            ),
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
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
              icon: Icon(Icons.person, color: Colors.grey, size: 28.sp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
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
          // Mao ni ang Main part
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Transform.translate( // Mao ni ang Popular header
                        offset: Offset(-14.w, -25.h),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 37.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 45.h), // Space ubos sa header
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen()),
                          );
                        },
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D3D),
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 12.w),
                              Icon(Icons.search, color: Colors.grey, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Search',
                                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h), // Space sa ubos sa search bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _GenreChip(
                            label: 'Romance',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RomanceScreen()),
                            ),
                          ),
                          SizedBox(width: 31.w),
                          _GenreChip(
                            label: 'Action',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ActionScreen()),
                            ),
                          ),
                          SizedBox(width: 32.w),
                          _GenreChip(
                            label: 'Horror',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HorrorScreen()),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 33.w),
                    child: Column(
                      children: [
                        _buildCoverImage(
                          coverUrl: isLoading || popularList.isEmpty
                              ? null
                              : popularList[0]['coverUrl'],
                          width: double.infinity,
                          height: wideBannerHeight.h,
                          mangaData: isLoading || popularList.isEmpty
                              ? null
                              : popularList[0],
                        ),
                        SizedBox(height: 20.h), // Space ubos sa wide banner
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 2
                                  ? null
                                  : popularList[1]['coverUrl'],
                              width: mediumBoxSize.w,
                              height: mediumBoxSize.h,
                              mangaData: isLoading || popularList.length < 2
                                  ? null
                                  : popularList[1],
                            ),
                            SizedBox(width: boxSpacing.w),
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 3
                                  ? null
                                  : popularList[2]['coverUrl'],
                              width: mediumBoxSize.w,
                              height: mediumBoxSize.h,
                              mangaData: isLoading || popularList.length < 3
                                  ? null
                                  : popularList[2],
                            ),
                          ],
                        ),
                        SizedBox(height: 28.h), // Space sa tunga sa rows
                                                Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 4
                                  ? null
                                  : popularList[3]['coverUrl'],
                              width: mediumBoxSize.w,
                              height: mediumBoxSize.h,
                              mangaData: isLoading || popularList.length < 4
                                  ? null
                                  : popularList[3],
                            ),
                            SizedBox(width: boxSpacing.w),
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 5
                                  ? null
                                  : popularList[4]['coverUrl'],
                              width: mediumBoxSize.w,
                              height: mediumBoxSize.h,
                              mangaData: isLoading || popularList.length < 5
                                  ? null
                                  : popularList[4],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h), // Space sa ubos sa grid
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

// Mao ni ang genre buttons sa romance etc
class _GenreChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _GenreChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 5, 0, 0),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}