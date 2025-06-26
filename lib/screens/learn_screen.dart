import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/sets_provider.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
  int _currentWordIndex = 0;
  bool _isFlashcardMode = true;
  List<Word> _allWords = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  int _correctAnswers = 0;
  bool _isFinished = false;
  final Map<Word, int> _wordToSetIndex = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();
    });
  }

  void _loadWords() {
    final setsProvider = Provider.of<SetsProvider>(context, listen: false);
    try {
      _wordToSetIndex.clear();
      final words = <Word>[];
      for (int setIndex = 0; setIndex < setsProvider.sets.length; setIndex++) {
        for (var word in setsProvider.sets[setIndex].words) {
          words.add(word);
          _wordToSetIndex[word] = setIndex;
        }
      }
      if (words.isEmpty) {
        print('В setsProvider нет доступных слов');
        return;
      }
      setState(() {
        _allWords = words..shuffle();
        _currentWordIndex = 0;
        _showTranslation = false;
        _correctAnswers = 0;
        _isFinished = false;
      });
      print('Загружено ${_allWords.length} слов');
    } catch (e) {
      print('Ошибка загрузки слов: $e');
    }
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
        appBar: AppBar(title: const Text('Изучение')),
        body: const Center(
            child: Text(
                'Нет слов для изучения. Сначала добавьте несколько слов!')),
      );
    }

    if (_isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Изучение')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isFlashcardMode ? 'Карточки заполнены!' : 'Тест завершен!',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (!_isFlashcardMode)
                Text(
                  'У тебя $_correctAnswers из ${_allWords.length} правильных ответов!',
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loadWords();
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child:
                    const Text('Начать заново', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

    final word = _allWords[_currentWordIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Изучение'),
        actions: [
          IconButton(
            icon: Icon(_isFlashcardMode ? Icons.quiz : Icons.flash_on),
            tooltip: _isFlashcardMode
                ? 'Переключиться в режим викторины'
                : 'Переключиться в режим флэш-карты',
            onPressed: () {
              try {
                setState(() {
                  _isFlashcardMode = !_isFlashcardMode;
                  _loadWords();
                });
              } catch (e) {
                print('Ошибка переключения режима: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка переключения режима: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: _isFlashcardMode
          ? _buildFlashcard(word)
          : _buildQuiz(word, setsProvider),
    );
  }

  Widget _buildFlashcard(Word word) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: 300,
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _showTranslation ? word.translation : word.word,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_currentWordIndex + 1 >= _allWords.length) {
                  _isFinished = true;
                } else {
                  _currentWordIndex++;
                  _showTranslation = false;
                  _controller.forward(from: 0);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                const Text('Следующее слово', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(Word word, SetsProvider setsProvider) {
    if (_allWords.length < 2) {
      return const Center(
        child: Text(
          'Недостаточно слов для теста. Необходимо минимум 2 слова.',
          style: TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final options = _generateOptions(word);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                word.word,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...options.asMap().entries.map((entry) {
            final option = entry.value;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - _animation.value * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          final setIndex = _wordToSetIndex[word];
                          final wordIndex =
                              setsProvider.sets[setIndex!].words.indexOf(word);
                          if (option == word.translation) {
                            _correctAnswers++;
                            if (wordIndex != -1) {
                              setsProvider.updateWordStatus(
                                  setIndex, wordIndex, true);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Правильно!'),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Не верно!'),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          }
                          setState(() {
                            if (_currentWordIndex + 1 >= _allWords.length) {
                              _isFinished = true;
                            } else {
                              _currentWordIndex++;
                              _controller.forward(from: 0);
                            }
                          });
                        } catch (e) {
                          print('Ошибка в тесте: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка в тесте: $e'),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        option,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<String> _generateOptions(Word word) {
    final options = <String>[word.translation];
    final random = Random();
    try {
      final availableWords = _allWords
          .where((w) => w.word != word.word)
          .map((w) => w.translation)
          .toList();

      final maxOptions = min(3, availableWords.length);
      availableWords.shuffle(random);

      for (int i = 0; i < maxOptions; i++) {
        if (!options.contains(availableWords[i])) {
          options.add(availableWords[i]);
        }
      }
    } catch (e) {
      print('Ошибка генерации параметров: $e');
    }
    return options..shuffle(random);
  }
}
