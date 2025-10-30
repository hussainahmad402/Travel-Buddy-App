import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travelbuddy/controllers/document_controller.dart';

import 'package:travelbuddy/views/home/trip_list_screen.dart';
import '../../controllers/trip_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Store selected documents
  List<File> _documents = [];

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx'],
  );

  if (result != null && result.files.isNotEmpty) {
    setState(() {
      _documents = result.paths.map((path) => File(path!)).toList();
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TripController>(
        builder: (context, tripController, child) {
          if (tripController.isLoading) {
            return const common.LoadingWidget(message: 'Creating your trip...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Field
                  CustomTextField(
                    label: 'Trip Title',
                    hint: 'e.g., Summer Vacation 2024',
                    controller: _titleController,
                    prefixIcon: const Icon(Icons.title),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a trip title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Destination Field
                  CustomTextField(
                    label: 'Destination',
                    hint: 'e.g., Paris, France',
                    controller: _destinationController,
                    prefixIcon: const Icon(Icons.location_on),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a destination' : null,
                  ),
                  const SizedBox(height: 16),

                  // Start Date
                  CustomTextField(
                    label: 'Start Date',
                    hint: _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select start date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) setState(() => _startDate = date);
                    },
                    validator: (_) =>
                        _startDate == null ? 'Please select a start date' : null,
                  ),
                  const SizedBox(height: 16),

                  // End Date
                  CustomTextField(
                    label: 'End Date',
                    hint: _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select end date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                    validator: (_) {
                      if (_endDate == null) return 'Please select an end date';
                      if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                        return 'End date must be after start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes Field
                  CustomTextField(
                    label: 'Notes (Optional)',
                    hint: 'Add any additional notes about your trip...',
                    controller: _notesController,
                    prefixIcon: const Icon(Icons.note),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Pick Documents
                  CustomButton(
                    text: 'Attach Documents',
                    icon: Icons.attach_file,
                    onPressed: _pickDocuments,
                  ),
                  const SizedBox(height: 12),

                  if (_documents.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Documents:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._documents.map(
                          (doc) => ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(doc.path.split('/').last),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // Create Trip Button
                  CustomButton(
  text: 'Create Trip',
  icon: Icons.add,
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final tripController = Provider.of<TripController>(context, listen: false);
      final documentController = Provider.of<DocumentController>(context, listen: false);

      // create trip and get Trip object
      final newTrip = await tripController.createTrip(
        token: authController.token!,
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      print('new trip : ${tripController.trips.last.id}');

      if (newTrip != null) {
        // ✅ Upload documents using newTrip.id
        for (final file in _documents) {
          await documentController.uploadDocument(
            token: authController.token!,
            tripId: tripController.trips.last.id, // <-- backend-generated ID
            file: file,
          );
          
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip and documents created successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TripListScreen()),
          // (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tripController.errorMessage ?? 'Failed to create trip')),
        );
      }
    }
  },
),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
