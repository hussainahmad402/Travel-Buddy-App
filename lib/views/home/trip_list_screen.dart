import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelbuddy/constants/app_colors.dart';
import 'package:travelbuddy/views/home/add_trip_screen.dart';
import '../../controllers/trip_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;
import 'trip_detail_screen.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  Future<void> _loadTrips() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final tripController = Provider.of<TripController>(context, listen: false);
    print("authController.token: ${authController.token}");

    if (authController.token != null) {
      await tripController.loadTrips(authController.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      title: const Text('My Trips'),
      // backgroundColor: Colors.transparent,
      elevation: 0,
      // actions: [
      //   IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrips),
      // ],
    ),
    body: Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController.isLoading) {
          return const common.LoadingWidget(message: 'Loading your trips...');
        }
    
        if (tripController.errorMessage != null) {
          return common.ErrorWidget(
            message: tripController.errorMessage!,
            onRetry: _loadTrips,
          );
        }
    
        if (tripController.trips.isEmpty) {
          return common.EmptyStateWidget(
            message: 'No trips yet!\nStart planning your next adventure.',
            icon: Icons.travel_explore,
            action: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTripScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Trip'),
            ),
          );
        }
    
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadTrips,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripController.trips.length,
            itemBuilder: (context, index) {
              final trip = tripController.trips[index];
              final isFavourite = false;
              return TripCard(
                trip: trip,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailScreen(trip: trip),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    ),
        );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isUpcoming = trip.startDate.isAfter(DateTime.now());
    final isOngoing =
        trip.startDate.isBefore(DateTime.now()) &&
        trip.endDate.isAfter(DateTime.now());

    return CustomCard(
      backgroundColor: Colors.white,
      
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? Colors.blue.withOpacity(0.1)
                      : isOngoing
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUpcoming
                      ? 'Upcoming'
                      : isOngoing
                      ? 'Ongoing'
                      : 'Completed',
                  style: TextStyle(
                    color: isUpcoming
                        ? Colors.blue
                        : isOngoing
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                trip.destination,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () async {
                  final authController = Provider.of<AuthController>(
                    context,
                    listen: false,
                  );
                  final tripController = Provider.of<TripController>(
                    context,
                    listen: false,
                  );

                  if (authController.token != null && trip.id != null) {
                    // If trip is already favourite → remove it
                    if (trip.isFavourite == true) {
                      final removed = await tripController.removeFavourite(
                        authController.token!,
                        trip.id,
                      );
                      if (removed) {
                        trip.isFavourite = false;
                       
                      }
                    }
                    // If trip is not favourite → add it
                    else {
                      final added = await tripController.addFavourite(
                        authController.token!,
                        trip.id,
                      );
                      if (added) {
                        trip.isFavourite = true;
                        
                      }
                    }
                  }
                },
                icon: Icon(
                  trip.isFavourite ?? false
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: trip.isFavourite ?? false
                      ? Colors.red
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trip.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
