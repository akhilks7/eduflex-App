import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching note URLs



class ViewNotesScreen extends StatelessWidget {
  // Sample data (replace with your actual data source, e.g., API or database)
  final List<Note> notes = [
    Note(id: 1, noteUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
    Note(id: 2, noteUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
    Note(id: 3, noteUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Notes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF007BFF), // Blue header
        elevation: 4,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% width
          constraints: BoxConstraints(maxWidth: 1000),
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notes List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteItem(
                      serialNumber: index + 1,
                      noteUrl: note.noteUrl,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model for Note data
class Note {
  final int id;
  final String noteUrl;

  Note({required this.id, required this.noteUrl});
}

// Widget for each note item
class NoteItem extends StatelessWidget {
  final int serialNumber;
  final String noteUrl;

  NoteItem({required this.serialNumber, required this.noteUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () => _launchNoteUrl(noteUrl),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Color(0xFFF1F1F1), // Hover effect
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Serial Number
              SizedBox(
                width: 50,
                child: Text(
                  '$serialNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Note Link
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFF007BFF),
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'View Note',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF007BFF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Launch the note URL (e.g., download or open in browser)
  Future<void> _launchNoteUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // Open externally
    } else {
      print('Could not launch $url');
    }
  }
}