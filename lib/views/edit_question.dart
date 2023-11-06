import 'package:flutter/material.dart';
import 'package:quiz_admin/services/database.dart';
import 'package:quiz_admin/widget/widget.dart';

class EditQuestion extends StatefulWidget {
  final String quizId;
  final String questionId;
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final String option4;

  EditQuestion(this.quizId, this.questionId, this.question, this.option1,
      this.option2, this.option3, this.option4);

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  DatabaseService databaseService = new DatabaseService();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String question, option1, option2, option3, option4;

  updateQuizData() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, String> questionMap = {
        "question": question ?? widget.question,
        "option1": option1 ?? widget.option1,
        "option2": option2 ?? widget.option2,
        "option3": option3 ?? widget.option3,
        "option4": option4 ?? widget.option4
      };

      print("${widget.quizId}");
      databaseService
          .updateQuestionData(questionMap, widget.quizId, widget.questionId)
          .then((value) {
        question = "";
        option1 = "";
        option2 = "";
        option3 = "";
        option4 = "";
        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        print(e);
      });
    } else {
      print("error is happening ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black54,
        ),
        title: AppLogo(),
        brightness: Brightness.light,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        //brightness: Brightness.li,
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.15,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue:
                              question == null ? widget.question : question,
                          validator: (val) =>
                              val.isEmpty ? "Enter Question" : null,
                          decoration: InputDecoration(hintText: "Question"),
                          onChanged: (val) {
                            question = val;
                          },
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          initialValue:
                              option1 == null ? widget.option1 : option1,
                          validator: (val) => val.isEmpty ? "Option1 " : null,
                          decoration: InputDecoration(
                              hintText: "Option1 (Correct Answer)"),
                          onChanged: (val) {
                            option1 = val;
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          initialValue:
                              option2 == null ? widget.option2 : option2,
                          validator: (val) => val.isEmpty ? "Option2 " : null,
                          decoration: InputDecoration(hintText: "Option2"),
                          onChanged: (val) {
                            option2 = val;
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          initialValue:
                              option3 == null ? widget.option3 : option3,
                          validator: (val) => val.isEmpty ? "Option3 " : null,
                          decoration: InputDecoration(hintText: "Option3"),
                          onChanged: (val) {
                            option3 = val;
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          initialValue:
                              option4 == null ? widget.option4 : option4,
                          validator: (val) => val.isEmpty ? "Option4 " : null,
                          decoration: InputDecoration(hintText: "Option4"),
                          onChanged: (val) {
                            option4 = val;
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Spacer(),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                updateQuizData();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(
                                  "Update Question",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
