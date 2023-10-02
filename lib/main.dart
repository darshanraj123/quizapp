import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: QuizApp(),
  ));
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  int questionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  late Timer _timer;
  List<bool> questionResults = [];

  List<Map<String, Object>> questions = [
    {
      'questionText': ' Who is the 15th Prime Minister of Bharat?',
      'answers': ['Indira Priyadarshini Gandhi', 'Atal Bihari Vajpayee', 'Narendra Modi', 'Rahul Gandhi'],
      'correctAnswer': 'Narendra Modi',
    },
    {
      'questionText': 'Which freedom fighter birthday is on 28 september?',
      'answers': ['Chandrasekhar Azad', 'subhash chandra bose', 'Mangal Pandey', 'Bhagat Singh'],
      'correctAnswer': 'Bhagat Singh',
    },
    {
      'questionText': 'In which year did Chhatrapati Shivaji Maharaj pass away?',
      'answers': ['3 April 1680', '20 Jan 1560', '14 May 1690', '21 Nov 1770'],
      'correctAnswer': '3 April 1680',
    }
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const int questionTimeInSeconds = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (questionTimeInSeconds - timer.tick == 0) {
        nextQuestion();
      }
      setState(() {}); // Update the UI to reflect the timer change
    });
  }

  void nextQuestion() {
    _timer.cancel(); // Cancel the current timer.
    setState(() {
      isAnswered = false;
      if (questionIndex < questions.length - 1) {
        questionIndex++;
        startTimer(); // Start the timer for the next question.
      } else {
        // Quiz completed
        showResult();
      }
    });
  }

  void showResult() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => ResultScreen(
          score: score,
          totalQuestions: questions.length,
          resetQuiz: resetQuiz,
          questionResults: questionResults,
        ),
      ),
    );
  }

  void answerQuestion(String selectedAnswer) {
    if (!isAnswered) {
      if (selectedAnswer == questions[questionIndex]['correctAnswer']) {
        setState(() {
          score++;
          questionResults.add(true);
        });
      } else {
        questionResults.add(false);
      }
      isAnswered = true;
      nextQuestion(); // Go to the next question automatically
    }
  }

  void resetQuiz() {
    _timer.cancel(); // Cancel the timer on reset
    setState(() {
      questionIndex = 0;
      score = 0;
      isAnswered = false;
      questionResults.clear();
      startTimer(); // Start the timer for the first question.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Quiz App',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true,
        elevation: 0, 
      ),
      body: questionIndex < questions.length
          ? QuizPage(
              questionIndex: questionIndex,
              questions: questions,
              answerQuestion: answerQuestion,
              timer: _timer, 
            )
          : ResultScreen(
              score: score,
              totalQuestions: questions.length,
              resetQuiz: resetQuiz,
              questionResults: questionResults,
            ),
    );
  }
}

class QuizPage extends StatelessWidget {
  final int questionIndex;
  final List<Map<String, Object>> questions;
  final Function(String) answerQuestion;
  final Timer timer; // Timer for displaying remaining time

  QuizPage({
    required this.questionIndex,
    required this.questions,
    required this.answerQuestion,
    required this.timer,
  });

  int get questionTimeInSeconds => 10; 

  @override
  Widget build(BuildContext context) {
    int remainingTime = timer.isActive ? questionTimeInSeconds - timer.tick : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Question ${questionIndex + 1}/${questions.length}',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.deepPurple, 
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 5,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  questions[questionIndex]['questionText'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold, 
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...(questions[questionIndex]['answers'] as List<String>).map((answer) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ElevatedButton(
                      onPressed: () => answerQuestion(answer),
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 10),
                Text(
                  'Time Left: $remainingTime seconds',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 135, 10, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Function resetQuiz;
  final List<bool> questionResults; // List of boolean values indicating whether each question was answered correctly

  ResultScreen({
    required this.score,
    required this.totalQuestions,
    required this.resetQuiz,
    required this.questionResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Result',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true,
        elevation: 0, 
        backgroundColor: Colors.blue, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 37, 236, 44),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $score/$totalQuestions',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold, 
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Question Results:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, 
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(
                questionResults.length,
                (index) => Text(
                  'Question ${index + 1}: ${questionResults[index] ? 'Correct' : 'Incorrect'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => resetQuiz(),
              child: const Text(
                'Restart Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
