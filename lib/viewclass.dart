import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Add this package
import 'package:url_launcher/url_launcher.dart'; // Add this package



class PrerecordedClassScreen extends StatelessWidget {
  // Sample data (replace with your actual data source)
  final List<ClassFile> classFiles = [
    ClassFile(id: 1, videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'),
    ClassFile(id: 2, videoUrl: null), // Simulating no file
    ClassFile(id: 3, videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prerecorded Class'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: classFiles.length,
          itemBuilder: (context, index) {
            final classFile = classFiles[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Serial Number
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Video or No File Message
                    Expanded(
                      child: classFile.videoUrl != null
                          ? VideoWidget(videoUrl: classFile.videoUrl!)
                          : Text(
                              'No file available',
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                    // Action Buttons
                    SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              _navigateToAssignment(context, classFile.id);
                            },
                            child: Text('View Assignment'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue),
                            ),
                          ),
                          SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              _navigateToNotes(context, classFile.id);
                            },
                            child: Text('View Note'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Simulate navigation to assignment
  void _navigateToAssignment(BuildContext context, int id) {
    // Replace with actual navigation logic or URL
    final url = 'https://example.com/user/viewassignment/$id';
    _launchUrl(url);
  }

  // Simulate navigation to notes
  void _navigateToNotes(BuildContext context, int id) {
    // Replace with actual navigation logic or URL
    final url = 'https://example.com/user/viewnotes/$id';
    _launchUrl(url);
  }

  // Launch URL (for external links)
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }
}

// Model for class file data
class ClassFile {
  final int id;
  final String? videoUrl;

  ClassFile({required this.id, this.videoUrl});
}

// Widget for video playback
class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Update UI when video is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SizedBox(
            width: 200,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: 200,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
  }
}