import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class AppReader extends StatefulWidget {
  // Data nga e hatag gikan sa app_description
  final String mangaId;
  final String title;
  final int initialChapterIndex;
  final double initialScrollOffset;

  const AppReader({
    super.key,
    required this.mangaId,
    required this.title,
    this.initialChapterIndex = 0,
    this.initialScrollOffset = 0.0,
  });

  @override
  State<AppReader> createState() => _AppReaderState();
}

class _AppReaderState extends State<AppReader> {
  late ScrollController _scrollController;
  List<Map<String, dynamic>> chapterList = [];
  List<Map<String, dynamic>> allPages = [];
  int currentChapterIndex = 0;

  // Loading states
  bool isLoadingChapters = true;
  bool isLoadingNextChapter = false;

  // Error message kung naay problema
  String? errorMessage;
  
  bool get hasNextChapter => currentChapterIndex < chapterList.length - 1;

  @override
  void initState() {
    super.initState();
    currentChapterIndex = widget.initialChapterIndex;

    _scrollController = ScrollController();
    fetchAllChapters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final double currentOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    Navigator.pop(context, {
      'chapterIndex': currentChapterIndex,
      'scrollOffset': currentOffset,
    });
  }

  // Mao ni nga API part nga ma fetch ang chapters
  Future<void> fetchAllChapters() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mangadex.org/manga/${widget.mangaId}/feed'
          '?limit=500&order[chapter]=asc&translatedLanguage[]=en',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chapters = data['data'] as List;

        if (chapters.isEmpty) {
          if (mounted) {
            setState(() {
              errorMessage = 'No chapters available for this manga.';
              isLoadingChapters = false;
            });
          }
          return;
        }

        // Start permi sa chapter 1
        final list = chapters
            .map((c) => {
                  'id': c['id'],
                })
            .toList();

        if (mounted) {
          setState(() {
            chapterList = list;
            isLoadingChapters = false;
          });

          await loadChapter(currentChapterIndex, isInitial: true);
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa chapters: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load chapters. Please try again.';
          isLoadingChapters = false;
        });
      }
    }
  }

  Future<void> loadChapter(int index, {bool isInitial = false}) async {
    if (index >= chapterList.length) return;

    if (!isInitial) {
      setState(() => isLoadingNextChapter = true);
    }

    try {
      final chapterId = chapterList[index]['id'];
      final sequentialNum = index + 1;
      final response = await http.get(
        Uri.parse('https://api.mangadex.org/at-home/server/$chapterId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final baseUrl = data['baseUrl'];
        final hash = data['chapter']['hash'];
        final pageFiles = data['chapter']['data'] as List;

        final pages = pageFiles
            .map((file) => {
                  'type': 'page',
                  'url': '$baseUrl/data/$hash/$file',
                  'chapterNum': sequentialNum,
                })
            .toList();

        if (mounted) {
          setState(() {
            allPages.add({
              'type': 'divider',
              // Pirme mag-start sa 1
              'chapterNum': sequentialNum,
            });
            allPages.addAll(pages);
            currentChapterIndex = index;
            isLoadingNextChapter = false;
          });

          if (isInitial && widget.initialScrollOffset > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_scrollController.hasClients &&
                    widget.initialScrollOffset <=
                        _scrollController.position.maxScrollExtent) {
                  _scrollController.jumpTo(widget.initialScrollOffset);
                }
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa pages sa chapter $index: $e');
      if (mounted) {
        setState(() => isLoadingNextChapter = false);
      }
    }
  }

  // ang sunod nga chapter
  Future<void> loadNextChapter() async {
    if (!hasNextChapter || isLoadingNextChapter) return;
    await loadChapter(currentChapterIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Ma save ang progress since ang back button ang gigamit
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _handleBack();
        },
        child: Stack(
          children: [

            // MANGA PAGES
            isLoadingChapters
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: allPages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == allPages.length) {
                            return _buildBottomWidget();
                          }

                          final item = allPages[index];

                          if (item['type'] == 'divider') {
                            return _buildChapterDivider(item['chapterNum']);
                          }

                          return CachedNetworkImage(
                            imageUrl: item['url'],
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) => Container(
                              height: 400,
                              color: Colors.black,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            // Error widget kung dili ma load ang page
                            errorWidget: (context, url, error) => Container(
                              height: 400,
                              color: const Color(0xFF1A1A1A),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

            // BACK BUTTON 
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 100,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 33,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget sa chapter divider 
  Widget _buildChapterDivider(int chapterNum) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Text(
          '— Chapter $chapterNum —',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Widget sa ubos sa list
  Widget _buildBottomWidget() {
    // Kung nag-load pa ang next chapter
    if (isLoadingNextChapter) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (hasNextChapter) {
      final nextDisplayNum = currentChapterIndex + 2;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: GestureDetector(
          onTap: loadNextChapter,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Center(
              child: Text(
                'Next Chapter — $nextDisplayNum',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          "You've reached the end!",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}