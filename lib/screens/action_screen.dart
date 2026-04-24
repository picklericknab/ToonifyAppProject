import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../reader/app_description.dart';
import 'home_screen.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  
  // Size sa card
  final double cardBorderRadius = 16.0;
  final double cardPadding = 12.0;
  final double cardSpacing = 14.0;
  
  // Sa image cover
  final double coverWidth = 85.0;
  final double coverHeight = 85.0;
  final double coverBorderRadius = 10.0;
  
  // Para sa text size
  final double titleFontSize = 17.0;
  final double descFontSize = 12.5;
  
  // Title variables
  final double dividerThickness = 0.8;
  final double dividerVerticalPadding = 6.0;

  static const int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;

  List<Map<String, dynamic>> actionList = [];
  bool isLoading = true;
  bool isLoadingMore = false;

  late ScrollController _scrollController;

  static const String _actionTagId =
      'a63fb59d-300c-4db9-bbf7-38a8b780d421';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          _hasMore) {
        fetchActionManga();
      }
    });
    fetchActionManga();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      debugPrint('Wrong cover: $e');
    }
    return null;
  }

  Future<void> fetchActionManga() async {
    if (isLoadingMore || !_hasMore) return;

    if (mounted) {
      setState(() {
        if (_offset == 0) {
          isLoading = true;
        } else {
          isLoadingMore = true;
        }
      });
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga'
          '?limit=$_pageSize'
          '&offset=$_offset'
          '&includedTags[]=$_actionTagId'
          '&includes[]=cover_art'
          '&availableTranslatedLanguage[]=en'
          '&order[followedCount]=desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;
        final total = data['total'] as int;

        List<Map<String, dynamic>> results = [];
        for (final manga in mangaList) {
          final mangaId = manga['id'];
          final attributes = manga['attributes'];

          // 2 sentences na part sa romance
          String fullDesc = attributes['description']['en'] ??
              (attributes['description'].isNotEmpty
                  ? attributes['description'].values.first
                  : 'No description available.');
          final sentences = fullDesc.split(RegExp(r'(?<=[.!?])\s+'));
          final shortDesc = sentences.take(2).join(' ');

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
            'title': attributes['title']['en'] ??
                attributes['title'].values.first,
            'description': shortDesc,
            'coverUrl': coverUrl,
          });
        }

        if (mounted) {
          setState(() {
            actionList.addAll(results);
            _offset += results.length;
            _hasMore = _offset < total;
            isLoading = false;
            isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Wrong action manga: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildMangaCard(Map<String, dynamic> manga) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppDescription(
              mangaId: manga['id'],
              title: manga['title'],
              coverUrl: manga['coverUrl'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFFB8B8B8),
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover image sa wala
            ClipRRect(
              borderRadius: BorderRadius.circular(coverBorderRadius),
              child: manga['coverUrl'] != null
                  ? CachedNetworkImage(
                      imageUrl: manga['coverUrl'],
                      width: coverWidth,
                      height: coverHeight,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: coverWidth,
                        height: coverHeight,
                        color: const Color(0xFF454545),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: coverWidth,
                        height: coverHeight,
                        color: const Color(0xFF454545),
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: coverWidth,
                      height: coverHeight,
                      color: const Color(0xFF454545),
                      child: const Icon(Icons.broken_image,
                          color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    manga['title'],
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: dividerVerticalPadding),
                    child: Divider(
                      thickness: dividerThickness,
                      color: Colors.black26,
                      height: 0,
                    ),
                  ),
                  Text(
                    manga['description'],
                    style: TextStyle(
                      fontSize: descFontSize,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
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
                      Transform.translate( // Mao ni ang Romance header
                        offset: const Offset(-14, -25),
                        child: const Text(
                          'Action',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 37,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 45),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: actionList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == actionList.length) {
                              if (isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              if (!_hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'No more results',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: cardSpacing),
                              child: _buildMangaCard(actionList[index]),
                            );
                          },
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