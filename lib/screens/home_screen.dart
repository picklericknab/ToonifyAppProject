import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonifyapp/screens/horror_screen.dart';
import 'package:toonifyapp/screens/profile_screen.dart';
import 'featured_screen.dart';
import 'popular_screen.dart';
import 'romance_screen.dart';
import 'action_screen.dart';
import 'history_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Size sa mga box usba lang
  static const double smallBoxSize = 115.0;
  static const double largeBoxSize = 130.0;
  static const double boxSpacing = 10.0;
  static const double boxBorderRadius = 20.0;

  String? featuredCoverUrl;
  bool isLoadingFeatured = true;
  List<String?> popularCoverUrls = [];
  bool isLoadingPopular = true;

  @override
  void initState() {
    super.initState();
    fetchFeaturedCover();
    fetchPopularCovers();
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

  // Sa feature banner na cover
  Future<void> fetchFeaturedCover() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=1&order[rating]=desc&includes[]=cover_art&contentRating[]=safe',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final manga = data['data'][0];
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
            featuredCoverUrl = coverUrl;
            isLoadingFeatured = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa featured cover: $e');
      if (mounted) setState(() => isLoadingFeatured = false);
    }
  }

  // Tung 5 ka box cover image
  Future<void> fetchPopularCovers() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=5&order[followedCount]=desc&includes[]=cover_art&contentRating[]=safe',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

        List<String?> urls = [];
        for (final manga in mangaList) {
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
          urls.add(coverUrl);
        }

        if (mounted) {
          setState(() {
            popularCoverUrls = urls;
            isLoadingPopular = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa popular covers: $e');
      if (mounted) setState(() => isLoadingPopular = false);
    }
  }

  // Loading kung wapay sulod kay hinay net
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

  // Mao ni sa COVER image
  Widget _buildPopularBox({
    required String? coverUrl,
    required double width,
    required double height,
  }) {
    if (coverUrl == null) {
      return _buildLoadingBox(width: width, height: height);
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PopularScreen()),
        );
      },
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
              icon: Icon(Icons.home, color: Colors.white, size: 28.sp),
              onPressed: () {},
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
          // Mao ni ang Main part ari lang usba
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
                      Transform.translate( // Mao ni ang Toonify header
                        offset: Offset(-14.w, -25.h),
                        child: Text(
                          'Toonify',
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
                      // Sa search bar na page
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
                          SizedBox(width: 40.w),
                          _GenreChip(
                            label: 'Action',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ActionScreen()),
                            ),
                          ),
                          SizedBox(width: 40.w),
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
                      Text( // Featured section title
                        'Featured',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h), // Space sa ubos sa Featured title
                      isLoadingFeatured
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FeaturedScreen(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: featuredCoverUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: featuredCoverUrl!,
                                        width: double.infinity,
                                        height: 160.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
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
                      SizedBox(height: 10.h), // Space sa ubos sa Featured banner
                      Text( // Popular section title
                        'Popular',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 14.h), // Space sa ubos sa Popular title
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // 3 small boxes sa taas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPopularBox(
                              coverUrl: isLoadingPopular || popularCoverUrls.isEmpty
                                  ? null
                                  : popularCoverUrls[0],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                            ),
                            _buildPopularBox(
                              coverUrl: isLoadingPopular || popularCoverUrls.length < 2
                                  ? null
                                  : popularCoverUrls[1],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                            ),
                            _buildPopularBox(
                              coverUrl: isLoadingPopular || popularCoverUrls.length < 3
                                  ? null
                                  : popularCoverUrls[2],
                              width: smallBoxSize.w,
                              height: smallBoxSize.h,
                            ),
                          ],
                        ),
                        SizedBox(height: boxSpacing.h),
                        // 2 large boxes sa ubos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: boxSpacing.w),
                              child: _buildPopularBox(
                                coverUrl: isLoadingPopular || popularCoverUrls.length < 4
                                    ? null
                                    : popularCoverUrls[3],
                                width: largeBoxSize.w,
                                height: largeBoxSize.h,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: boxSpacing.w),
                              child: _buildPopularBox(
                                coverUrl: isLoadingPopular || popularCoverUrls.length < 5
                                    ? null
                                    : popularCoverUrls[4],
                                width: largeBoxSize.w,
                                height: largeBoxSize.h,
                              ),
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