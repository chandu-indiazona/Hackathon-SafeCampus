import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();

  // Post a new message
  Future<void> _createPost(String content) async {
    try {
      String randomAuthor = "Anonymous"; // Default author if no name is provided
      await FirebaseFirestore.instance.collection('posts').add({
        'author': randomAuthor,
        'content': content,
        'phone': null,
        'google_maps_url': null, // Add actual URL here if required
        'timestamp': FieldValue.serverTimestamp(),
      });

      _postController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post shared successfully!')),
      );
    } catch (e) {
      print("Error creating post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing post. Try again later!')),
      );
    }
  }

  // Launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Chat'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading posts. Please try again later.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts available yet. Be the first to post!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final posts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Post(
                    author: data['author'] ?? 'Anonymous',
                    content: data['content'] ?? 'No content provided.',
                    timestamp: (data['timestamp'] as Timestamp?)
                        ?.toDate()
                        .toString(),
                    phone: data['phone'],
                    google_maps_url: data['google_maps_url'],
                  );
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Text(
                                    post.author[0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.author,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      post.timestamp ?? 'Unknown time',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              post.content,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[800]),
                            ),
                            if (post.phone != null) ...[
                              SizedBox(height: 8),
                              Text(
                                'Phone: ${post.phone}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                            // Add a button to launch the Google Maps URL
                            if (post.google_maps_url != null)
                              ElevatedButton(
                                onPressed: () => _launchURL(post.google_maps_url!),
                                child: Text('View on Google Maps'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _postController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final content = _postController.text.trim();
              if (content.isNotEmpty) {
                _createPost(content);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter some text!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Post {
  final String author;
  final String content;
  final String? timestamp;
  final String? phone;
  final String? google_maps_url;

  Post({
    required this.author,
    required this.content,
    this.timestamp,
    this.phone,
    this.google_maps_url,
  });
}
