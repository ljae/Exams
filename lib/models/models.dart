export 'school.dart';

class Problem {
  final String id;
  final DateTime date;
  final String title;
  final String content; // Can contain LaTeX
  final String? imageUrl;
  final String correctAnswer;
  final String explanation;

  final String? newsTitle;
  final String? newsUrl;

  Problem({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.correctAnswer,
    required this.explanation,
    this.newsTitle,
    this.newsUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'newsTitle': newsTitle,
      'newsUrl': newsUrl,
    };
  }

  factory Problem.fromMap(Map<String, dynamic> map) {
    return Problem(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      correctAnswer: map['correctAnswer'],
      explanation: map['explanation'],
      newsTitle: map['newsTitle'],
      newsUrl: map['newsUrl'],
    );
  }
}

class User {
  final String id;
  final String nickname;
  final String schoolName;

  User({
    required this.id,
    required this.nickname,
    required this.schoolName,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nickname: map['nickname'],
      schoolName: map['schoolName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'schoolName': schoolName,
    };
  }
}

class Attempt {
  final String problemId;
  final bool isCorrect;
  final DateTime solvedAt;
  final int timeTakenSeconds;

  Attempt({
    required this.problemId,
    required this.isCorrect,
    required this.solvedAt,
    this.timeTakenSeconds = 0,
  });

  factory Attempt.fromMap(Map<String, dynamic> map) {
    return Attempt(
      problemId: map['problemId'],
      isCorrect: map['isCorrect'] == 1,
      solvedAt: DateTime.parse(map['solvedAt']),
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'problemId': problemId,
      'isCorrect': isCorrect,
      'solvedAt': solvedAt.toIso8601String(),
      'timeTakenSeconds': timeTakenSeconds,
    };
  }
}

class RankingItem {
  final String userId;
  final String nickname;
  final String schoolName;
  final int solvedCount;
  final int rank;

  RankingItem({
    required this.userId,
    required this.nickname,
    required this.schoolName,
    required this.solvedCount,
    required this.rank,
  });
}

class SchoolRankingItem {
  final String schoolName;
  final int totalSolvedCount;
  final int studentCount;
  final int rank;

  SchoolRankingItem({
    required this.schoolName,
    required this.totalSolvedCount,
    required this.studentCount,
    required this.rank,
  });
}
