import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../reader/app_description.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final double cardBorderRadius = 16.0;
  final double cardPadding = 12.0;
  final double cardSpacing = 14.0;
  final double coverWidth = 85.0;
  final double coverHeight = 85.0;
  final double coverBorderRadius = 10.0;
  final double titleFontSize = 17.0;
  final double descFontSize = 12.5;
  final double dividerThickness = 0.8;
  final double dividerVerticalPadding = 6.0;


  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  final List<String> bannedWords = [
    'porn',
    'hentai',
    'loli',
    'sex',
    'boobs',
    'dick',
    'penis',
    'vagina',
    'pussy',
    'nude',
    'naked',
    'cum',
    'milf',
    'bdsm',
    'fetish',
    'horny',
    'nsfw',
    'ecchi',
    'smut',
    'yaoi',
    'yuri',
    'bl',
    'gl',
    'boys love',
    'girls love',
    'boyslove',
    'girlslove',
    'shota',
    'rape',
    'incest',
    'fuck',
    'fucking',
    'anal',
    'oral',
    'blowjob',
    'boob',
    'tits',
    'ass',
    'thigh',
    'harem',
  ];

  bool containsBannedWord(String text) {
    final lower = text.toLowerCase();

    for (final word in bannedWords) {
      if (lower.contains(word)) {
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      debugPrint('Sayop sa pagkuha sa cover: $e');
    }
    return null;
  }

  Future<void> searchManga(String query) async {
    if (query.trim().isEmpty) return;

    if (containsBannedWord(query)) {
      setState(() {
        hasSearched = true;
        isLoading = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
      searchResults = [];
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga'
          '?limit=20'
          '&title=${Uri.encodeComponent(query.trim())}'
          '&includes[]=cover_art'
          '&contentRating[]=safe'
          '&hasAvailableChapters=true'
          '&availableTranslatedLanguage[]=en'
          '&excludedTags[]=5920b825-4181-4a17-beeb-9918b0ff7a30'
          '&excludedTags[]=a3c67850-4684-404e-9b7f-c69850ee5da6'
          '&excludedTags[]=2d1f5d56-a1e5-4d0d-a961-2193588b08ec'
          '&excludedTags[]=f04b3eb7-56d6-4c4b-9fdd-3a7f8b9c3407'
          '&excludedTagsMode=AND'
          '&order[relevance]=desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mangaList = data['data'] as List;

        List<Map<String, dynamic>> results = [];

        for (final manga in mangaList) {
          final mangaId = manga['id'];
          final attributes = manga['attributes'];

          final title = attributes['title']['en'] ??
              attributes['title'].values.first;

          String fullDesc = attributes['description']['en'] ??
              (attributes['description'].isNotEmpty
                  ? attributes['description'].values.first
                  : 'No description available.');

          final relationships = manga['relationships'] as List;

          final tags = attributes['tags'] as List;

          bool isBanned = false;

          if (containsBannedWord(title.toString())) {
            isBanned = true;
          }

          if (containsBannedWord(fullDesc.toString())) {
            isBanned = true;
          }

          for (final tag in tags) {
            final tagName =
                tag['attributes']['name']['en']?.toString().toLowerCase() ?? '';

            if (containsBannedWord(tagName)) {
              isBanned = true;
              break;
            }
          }

          if (isBanned) {
            continue;
          }

          final sentences = fullDesc.split(RegExp(r'(?<=[.!?])\s+'));
          final shortDesc = sentences.take(2).join(' ');

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
            'title': title,
            'description': shortDesc,
            'coverUrl': coverUrl,
          });
        }

        if (mounted) {
          setState(() {
            searchResults = results;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa search results: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
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
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: coverWidth,
                      height: coverHeight,
                      color: const Color(0xFF454545),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
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
                    padding: EdgeInsets.symmetric(vertical: dividerVerticalPadding),
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
                      Transform.translate( // Mao ni ang Search header
                        offset: const Offset(-14, -25),
                        child: const Text(
                          'Search',
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
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => searchManga(value),
                          decoration: InputDecoration(
                            hintText: 'Search manga or manwha...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        searchResults = [];
                                        hasSearched = false;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (value) => setState(() {}),
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
                      : !hasSearched
                          ? const Center(
                              child: Text(
                                'Type to search manga or manwha',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : searchResults.isEmpty
                              // Kung walay results
                              ? const Center(
                                  child: Text(
                                    'No results found',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: cardSpacing),
                                      child: _buildMangaCard(searchResults[index]),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: 0,
            left: 355,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
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
}