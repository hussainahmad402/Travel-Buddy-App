import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<dynamic>> _usersFuture; // for all users list

  @override
  void initState() {
    super.initState();
    final chatController = Provider.of<ChatController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);

    final userId = authController.token ?? ""; // your backend user ID
    final token = authController.token; // or authController.userToken if stored

    // Call your fetchAllUsers API from the controller
    _usersFuture = chatController.fetchAllUsers(token!);

    // (Optional) — If you want to load chat list stream as well
    chatController.getChatList(userId);
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.token ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Chats"), centerTitle: true),

      // 🔹 Step 1: Show users first (for starting new chats)
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user.name ?? 'Unknown';
              final email = user.email ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(name),
                subtitle: Text(email),
                onTap: () {
                  // When tapped — open chat with this user
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: user.id.toString(),
                        receiverName: name,
                        currentUserId: userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
