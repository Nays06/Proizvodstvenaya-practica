import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sets_provider.dart';

class EditSetScreen extends StatefulWidget {
  const EditSetScreen({super.key});

  @override
  _EditSetScreenState createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _wordFocusNode = FocusNode();
  final _translationFocusNode = FocusNode();

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _wordFocusNode.dispose();
    _translationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setIndex = ModalRoute.of(context)!.settings.arguments as int;
    final setsProvider = Provider.of<SetsProvider>(context);
    final set = setsProvider.sets[setIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${set.name}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordController,
                    focusNode: _wordFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Word',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_translationFocusNode),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _translationController,
                    focusNode: _translationFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Translation',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addWord(setIndex, context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addWord(setIndex, context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: set.words.length,
              itemBuilder: (context, index) {
                final word = set.words[index];
                return ListTile(
                  title: Text(word.word),
                  subtitle: Text(word.translation),
                  trailing: Checkbox(
                    value: word.isLearned,
                    onChanged: (value) => setsProvider.updateWordStatus(setIndex, index, value!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addWord(int setIndex, BuildContext context) {
    if (_wordController.text.isNotEmpty && _translationController.text.isNotEmpty) {
      Provider.of<SetsProvider>(context, listen: false).addWordToSet(
        setIndex,
        Word(word: _wordController.text, translation: _translationController.text),
        );
      _wordController.clear();
      _translationController.clear();
      _wordFocusNode.requestFocus();
    }
  }
}