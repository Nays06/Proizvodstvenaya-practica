import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sets_provider.dart';

class SetsScreen extends StatefulWidget {
  const SetsScreen({super.key});

  @override
  _SetsScreenState createState() => _SetsScreenState();
}

class _SetsScreenState extends State<SetsScreen> {
  final _setNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final setsProvider = Provider.of<SetsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Sets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setNameController,
                    decoration: const InputDecoration(labelText: 'New Set Name'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_setNameController.text.isNotEmpty) {
                      setsProvider.addSet(_setNameController.text);
                      _setNameController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: setsProvider.sets.length,
              itemBuilder: (context, index) {
                final set = setsProvider.sets[index];
                return ListTile(
                  title: Text(set.name),
                  subtitle: Text('${set.words.length} words'),
                  onTap: () => Navigator.pushNamed(context, '/edit_set', arguments: index),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => setsProvider.resetProgress(),
            child: const Text('Reset Progress'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/learn'),
        child: const Icon(Icons.school),
      ),
    );
  }
}