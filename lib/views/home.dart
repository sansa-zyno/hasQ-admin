import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_admin/services/database.dart';
import 'package:quiz_admin/views/create_quiz.dart';
import 'package:quiz_admin/views/edit_quiz.dart';
import 'package:quiz_admin/views/quiz_play.dart';
import 'package:quiz_admin/views/signin.dart';
import 'package:quiz_admin/widget/widget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream quizStream;
  DatabaseService databaseService = new DatabaseService();

  Widget quizList() {
    return Container(
        child: StreamBuilder(
      stream: quizStream,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? Container()
            : ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return QuizTile(
                      imageUrl: snapshot.data.docs[index]['quizImgUrl'],
                      title: snapshot.data.docs[index]['quizTitle'],
                      description: snapshot.data.docs[index]['quizDesc'],
                      id: snapshot.data.docs[index].id);
                });
      },
    ));
  }

  @override
  void initState() {
    databaseService.getQuizData().then((value) {
      quizStream = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppLogo(),
        brightness: Brightness.light,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Future.delayed(Duration(seconds: 5), () {
                  final FirebaseAuth _auth = FirebaseAuth.instance;
                  _auth.signOut();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (ctx) => SignIn()));
                });
              }),
          SizedBox(width: 10),
        ],
        //brightness: Brightness.li,
      ),
      body: quizList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => CreateQuiz()));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

class QuizTile extends StatefulWidget {
  final String imageUrl, title, id, description;

  QuizTile({
    @required this.title,
    @required this.imageUrl,
    @required this.description,
    @required this.id,
  });

  @override
  _QuizTileState createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> {
  DatabaseService databaseService = new DatabaseService();
  QuerySnapshot snap;

  @override
  void initState() {
    /*databaseService.getQuestionData(widget.id).then((value) {
      snap = value;
      setState(() {});
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => QuizPlay(widget.id)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    )
                  : Container(),
              Container(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.description,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "10 Questions",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => EditQuiz(
                                      widget.imageUrl,
                                      widget.title,
                                      widget.description,
                                      widget.id)));
                            },
                            color: Colors.blue,
                            child: Text('Edit'),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          MaterialButton(
                            onPressed: () {
                              DatabaseService databaseService =
                                  DatabaseService();
                              databaseService.deleteQuiz(widget.id);
                            },
                            color: Colors.red,
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
