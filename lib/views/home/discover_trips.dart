import 'package:flutter/material.dart';
import 'package:travelbuddy/models/user.dart';
import 'package:travelbuddy/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy/controllers/profile_controller.dart';

class DiscoverTrip extends StatelessWidget {
  const DiscoverTrip({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get user from your ProfileController (assuming you use Provider)
    final profileController = Provider.of<ProfileController>(context);
    final User? user = profileController.userProfile;

    final destinations = [
      {
        'image':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
        'title': 'Khai island beach',
        'country': 'Thailand',
        'rating': '4.9',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80',
        'title': 'Hismat rock',
        'country': 'Saudi Arabia',
        'rating': '4.8',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=600&q=80',
        'title': 'Bali Island',
        'country': 'Indonesia',
        'rating': '4.7',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Discover Trips'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 28,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: user?.getProfileImage(
                            fallbackUrl:
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaAsJaTD22xdCgfrjTCJzLQmODiZ-tYaXisA&s',
                          ),
                        ),
                        Text(
                          '  ${user?.first_name ?? "Guest"} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // ✅ Heading
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: 'Discover the wonders\nof the '),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Destination',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Destination Cards
            SizedBox(
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final item = destinations[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: DestinationCard(
                        image: item['image']!,
                        title: item['title']!,
                        country: item['country']!,
                        rating: item['rating']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DestinationCard extends StatelessWidget {
  final String image;
  final String title;
  final String country;
  final String rating;

  const DestinationCard({
    super.key,
    required this.image,
    required this.title,
    required this.country,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(1, 1 ),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      image,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.bookmark_border, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Info Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      country,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=80&q=80',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
