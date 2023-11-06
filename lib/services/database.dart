import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future<void> addUserData(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e);
    });
  }

  /*getData() async {
    return await Firestore.instance.collection("users").snapshots();
  }*/

  Future<void> addQuizData(Map quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e);
    });
  }

  Future<Stream<QuerySnapshot>> getQuizData() async {
    return await FirebaseFirestore.instance.collection("Quiz").snapshots();
  }

  updateQuiz(quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .update(quizData);
  }

  deleteQuiz(String quizId) async {
    await FirebaseFirestore.instance.collection('Quiz').doc(quizId).delete();
  }

  Future<void> addQuestionData(quizQuestionData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .add(quizQuestionData)
        .catchError((e) {
      print(e);
    });
  }

  Future<Stream<QuerySnapshot>> getQuestionData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .snapshots();
  }

  Future<void> updateQuestionData(
      quizQuestionData, String quizId, String questionId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .doc(questionId)
        .update(quizQuestionData);
  }

  deleteQuestion(String quizId, String questionId) async {
    await FirebaseFirestore.instance
        .collection('Quiz')
        .doc(quizId)
        .collection('QNA')
        .doc(questionId)
        .delete();
  }
}
