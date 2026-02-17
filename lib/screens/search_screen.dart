import 'package:flutter/material.dart';
import '../models/user.dart';

class SearchScreen extends StatefulWidget {
  final User user; // campo final

  const SearchScreen({Key? key, required this.user})
    : super(key: key); // inicialización correcta

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Lista de ejemplo de usuarios
  final List<User> users = [
    User(
      id: '1',
      name: 'Ana',
      email: 'ana@email.com',
      interests: ['Música', 'Videojuegos'],
    ),
    User(
      id: '2',
      name: 'Luis',
      email: 'luis@email.com',
      interests: ['Cine', 'Fútbol'],
    ),
    User(
      id: '3',
      name: 'Clara',
      email: 'clara@email.com',
      interests: ['Videojuegos', 'Anime'],
    ),
    User(
      id: '4',
      name: 'Jorge',
      email: 'jorge@email.com',
      interests: ['Música', 'Cine'],
    ),
    User(
      id: '5',
      name: 'Sofía',
      email: 'sofia@email.com',
      interests: ['Arte', 'Literatura'],
    ),
    User(
      id: '6',
      name: 'Miguel',
      email: 'miguel@email.com',
      interests: ['Deportes', 'Viajes'],
    ),
  ];

  late List<User> filteredUsers;

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where(
            (user) =>
                user.interests.any(
                  (interest) =>
                      interest.toLowerCase().contains(query.toLowerCase()),
                ) ||
                user.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar personas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o afinidad',
                border: OutlineInputBorder(),
              ),
              onChanged: filterUsers,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.interests.join(', ')),
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
