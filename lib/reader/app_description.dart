import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'app_reader.dart';

class AppDescription extends StatefulWidget {
  
  final String mangaId;
  final String title;
  final String coverUrl;

  const AppDescription({
    super.key,
    required this.mangaId,
    required this.title,
    required this.coverUrl,
  });

  @override
  State<AppDescription> createState() => _AppDescriptionState();
}

class _AppDescriptionState extends State<AppDescription> {

  // Blur o height sa banner
  final double blurAmount = 6.0;
  final double bannerHeight = 240.0;
  
  // Size sa cover
  final double coverWidth = 130.0;
  final double coverHeight = 190.0;
  final double coverOverlap = 90.0;

  // Sa description container
  final double descContainerTopOffset = 30.0;
  final double descContainerHeight = 340.0;
  final double descFontSize = 18.5;

  // Ari usba ang start reading button
  final double buttonWidth = 260.0;
  final double buttonHeight = 55.0;
  final double buttonRadius = 30.0;
  final double buttonBottomPadding = 50.0;

  String description = '';
  bool isLoadingDescription = true;

  final ScrollController _descScrollController = ScrollController();
  int savedChapterIndex = 0;
  double savedScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDescription();
  }

  @override
  void dispose() {
    _descScrollController.dispose();
    super.dispose();
  }

  // MangaDEX API sa description na part
  Future<void> fetchDescription() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mangadex.org/manga/${widget.mangaId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attributes = data['data']['attributes'];

        // Description usba ang 3 if punan inyo
        String fullDesc = attributes['description']['en'] ??
            (attributes['description'].isNotEmpty
                ? attributes['description'].values.first
                : 'No description available.');

        final sentences = fullDesc.split(RegExp(r'(?<=[.!?])\s+'));
        final summarized = sentences.take(3).join(' ');

        if (mounted) {
          setState(() {
            description = summarized;
            isLoadingDescription = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Sayop sa pagkuha sa description: $e');
      if (mounted) {
        setState(() {
          description = 'No description available.';
          isLoadingDescription = false;
        });
      }
    }
  }

  Future<void> _openReader() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppReader(
          mangaId: widget.mangaId,
          title: widget.title,
          initialChapterIndex: savedChapterIndex,
          initialScrollOffset: savedScrollOffset,
        ),
      ),
    );

    // If nag scroll unsa na chpater kay ari ma save if mag ask si sir
    if (result != null && result is Map) {
      setState(() {
        savedChapterIndex = result['chapterIndex'] ?? 0;
        savedScrollOffset = result['scrollOffset'] ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double coverStartY = bannerHeight - coverOverlap;
    final double coverEndY = coverStartY + coverHeight;
    final double descTop = coverEndY + descContainerTopOffset;

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: Stack(
        children: [

          // Sa top banner na part
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: const Color(0xFF3D3D3D)),
                  errorWidget: (context, url, error) =>
                      Container(color: const Color(0xFF3D3D3D)),
                ),
                // Blur effect ilisdi lang nya ari
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF2A2A2A)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Naa dri ang background
          Positioned(
            top: bannerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: const Color(0xFF2A2A2A)),
          ),

          // Sa cover Image
          Positioned(
            top: coverStartY,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.coverUrl,
                width: coverWidth,
                height: coverHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: coverWidth,
                  height: coverHeight,
                  color: const Color(0xFF454545),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: coverWidth,
                  height: coverHeight,
                  color: const Color(0xFF454545),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Title sa manga
          Positioned(
            top: coverStartY + (coverHeight * 0.55),
            left: coverWidth + 28,
            right: 16,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                height: 1.3,
              ),
            ),
          ),

          // Sa description na part
          Positioned(
            top: descTop,
            left: 16,
            right: 16,
            child: ClipRect(
              child: SizedBox(
                height: descContainerHeight,
                child: isLoadingDescription
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : SingleChildScrollView(
                        controller: _descScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          description,
                          textAlign: TextAlign.justify, 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: descFontSize,
                            height: 1.7, 
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Ari usba ang sa start reading na button
          Positioned(
            bottom: buttonBottomPadding,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _openReader,
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                  child: const Center(
                    child: Text(
                      'Start Reading',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8), 
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 100,  // Usba lang nya dri ang width sa back button
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
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
    );
  }
}