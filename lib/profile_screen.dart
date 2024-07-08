import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final displayName = userData?['displayName'] ?? 'User';
        final email = userData?['email'] ?? 'Email';
        final photoURL = userData?['photoURL'] ?? '';

        return ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(photoURL),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('My Cats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCatsScreen(userId: userId)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add a Cat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCatScreen(userId: userId)),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class MyCatsScreen extends StatelessWidget {
  final String? userId;

  const MyCatsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cats')
            .where('ownerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cats = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final catData = cats[index].data() as Map<String, dynamic>;
              final catName = catData['name'] ?? 'Unknown';
              final catPhotoURL = catData['photoURL'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(catPhotoURL),
                ),
                title: Text(catName),
              );
            },
          );
        },
      ),
    );
  }
}

class AddCatScreen extends StatelessWidget {
  final String? userId;

  AddCatScreen({super.key, required this.userId});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _photoURLController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Cat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            TextField(
              controller: _photoURLController,
              decoration: const InputDecoration(labelText: 'Photo URL'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final catData = {
                  'name': _nameController.text,
                  'age': int.parse(_ageController.text),
                  'breed': _breedController.text,
                  'ownerId': userId,
                  'photoURL': _photoURLController.text,
                  'description': _descriptionController.text,
                };

                await FirebaseFirestore.instance.collection('cats').add(catData);

                Navigator.pop(context);
              },
              child: const Text('Add Cat'),
            ),
          ],
        ),
      ),
    );
  }
}