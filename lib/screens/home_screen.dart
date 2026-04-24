import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toonifyapp/screens/horror_screen.dart';
import 'featured_screen.dart';
import 'popular_screen.dart';
import 'romance_screen.dart';
import 'action_screen.dart';

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
        // I-build ang full image URL
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
        borderRadius: BorderRadius.circular(boxBorderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
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
        borderRadius: BorderRadius.circular(boxBorderRadius),
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
              borderRadius: BorderRadius.circular(boxBorderRadius),
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
        height: 65,
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
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.menu_book, color: Colors.grey, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.grey, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            left: 40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 230, 230),
                borderRadius: BorderRadius.circular(180),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: 70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -75,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          Positioned(
            bottom: -135,
            right: -75,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          // Mao ni ang Main part ari lang usba
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Transform.translate( // Mao ni ang Toonify header
                        offset: const Offset(-14, -25),
                        child: const Text(
                          'Toonify',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 37,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 45), // Space ubos sa header
                      Container( // Mao ni ang search bar
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D3D3D),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Space sa ubos sa search bar
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
                          const SizedBox(width: 40),
                          _GenreChip(
                            label: 'Action',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ActionScreen()),
                            ),
                          ),
                          const SizedBox(width: 40),
                          _GenreChip(
                            label: 'Horror',
                            onTap:() => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HorrorScreen())
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), 
                      const Text( // Featured section title
                        'Featured',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12), // Space sa ubos sa Featured title
                      isLoadingFeatured
                          ? Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color(0xFF454545),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
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
                                borderRadius: BorderRadius.circular(16),
                                child: featuredCoverUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: featuredCoverUrl!,
                                        width: double.infinity,
                                        height: 160,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          width: double.infinity,
                                          height: 160,
                                          color: const Color(0xFF454545),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        errorWidget:
                                            (context, url, error) =>
                                                Container(
                                          width: double.infinity,
                                          height: 160,
                                          color: const Color(0xFF454545),
                                          child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 160,
                                        color: const Color(0xFF454545),
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                              ),
                            ),
                      const SizedBox(height: 10), // Space sa ubos sa Featured banner
                      const Text( // Popular section title
                        'Popular',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14), // Space sa ubos sa Popular title
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // 3 small boxes sa taas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPopularBox(
                              coverUrl: isLoadingPopular ||
                                      popularCoverUrls.isEmpty
                                  ? null
                                  : popularCoverUrls[0],
                              width: smallBoxSize,
                              height: smallBoxSize,
                            ),
                            _buildPopularBox(
                              coverUrl: isLoadingPopular ||
                                      popularCoverUrls.length < 2
                                  ? null
                                  : popularCoverUrls[1],
                              width: smallBoxSize,
                              height: smallBoxSize,
                            ),
                            _buildPopularBox(
                              coverUrl: isLoadingPopular ||
                                      popularCoverUrls.length < 3
                                  ? null
                                  : popularCoverUrls[2],
                              width: smallBoxSize,
                              height: smallBoxSize,
                            ),
                          ],
                        ),
                        const SizedBox(height: boxSpacing),
                        // 2 large boxes sa ubos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: boxSpacing),
                              child: _buildPopularBox(
                                coverUrl: isLoadingPopular ||
                                        popularCoverUrls.length < 4
                                    ? null
                                    : popularCoverUrls[3],
                                width: largeBoxSize,
                                height: largeBoxSize,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: boxSpacing),
                              child: _buildPopularBox(
                                coverUrl: isLoadingPopular ||
                                        popularCoverUrls.length < 5
                                    ? null
                                    : popularCoverUrls[4],
                                width: largeBoxSize,
                                height: largeBoxSize,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20), // Space sa ubos sa grid
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 5, 0, 0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}