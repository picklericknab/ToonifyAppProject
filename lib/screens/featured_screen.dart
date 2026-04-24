import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toonifyapp/screens/history_screen.dart';
import '../reader/app_description.dart';
import 'home_screen.dart';
import 'romance_screen.dart';
import 'action_screen.dart';
import 'horror_screen.dart';

class FeaturedScreen extends StatefulWidget {
  const FeaturedScreen({super.key});

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  // Size sa mga box usba lang
  static const double smallBoxSize = 115.0;
  static const double largeBoxSize = 130.0;
  static const double boxSpacing = 10.0;
  static const double boxBorderRadius = 20.0;

  Map<String, dynamic>? hotManga;
  bool isLoadingHot = true;
  List<Map<String, dynamic>> recommendedList = [];
  bool isLoadingRecommended = true;

  @override
  void initState() {
    super.initState();
    fetchHotManga();
    fetchRecommendedManga();
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
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=20&order[latestUploadedChapter]=desc&includes[]=cover_art&contentRating[]=safe&hasAvailableChapters=true&availableTranslatedLanguage[]=en',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

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
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga?limit=20&order[createdAt]=desc&includes[]=cover_art&contentRating[]=safe&hasAvailableChapters=true&availableTranslatedLanguage[]=en',
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
              icon: const Icon(Icons.home, color: Colors.grey, size: 28),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu_book, color: Colors.grey, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
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
                      Transform.translate( // Mao ni ang Featured header
                        offset: const Offset(-14, -25),
                        child: const Text(
                          'Featured',
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
                      Container( 
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
                            onTap:() => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ActionScreen()),
                            ),
                          ),
                          const SizedBox(width: 40),
                          _GenreChip(
                            label: 'Horror',
                            onTap:() => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HorrorScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Space sa ubos sa chips
                      const Text( 
                        'Hot',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12), // Space sa ubos sa Featured title
                      isLoadingHot
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
                              onTap: hotManga != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AppDescription(
                                            mangaId: hotManga!['id'],
                                            title: hotManga!['title'],
                                            coverUrl:
                                                hotManga!['coverUrl'] ?? '',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: hotManga?['coverUrl'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: hotManga!['coverUrl'],
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
                      const SizedBox(height: 10), // Space sa ubos sa Hot banner
                      const Text( 
                        'Recommended',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14), // Space sa ubos sa Recommended title
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended ||
                                      recommendedList.isEmpty
                                  ? null
                                  : recommendedList[0]['coverUrl'],
                              width: smallBoxSize,
                              height: smallBoxSize,
                              mangaData: isLoadingRecommended ||
                                      recommendedList.isEmpty
                                  ? null
                                  : recommendedList[0],
                            ),
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended ||
                                      recommendedList.length < 2
                                  ? null
                                  : recommendedList[1]['coverUrl'],
                              width: smallBoxSize,
                              height: smallBoxSize,
                              mangaData: isLoadingRecommended ||
                                      recommendedList.length < 2
                                  ? null
                                  : recommendedList[1],
                            ),
                            _buildCoverImage(
                              coverUrl: isLoadingRecommended ||
                                      recommendedList.length < 3
                                  ? null
                                  : recommendedList[2]['coverUrl'],
                              width: smallBoxSize,
                              height: smallBoxSize,
                              mangaData: isLoadingRecommended ||
                                      recommendedList.length < 3
                                  ? null
                                  : recommendedList[2],
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
                              child: _buildCoverImage(
                                coverUrl: isLoadingRecommended ||
                                        recommendedList.length < 4
                                    ? null
                                    : recommendedList[3]['coverUrl'],
                                width: largeBoxSize,
                                height: largeBoxSize,
                                mangaData: isLoadingRecommended ||
                                        recommendedList.length < 4
                                    ? null
                                    : recommendedList[3],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: boxSpacing),
                              child: _buildCoverImage(
                                coverUrl: isLoadingRecommended ||
                                        recommendedList.length < 5
                                    ? null
                                    : recommendedList[4]['coverUrl'],
                                width: largeBoxSize,
                                height: largeBoxSize,
                                mangaData: isLoadingRecommended ||
                                        recommendedList.length < 5
                                    ? null
                                    : recommendedList[4],
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