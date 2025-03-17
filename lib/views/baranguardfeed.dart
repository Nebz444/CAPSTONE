import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class BaranguardFeed extends StatefulWidget {
  const BaranguardFeed({super.key});

  @override
  _BaranguardFeedState createState() => _BaranguardFeedState();
}

class _BaranguardFeedState extends State<BaranguardFeed> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('https://manibaugparalaya.com/API/fetchPost.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('posts')) {
          setState(() {
            posts = List<Map<String, dynamic>>.from(data['posts']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected response format.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load posts. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching posts: $e';
        isLoading = false;
      });
    }
  }

  void _showFullScreenGallery(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.white, title: const Text('Photo Viewer')),
            body: Center(
              child: Hero(
                tag: imageUrl,
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _askPermissionAndLaunchURL(String url) async {
    final bool permission = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Open Link'),
          content: const Text('Do you want to open this link in a browser?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open'),
            ),
          ],
        );
      },
    );

    if (permission == true) {
      await _launchURL(url);
    }
  }

  List<TextSpan> _buildTextSpans(String text, Iterable<RegExpMatch> matches) {
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _askPermissionAndLaunchURL(url),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  Widget buildPost(Map<String, dynamic> post) {
    final String postText = post['text'] ?? '';
    final RegExp urlRegex = RegExp(r"(https?://[^\s]+)");
    final Iterable<RegExpMatch> matches = urlRegex.allMatches(postText);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                post['username'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post['created_at'] ?? '',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            if (post['image_path'] != null && post['image_path'].isNotEmpty)
              GestureDetector(
                onTap: () => _showFullScreenGallery(post['image_path']),
                child: Hero(
                  tag: post['image_path'],
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        post['image_path'],
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width * 0.55, // Dynamic height
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: _buildTextSpans(postText, matches),
                ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, textAlign: TextAlign.center))
          : posts.isEmpty
          ? const Center(child: Text('No posts available.'))
          : ListView.builder(
        itemCount: posts.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => buildPost(posts[index]),
      ),
    );
  }
}