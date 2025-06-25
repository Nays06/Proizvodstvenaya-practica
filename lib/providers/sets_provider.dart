import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Word {
  final String word;
  final String translation;
  bool isLearned;

  Word({required this.word, required this.translation, this.isLearned = false});

  Map<String, dynamic> toJson() => {
        'word': word,
        'translation': translation,
        'isLearned': isLearned,
      };

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        word: json['word'],
        translation: json['translation'],
        isLearned: json['isLearned'] ?? false,
      );
}

class WordSet {
  final String name;
  final List<Word> words;

  WordSet({required this.name, List<Word>? words}) : words = words ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'words': words.map((word) => word.toJson()).toList(),
      };

  factory WordSet.fromJson(Map<String, dynamic> json) => WordSet(
        name: json['name'],
        words: (json['words'] as List).map((w) => Word.fromJson(w)).toList(),
      );
}

class SetsProvider with ChangeNotifier {
  List<WordSet> _sets = [];

  List<WordSet> get sets => _sets;

  SetsProvider() {
    _loadSets();
  }

  Future<void> _loadSets() async {
    final prefs = await SharedPreferences.getInstance();
    final setsJson = prefs.getString('sets') ?? '[]';
    final List<dynamic> decoded = jsonDecode(setsJson);
    _sets = decoded.map((s) => WordSet.fromJson(s)).toList();
    notifyListeners();
  }

  Future<void> _saveSets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sets', jsonEncode(_sets.map((s) => s.toJson()).toList()));
    notifyListeners();
  }

  void addSet(String name) {
    _sets.add(WordSet(name: name));
    _saveSets();
    notifyListeners();
  }

  void addWordToSet(int setIndex, Word word) {
    _sets[setIndex].words.add(word);
    _saveSets();
    notifyListeners();
  }

  void updateWordStatus(int setIndex, int wordIndex, bool isLearned) {
    _sets[setIndex].words[wordIndex].isLearned = isLearned;
    _saveSets();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    for (var set in _sets) {
      for (var word in set.words) {
        word.isLearned = false;
      }
    }
    await _saveSets();
    notifyListeners();
  }
}