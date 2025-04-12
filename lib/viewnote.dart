import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewNotesScreen extends StatefulWidget {
  final String classFileId;

  const ViewNotesScreen({super.key, required this.classFileId});

  @override
  State<ViewNotesScreen> createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  List<dynamic> _notes = [];
  bool _isLoading = true;
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      setState(() => _isLoading = true);
      final response = await supabase
          .from('Teacher_tbl_notes')
          .select()
          .eq('classfile_id', widget.classFileId);

      print("Notes response: $response");
      setState(() {
        _notes = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800.withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Class Notes',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchNotes,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 20),
                            Text(
                              'Loading Notes...',
                              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : _notes.isEmpty
                        ? Center(
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.note_add_outlined,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No notes available',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Check back later for updates!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchNotes,
                            color: Colors.blue,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _notes.length,
                              itemBuilder: (context, index) {
                                final note = _notes[index];
                                return FadeInUp(
                                  duration: Duration(milliseconds: 500 + (index * 100)),
                                  child: NoteItem(
                                    serialNumber: index + 1,
                                    noteUrl: note['notefile'] ?? '',
                                    noteId: note['id'],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final int serialNumber;
  final String noteUrl;
  final int noteId;

  const NoteItem({
    required this.serialNumber,
    required this.noteUrl,
    required this.noteId,
  });

  bool _isImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif');
  }

  bool _isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isDoc(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx');
  }

  String _getFileType(String url) {
    if (_isPdf(url)) return 'PDF';
    if (_isImage(url)) return 'Image';
    if (_isDoc(url)) return 'Document';
    return 'Unknown';
  }

  IconData _getFileIcon(String url) {
    if (_isPdf(url)) return Icons.picture_as_pdf;
    if (_isImage(url)) return Icons.image;
    if (_isDoc(url)) return Icons.description;
    return Icons.insert_drive_file;
  }

  String _getMimeType(String url) {
    if (_isPdf(url)) return 'application/pdf';
    if (_isImage(url)) return 'image/*';
    if (_isDoc(url)) return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    return 'application/octet-stream'; // Fallback for unknown types
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black26,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade900],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$serialNumber',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note $serialNumber',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: $noteId - ${_getFileType(noteUrl)}',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _launchNoteUrl(noteUrl, context),
                    icon: const Icon(Icons.open_in_new, size: 20),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              noteUrl.isEmpty
                  ? Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'No file available',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.red.shade700),
                        ),
                      ),
                    )
                  : _isPdf(noteUrl)
                      ? GestureDetector(
                          onTap: () => _viewFullScreen(context, noteUrl, true),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PDF(
                                swipeHorizontal: true,
                                autoSpacing: true,
                                pageFling: true,
                              ).cachedFromUrl(
                                noteUrl,
                                placeholder: (progress) => Center(
                                  child: CircularProgressIndicator(value: progress / 100),
                                ),
                                errorWidget: (error) => Center(
                                  child: Text(
                                    'Error loading PDF',
                                    style: GoogleFonts.poppins(color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : _isImage(noteUrl)
                          ? GestureDetector(
                              onTap: () => _viewFullScreen(context, noteUrl, false),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: noteUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => Center(
                                      child: Text(
                                        'Error loading image',
                                        style: GoogleFonts.poppins(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _launchNoteUrl(noteUrl, context),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getFileIcon(noteUrl),
                                        size: 60,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${_getFileType(noteUrl)} File',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Tap to open externally',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchNoteUrl(String url, BuildContext context) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No note file available')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    final mimeType = _getMimeType(url);

    try {
      // Attempt to launch with explicit MIME type
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: WebViewConfiguration(
            headers: {'Content-Type': mimeType},
          ),
        );
      } else {
        // Fallback: Try opening as a generic file download
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            headers: {'Content-Disposition': 'attachment'},
          ),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open $url. Ensure an app like Word or Docs is set to handle ${_getFileType(url).toLowerCase()} files.',
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _launchNoteUrl(url, context),
          ),
        ),
      );
    }
  }

  void _viewFullScreen(BuildContext context, String url, bool isPdf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenNoteViewer(url: url, isPdf: isPdf),
      ),
    );
  }
}

class FullScreenNoteViewer extends StatelessWidget {
  final String url;
  final bool isPdf;

  const FullScreenNoteViewer({required this.url, required this.isPdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note Viewer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch $url')),
                );
              }
            },
          ),
        ],
      ),
      body: isPdf
          ? PDF(
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
            ).cachedFromUrl(
              url,
              placeholder: (progress) => Center(
                child: CircularProgressIndicator(value: progress / 100),
              ),
              errorWidget: (error) => Center(
                child: Text('Error loading PDF', style: GoogleFonts.poppins(color: Colors.red)),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Text('Error loading image', style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ),
    );
  }
}