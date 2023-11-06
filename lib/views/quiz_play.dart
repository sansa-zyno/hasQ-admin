import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_admin/models/question_model.dart';
import 'package:quiz_admin/services/database.dart';
import 'package:quiz_admin/views/add_question.dart';
import 'package:quiz_admin/views/edit_question.dart';
import 'package:quiz_admin/views/results.dart';
import 'package:quiz_admin/widget/widget.dart';
import 'package:quiz_admin/widgets/option_tile.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
int total = 0;

/// Stream
Stream infoStream;

class QuizPlay extends StatefulWidget {
  final String quizId;
  QuizPlay(this.quizId);

  @override
  _QuizPlayState createState() => _QuizPlayState();
}

class _QuizPlayState extends State<QuizPlay> {
  //QuerySnapshot questionSnaphot;
  List<QueryDocumentSnapshot> qdocs;
  List<QueryDocumentSnapshot> qdocs2;
  DatabaseService databaseService = new DatabaseService();
  Duration _duration = Duration(minutes: 5);

  bool isLoading = true;
  Stream questionStream;

  getQuestionStream() async {
    questionStream = await databaseService.getQuestionData(widget.quizId);
    questionStream.listen((querySnapshot) {
      //print(querySnapshot.docs[1].id);
      qdocs = querySnapshot.docs;
      qdocs.shuffle();
      qdocs2 = qdocs.take(10).toList();
      //questionSnaphot = value;
      _notAttempted = qdocs2.length;
      _correct = 0;
      _incorrect = 0;
      isLoading = false;
      total = qdocs2.length;
      setState(() {});
      print("init don $total ${widget.quizId} ");
    });
  }

  @override
  void initState() {
    if (infoStream == null) {
      infoStream = Stream<List<int>>.periodic(Duration(milliseconds: 100), (x) {
        //for listening sake but List not used
        return [_correct, _incorrect];
      });
    }
    super.initState();
    getQuestionStream();
  }

  QuestionModel getQuestionModelFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel = new QuestionModel();

    questionModel.question = questionSnapshot["question"];

    /// shuffling the options
    List<String> options = [
      questionSnapshot["option1"],
      questionSnapshot["option2"],
      questionSnapshot["option3"],
      questionSnapshot["option4"]
    ];
    options.shuffle();

    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.correctOption = questionSnapshot["option1"];
    questionModel.answered = false;

    print(questionModel.correctOption.toLowerCase());

    return questionModel;
  }

  @override
  void dispose() {
    infoStream = null;
    questionStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0.0,
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    InfoHeader(
                      length: qdocs2.length,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: SlideCountdownClock(
                        duration: _duration,
                        slideDirection: SlideDirection.Up,
                        separator: "-",
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        separatorTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                        onDone: () {
                          infoStream = null;
                          FlutterRingtonePlayer.playNotification();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => Results(
                                        incorrect: _incorrect,
                                        correct: _correct,
                                        total: total,
                                        notattempted: _notAttempted,
                                      )));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    qdocs2 == null
                        ? Container(
                            child: Center(
                              child: Text("No Data"),
                            ),
                          )
                        : ListView.builder(
                            itemCount: qdocs2.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return QuizPlayTile(
                                questionModel: getQuestionModelFromDatasnapshot(
                                    qdocs2[index]),
                                index: index,
                                quizId: widget.quizId,
                                questionId: qdocs2[index].id,
                              );
                            })
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (ctx) => AddQuestion(widget.quizId)));
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
    );
  }
}

class InfoHeader extends StatefulWidget {
  final int length;

  InfoHeader({@required this.length});

  @override
  _InfoHeaderState createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: infoStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  height: 40,
                  margin: EdgeInsets.only(left: 14),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: <Widget>[
                      NoOfQuestionTile(
                        text: "Total",
                        number: widget.length,
                      ),
                      NoOfQuestionTile(
                        text: "Correct",
                        number: _correct,
                      ),
                      NoOfQuestionTile(
                        text: "Incorrect",
                        number: _incorrect,
                      ),
                      NoOfQuestionTile(
                        text: "NotAttempted",
                        number: _notAttempted,
                      ),
                    ],
                  ),
                )
              : Container();
        });
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String questionId;

  QuizPlayTile(
      {@required this.questionModel,
      @required this.index,
      @required this.quizId,
      @required this.questionId});

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Q${widget.index + 1} ${widget.questionModel.question}",
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option1 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                }
              }
            },
            child: OptionTile(
              option: "A",
              description: "${widget.questionModel.option1}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                }
              }
            },
            child: OptionTile(
              option: "B",
              description: "${widget.questionModel.option2}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                }
              }
            },
            child: OptionTile(
              option: "C",
              description: "${widget.questionModel.option3}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                    _notAttempted = _notAttempted - 1;
                  });
                }
              }
            },
            child: OptionTile(
              option: "D",
              description: "${widget.questionModel.option4}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => EditQuestion(
                            widget.quizId,
                            widget.questionId,
                            widget.questionModel.question,
                            widget.questionModel.option1,
                            widget.questionModel.option2,
                            widget.questionModel.option3,
                            widget.questionModel.option4)));
                  },
                  color: Colors.blue,
                  child: Text('Edit'),
                ),
                SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    DatabaseService databaseService = DatabaseService();
                    databaseService.deleteQuestion(
                        widget.quizId, widget.questionId);
                  },
                  color: Colors.red,
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
