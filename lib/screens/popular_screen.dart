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

class PopularScreen extends StatefulWidget {
  const PopularScreen({super.key});

  @override
  State<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  // Size sa mga box usba lang
  static const double boxBorderRadius = 20.0;
  static const double wideBannerHeight = 160.0;
  static const double mediumBoxSize = 155.0;

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
          // Error icon basta way sud
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
          // Mao ni ang Main part
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
                      Transform.translate( // Mao ni ang Popular header
                        offset: const Offset(-14, -25),
                        child: const Text(
                          'Popular',
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
                            onTap:() => Navigator.push(
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
                      const SizedBox(height: 24), 
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 33),
                    child: Column(
                      children: [
                        _buildCoverImage(
                          coverUrl: isLoading || popularList.isEmpty
                              ? null
                              : popularList[0]['coverUrl'],
                          width: double.infinity,
                          height: wideBannerHeight,
                          mangaData: isLoading || popularList.isEmpty
                              ? null
                              : popularList[0],
                        ),
                        const SizedBox(height: 28), // Space ubos sa wide banner
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 2
                                  ? null
                                  : popularList[1]['coverUrl'],
                              width: mediumBoxSize,
                              height: mediumBoxSize,
                              mangaData: isLoading || popularList.length < 2
                                  ? null
                                  : popularList[1],
                            ),
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 3
                                  ? null
                                  : popularList[2]['coverUrl'],
                              width: mediumBoxSize,
                              height: mediumBoxSize,
                              mangaData: isLoading || popularList.length < 3
                                  ? null
                                  : popularList[2],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28), // Space sa tunga sa rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 4
                                  ? null
                                  : popularList[3]['coverUrl'],
                              width: mediumBoxSize,
                              height: mediumBoxSize,
                              mangaData: isLoading || popularList.length < 4
                                  ? null
                                  : popularList[3],
                            ),
                            _buildCoverImage(
                              coverUrl: isLoading || popularList.length < 5
                                  ? null
                                  : popularList[4]['coverUrl'],
                              width: mediumBoxSize,
                              height: mediumBoxSize,
                              mangaData: isLoading || popularList.length < 5
                                  ? null
                                  : popularList[4],
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