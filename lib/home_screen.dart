import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'cats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purrfect Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final authService = Provider.of<AuthService>(context, listen: false);
              authService.signOut();
            },
          ),
        ],
      ),
      body: CatsScreen(),
      drawer: Drawer(
        child: ProfileScreen(),
      ),
      endDrawer: const Drawer(
        child: MessagesScreen(),
      ),
    );
  }
}