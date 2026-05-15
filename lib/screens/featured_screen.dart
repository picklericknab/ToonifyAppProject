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
import '../services/auth_service.dart';

class FeaturedScreen extends StatefulWidget {
  const FeaturedScreen({super.key});

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {

  static const double smallBoxSize = 100.0;
  static const double largeBoxSize = 100.0;
  static const double boxSpacing = 10.0;
  static const double boxBorderRadius = 20.0;

  static const List<String> _bannedTags = [
    'yaoi', 'boys\' love', 'bl', 'yuri', 'girls\' love', 'gl',
    'sexual violence', 'ecchi', 'harem', 'reverse harem', 'incest',
    'fetish', 'bdsm', 'mature', 'ero', 'erotica', 'pornographic',
    'smut', 'nsfw', 'lewd', 'fan service', 'fanservice', 'nudity',
    'sexual content', 'sex', 'rape', 'gore', 'graphic violence',
    'violence', 'abuse', 'prostitution', 'cheating', 'adultery',
    'monster girl', 'succubus', 'milf', 'loli', 'shotacon',
    'crossdressing', 'gender bender', 'polyamory', 'magic sex',
    'teacher student', 'student teacher', 'age gap',
  ];

  Map<String, dynamic>? hotManga;
  bool isLoadingHot = true;
  List<Map<String, dynamic>> recommendedList = [];
  bool isLoadingRecommended = true;

  String? _ageRange;

  @override
  void initState() {
    super.initState();
    _loadAgeRangeAndFetch();
  }

  Future<void> _loadAgeRangeAndFetch() async {
    final user = AuthService.currentUser;
    if (user != null && user.email != null) {
      _ageRange = await AuthService.getAgeRange(user.email!);
    }
    fetchHotManga();
    fetchRecommendedManga();
  }

  List<String> _contentRatingsForAge(String? ageRange) {
    if (ageRange == 'Under 13') {
      return ['safe'];
    } else if (ageRange == '13 – 17') {
      return ['safe', 'suggestive'];
    } else {
      return ['safe', 'suggestive'];
    }
  }

  bool _mangaHasBannedTag(Map<String, dynamic> manga) {
    final attributes = manga['attributes'] as Map<String, dynamic>?;
    if (attributes == null) return false;

    final tags = attributes['tags'] as List?;
    if (tags == null) return false;

    for (final tag in tags) {
      final tagName = (tag['attributes']?['name']?['en'] ?? '').toString().toLowerCase();
      if (_bannedTags.contains(tagName)) return true;
    }

    final contentRating = (attributes['contentRating'] ?? '').toString().toLowerCase();
    if (contentRating == 'pornographic' || contentRating == 'erotica') return true;

    return false;
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

  // Hot based na manga part
  Future<void> fetchHotManga() async {
    try {
      final ratings = _contentRatingsForAge(_ageRange);
      final ratingsQuery = ratings.map((r) => 'contentRating[]=$r').join('&');

      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=20&order[latestUploadedChapter]=desc&includes[]=cover_art&$ratingsQuery',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

        for (final manga in mangaList) {

          if (_mangaHasBannedTag(manga)) continue;

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

          if (mounted) {
            setState(() {
              hotManga = {
                'id': mangaId,
                'title': manga['attributes']['title']['en'] ??
                    manga['attributes']['title'].values.first,
                'coverUrl': coverUrl,
              };
              isLoadingHot = false;
            });
          }
          break;
        }

        if (mounted && isLoadingHot) {
          setState(() => isLoadingHot = false);
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa hot manga: $e');
      if (mounted) setState(() => isLoadingHot = false);
    }
  }

  // Sa recommended na manga part
  Future<void> fetchRecommendedManga() async {
    try {
      final ratings = _contentRatingsForAge(_ageRange);
      final ratingsQuery = ratings.map((r) => 'contentRating[]=$r').join('&');

      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=20&order[createdAt]=desc&includes[]=cover_art&$ratingsQuery',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

        List<Map<String, dynamic>> results = [];
        for (final manga in mangaList) {

          if (_mangaHasBannedTag(manga)) continue;

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
            recommendedList = results;
            isLoadingRecommended = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa recommended manga: $e');
      if (mounted) setState(() => isLoadingRecommended = false);
    }
  }

  // Loading box bastsa way sud
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
                      Transform.translate(
                        offset: Offset(-14.w, -25.h),
                        child: Text(
                          'Featured',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 37.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 45.h),
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
                      SizedBox(height: 20.h),
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
                      SizedBox(height: 20.h),
                      Text(
                        'Hot',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      isLoadingHot
                          ? Container(
                              width: double.infinity,
                              height: 160.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF454545),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: hotManga != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AppDescription(
                                            mangaId: hotManga!['id'],
                                            title: hotManga!['title'],
                                            coverUrl: hotManga!['coverUrl'] ?? '',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: hotManga?['coverUrl'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: hotManga!['coverUrl'],
                                        width: double.infinity,
                                        height: 160.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          width: double.infinity,
                                          height: 160.h,
                                          color: const Color(0xFF454545),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.w,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: double.infinity,
                                          height: 160.h,
                                          color: const Color(0xFF454545),
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 160.h,
                                        color: const Color(0xFF454545),
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                              ),
                            ),
                      SizedBox(height: 10.h),
                      Text(
                        'Recommended',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended || recommendedList.isEmpty
                                  ? null
                                  : recommendedList[0]['coverUrl'],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                              mangaData: isLoadingRecommended || recommendedList.isEmpty
                                  ? null
                                  : recommendedList[0],
                            ),
                            SizedBox(width: boxSpacing.w),
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended || recommendedList.length < 2
                                  ? null
                                  : recommendedList[1]['coverUrl'],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                              mangaData: isLoadingRecommended || recommendedList.length < 2
                                  ? null
                                  : recommendedList[1],
                            ),
                            SizedBox(width: boxSpacing.w),
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended || recommendedList.length < 3
                                  ? null
                                  : recommendedList[2]['coverUrl'],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                              mangaData: isLoadingRecommended || recommendedList.length < 3
                                  ? null
                                  : recommendedList[2],
                            ),
                          ],
                        ),
                        SizedBox(height: boxSpacing.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended || recommendedList.length < 4
                                  ? null
                                  : recommendedList[3]['coverUrl'],
                              width: largeBoxSize.w,
                              height: largeBoxSize.h,
                              mangaData: isLoadingRecommended || recommendedList.length < 4
                                  ? null
                                  : recommendedList[3],
                            ),
                            SizedBox(width: boxSpacing.w),
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended || recommendedList.length < 5
                                  ? null
                                  : recommendedList[4]['coverUrl'],
                              width: largeBoxSize.w,
                              height: largeBoxSize.h,
                              mangaData: isLoadingRecommended || recommendedList.length < 5
                                  ? null
                                  : recommendedList[4],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
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