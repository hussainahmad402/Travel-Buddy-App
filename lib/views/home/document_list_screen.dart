import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../../controllers/document_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/document.dart';
import '../../models/trip.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class DocumentListScreen extends StatefulWidget {
  final Trip trip;

  const DocumentListScreen({super.key, required this.trip});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
  }

  Future<void> _loadDocuments() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final documentController = Provider.of<DocumentController>(context, listen: false);

    if (authController.token != null) {
      await documentController.loadDocuments(authController.token!, widget.trip.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents - ${widget.trip.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Consumer<DocumentController>(
        builder: (context, docController, child) {
          if (docController.isLoading) {
            return const common.LoadingWidget(message: 'Loading documents...');
          }

          if (docController.errorMessage != null) {
            return common.ErrorWidget(
              message: docController.errorMessage!,
              onRetry: _loadDocuments,
            );
          }

          if (docController.documents.isEmpty) {
            return common.EmptyStateWidget(
              message: 'No documents uploaded yet!',
              icon: Icons.insert_drive_file,
              action: ElevatedButton.icon(
                onPressed: _pickAndUploadFile,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Document'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDocuments,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docController.documents.length,
              itemBuilder: (context, index) {
                final document = docController.documents[index];
                return DocumentCard(
                  document: document,
                  onTap: () => _showDocumentOptions(document),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔹 Pick and upload a document (PDF, Word, Image)
  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final authController = Provider.of<AuthController>(context, listen: false);
      final docController = Provider.of<DocumentController>(context, listen: false);

      final success = await docController.uploadDocument(
        token: authController.token!,
        tripId: widget.trip.id,
        file: file,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully!')),
        );
        await _loadDocuments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(docController.errorMessage ?? 'Upload failed')),
        );
      }
    }
  }

  /// 🔹 Reusable card for each document
Widget DocumentCard({
  required Document document,
  required VoidCallback onTap,
}) {
  IconData fileIcon;

  switch (document.fileType.toLowerCase()) {
    case 'pdf':
      fileIcon = Icons.picture_as_pdf;
      break;
    case 'doc':
    case 'docx':
      fileIcon = Icons.description;
      break;
    case 'jpg':
    case 'jpeg':
    case 'png':
      fileIcon = Icons.image;
      break;
    default:
      fileIcon = Icons.insert_drive_file;
  }

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(fileIcon, color: Colors.blueAccent),
      ),
      title: Text(
        document.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        document.fileType.toUpperCase(),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: const Icon(Icons.more_vert),
      onTap: onTap,
    ),
  );
}


  /// 🔹 Show bottom sheet for actions
  void _showDocumentOptions(Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View'),
              onTap: () {
                Navigator.pop(context);
                _openFile(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareFile(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                // _deleteDocument(document);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Open document using local file viewer
Future<void> _openFile(Document document) async {
  try {
    final file = File(document.filePath);
    if (await file.exists()) {
      final result = await OpenFilex.open(file.path);
      debugPrint("Open file result: ${result.message}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found locally')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening file: $e')),
    );
  }
}


  /// 🔹 Download document to app’s directory
  Future<void> _downloadFile(Document document) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${document.fileName}');
      final response = await http.get(Uri.parse(document.filePath));
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  /// 🔹 Share document
  Future<void> _shareFile(Document document) async {
    final file = File(document.filePath);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: document.fileName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found for sharing')),
      );
    }
  }

  /// 🔹 Delete document via controller
  // Future<void> _deleteDocument(Document document) async {
  //   final authController = Provider.of<AuthController>(context, listen: false);
  //   final docController = Provider.of<DocumentController>(context, listen: false);

  //   final success = await docController.deleteDocument(authController.token!, document.id);
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Document deleted successfully')),
  //     );
  //     await _loadDocuments();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(docController.errorMessage ?? 'Delete failed')),
  //     );
  //   }
  // }
}
 