import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy/views/home/trip_list_screen.dart';
import '../../controllers/trip_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final tripController = Provider.of<TripController>(context, listen: false);

      if (authController.token != null) {
        tripController.loadFavourites(authController.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: Colors.white,
     appBar: AppBar(
      centerTitle: true,
        title: const Text("Favourite Trips"),
        backgroundColor: Colors.white,
        elevation: 0,
     
      ),
   
    body: Consumer<TripController>(
      builder: (context, tripController, child) {
        final favouriteTrips =
            tripController.trips.where((t) => t.isFavourite == true).toList();
   
        if (tripController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
   
        if (favouriteTrips.isEmpty) {
          return const Center(child: Text("No favourite trips found."));
        }
   
        return ListView.builder(
          itemCount: favouriteTrips.length,
          itemBuilder: (context, index) {
            final trip = favouriteTrips[index];
            return TripCard(trip: trip);
          },
        );
      },
    ));
  }
}
