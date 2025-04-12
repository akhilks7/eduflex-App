import 'package:flutter/material.dart';

class PrerecordedClassScreenv extends StatefulWidget {
  const PrerecordedClassScreenv({super.key});

  @override
  State<PrerecordedClassScreenv> createState() => _PrerecordedClassScreenvState();
}

class _PrerecordedClassScreenvState extends State<PrerecordedClassScreenv> {
  final List<Map<String, dynamic>> classContent = [
    {
      'id': 1,
      'title': 'Class 1: Introduction',
      'videoUrl': 'https://example.com/video1.mp4',
      'notes': 'Basic concepts and overview of the course...',
    },
    {
      'id': 2,
      'title': 'Class 2: Fundamentals',
      'videoUrl': 'https://example.com/video2.mp4',
      'notes': 'Key principles and foundations...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prerecorded Classes'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: classContent.length,
          itemBuilder: (context, index) {
            final content = classContent[index];
            return ClassCard(
              id: content['id'],
              title: content['title'],
              videoUrl: content['videoUrl'],
              notes: content['notes'],
            );
          },
        ),
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final int id;
  final String title;
  final String videoUrl;
  final String notes;

  const ClassCard({
    super.key,
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Video Section
            Row(
              children: [
                Icon(Icons.video_library, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Playing: $title')),
                      );
                      // Add video player implementation here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Play Video',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class Notes:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesViewScreen(
                                id: id,
                                title: title,
                                notes: notes,
                              ),
                            ),
                          );
                        },
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Notes View Screen
class NotesViewScreen extends StatelessWidget {
  final int id;
  final String title;
  final String notes;

  const NotesViewScreen({
    super.key,
    required this.id,
    required this.title,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            notes,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

