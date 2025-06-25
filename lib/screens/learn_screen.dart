import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/sets_provider.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
  int _currentWordIndex = 0;
  bool _isFlashcardMode = true;
  List<Word> _allWords = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _loadWords();
  }

  void _loadWords() {
    final setsProvider = Provider.of<SetsProvider>(context, listen: false);
    _allWords = setsProvider.sets.expand((set) => set.words).toList()..shuffle();
    _currentWordIndex = 0;
    _showTranslation = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setsProvider = Provider.of<SetsProvider>(context);

    if (_allWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn')),
        body: const Center(child: Text('No words to learn. Add some words first!')),
      );
    }

    final word = _allWords[_currentWordIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            icon: Icon(_isFlashcardMode ? Icons.quiz : Icons.flash_on),
            onPressed: () {
              setState(() {
                _isFlashcardMode = !_isFlashcardMode;
                _loadWords();
              });
            },
          ),
        ],
      ),
      body: _isFlashcardMode ? _buildFlashcard(word) : _buildQuiz(word, setsProvider),
    );
  }

  Widget _buildFlashcard(Word word) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showTranslation = !_showTranslation;
            _controller.forward(from: 0);
          });
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - _animation.value * 0.1,
              child: Card(
                elevation: 4,
                child: Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _showTranslation ? word.translation : word.word,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuiz(Word word, SetsProvider setsProvider) {
    final options = _generateOptions(word);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(word.word, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          final option = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                if (option == word.translation) {
                  setsProvider.updateWordStatus(
                    setsProvider.sets.indexWhere((s) => s.words.contains(word)),
                    setsProvider.sets.expand((s) => s.words).toList().indexOf(word),
                    true,
                  );
                }
                setState(() {
                  _currentWordIndex = (_currentWordIndex + 1) % _allWords.length;
                  _controller.forward(from: 0);
                });
              },
              child: Text(option),
            ),
          );
        }),
      ],
    );
  }

  List<String> _generateOptions(Word word) {
    final options = [word.translation];
    final random = Random();
    while (options.length < 4) {
      final randomWord = _allWords[random.nextInt(_allWords.length)];
      if (randomWord.translation != word.translation && !options.contains(randomWord.translation)) {
        options.add(randomWord.translation);
      }
    }
    return options..shuffle();
  }
}