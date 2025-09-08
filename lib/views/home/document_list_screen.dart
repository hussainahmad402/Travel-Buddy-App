import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:travelbuddy/models/document.dart';
import '../../controllers/document_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class DocumentListScreen extends StatefulWidget {
  final Trip trip;

  const DocumentListScreen({
    super.key,
    required this.trip,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
    });
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Consumer<DocumentController>(
        builder: (context, documentController, child) {
          if (documentController.isLoading) {
            return const common.LoadingWidget(message: 'Loading documents...');
          }

          if (documentController.errorMessage != null) {
            return common.ErrorWidget(
              message: documentController.errorMessage!,
              onRetry: _loadDocuments,
            );
          }

          if (documentController.documents.isEmpty) {
            return common.EmptyStateWidget(
              message: 'No documents uploaded yet!\nStart by uploading your travel documents.',
              icon: Icons.attach_file,
              action: ElevatedButton.icon(
                onPressed: _showUploadDialog,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Document'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDocuments,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documentController.documents.length,
              itemBuilder: (context, index) {
                final document = documentController.documents[index];
                return DocumentCard(
                  document: document,
                  onTap: () {
                    // Handle document view/download
                    _showDocumentOptions(document);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Document',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(
                  context,
                  Icons.camera_alt,
                  'Camera',
                  () => _uploadDocument('camera'),
                ),
                _buildUploadOption(
                  context,
                  Icons.photo_library,
                  'Gallery',
                  () => _uploadDocument('gallery'),
                ),
                _buildUploadOption(
                  context,
                  Icons.folder_open,
                  'Files',
                  () => _uploadDocument('files'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(String source) async {
    Navigator.pop(context); // Close the bottom sheet
    
    try {
      // Simulate document upload for now
      final authController = Provider.of<AuthController>(context, listen: false);
      final documentController = Provider.of<DocumentController>(context, listen: false);
      
      final success = await documentController.uploadDocument(
        token: authController.token!,
        tripId: widget.trip.id,
        file: File('simulated_${source}_document.jpg'),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(documentController.errorMessage ?? 'Failed to upload document')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: ${e.toString()}')),
      );
    }
  }

  void _showDocumentOptions(dynamic document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              document.fileName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionOption(
                  context,
                  Icons.visibility,
                  'View',
                  () {
                    Navigator.pop(context);
                    // Implement document viewing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View functionality coming soon!')),
                    );
                  },
                ),
                _buildActionOption(
                  context,
                  Icons.download,
                  'Download',
                  () {
                    Navigator.pop(context);
                    // Implement document download
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download functionality coming soon!')),
                    );
                  },
                ),
                _buildActionOption(
                  context,
                  Icons.share,
                  'Share',
                  () {
                    Navigator.pop(context);
                    // Implement document sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share functionality coming soon!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileType = _getFileType(document.fileName);

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileType),
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileType.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  String _getFileType(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}
