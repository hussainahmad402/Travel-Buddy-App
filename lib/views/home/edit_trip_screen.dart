import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy/constants/app_colors.dart';
import '../../controllers/trip_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class EditTripScreen extends StatefulWidget {
  final Trip trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _destinationController;
  late TextEditingController _notesController;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.trip.title);
    _destinationController =
        TextEditingController(text: widget.trip.destination);
    _notesController = TextEditingController(text: widget.trip.notes ?? '');

    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Trip'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TripController>(
        builder: (context, tripController, child) {
          if (tripController.isLoading) {
            return const common.LoadingWidget(message: 'Updating trip...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    backgroundColor: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        const SizedBox(height: 16),

                        // TITLE
                        CustomTextField(
                          label: "Title",
                          hint: "Enter trip title",
                          controller: _titleController,
                          prefixIcon: const Icon(Icons.title),
                          validator: (v) =>
                              v!.isEmpty ? "Title is required" : null,
                        ),

                        const SizedBox(height: 16),

                        // DESTINATION
                        CustomTextField(
                          label: "Destination",
                          hint: "Enter destination",
                          controller: _destinationController,
                          prefixIcon: const Icon(Icons.location_on),
                          validator: (v) =>
                              v!.isEmpty ? "Destination is required" : null,
                        ),

                        const SizedBox(height: 16),

                        // START DATE
                        GestureDetector(
                          onTap: pickStartDate,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: "Start Date",
                              hint: "",
                              controller: TextEditingController(
                                  text:
                                      "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"),
                              prefixIcon:
                                  const Icon(Icons.calendar_today_rounded),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // END DATE
                        GestureDetector(
                          onTap: pickEndDate,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: "End Date",
                              controller: TextEditingController(
                                  text:
                                      "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"),
                              prefixIcon:
                                  const Icon(Icons.calendar_month_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // NOTES
                  CustomTextField(
                    label: 'Notes',
                    hint: 'Add any notes...',
                    controller: _notesController,
                    prefixIcon: const Icon(Icons.note),
                    maxLines: 5,
                  ),

                  const SizedBox(height: 32),

                  // UPDATE BUTTON
                  CustomButton(
                    text: "Update Trip",
                    icon: Icons.save,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final auth =
                            Provider.of<AuthController>(context, listen: false);

                        final success = await tripController.updateTrip(
                          token: auth.token!,
                          tripId: widget.trip.id,
                          title: _titleController.text.trim(),
                          destination: _destinationController.text.trim(),
                          startDate: _startDate!,
                          endDate: _endDate!,
                          notes: _notesController.text.trim(),
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Trip updated successfully!")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(tripController.errorMessage ??
                                    "Failed to update trip")),
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
