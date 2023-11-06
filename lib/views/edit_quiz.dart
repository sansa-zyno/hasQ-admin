import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_admin/services/database.dart';
import 'package:quiz_admin/views/add_question.dart';
import 'package:quiz_admin/widget/widget.dart';
import 'package:random_string/random_string.dart';

class EditQuiz extends StatefulWidget {
  final String quizImgUrl, quizTitle, quizDesc, id;

  EditQuiz(this.quizImgUrl, this.quizTitle, this.quizDesc, this.id);

  @override
  _EditQuizState createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  DatabaseService databaseService = new DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String quizImgUrl, quizTitle, quizDesc;

  bool isLoading = false;
  String quizId;

  //image picker
  File _image;
  String _postPicUrl;

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String fileName = '${DateTime.now().toString()}.png';

    if (image != null) {
      ///Saving Pdf to firebase
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putData(image.readAsBytesSync());
      String urlImage = await (await uploadTask).ref.getDownloadURL();

      setState(() {
        _image = image;
        _postPicUrl = urlImage;
      });
    }
  }

  updateQuiz() {
    //quizId = randomAlphaNumeric(16);
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, String> quizData = {
        "quizImgUrl": _postPicUrl ?? widget.quizImgUrl,
        "quizTitle": quizTitle ?? widget.quizTitle,
        "quizDesc": quizDesc ?? widget.quizDesc
      };

      databaseService.updateQuiz(quizData, widget.id).then((value) {
        setState(() {
          isLoading = false;
        });
      });
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
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height / 1.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: getImage,
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[200],
                      // decoration: BoxDecoration(boxShadow: [
                      //   BoxShadow(
                      //     offset: Offset(1, 1),
                      //     blurRadius: 5,
                      //   ),
                      // ]),
                      child: _image == null
                          ? Image.network(widget.quizImgUrl)
                          : Image.file(
                              _image,
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    initialValue:
                        quizTitle == null ? widget.quizTitle : quizTitle,
                    validator: (val) => val.isEmpty ? "Enter Quiz Title" : null,
                    decoration: InputDecoration(hintText: "Quiz Title"),
                    onChanged: (val) {
                      quizTitle = val;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    initialValue: quizDesc == null ? widget.quizDesc : quizDesc,
                    validator: (val) =>
                        val.isEmpty ? "Enter Quiz Description" : null,
                    decoration: InputDecoration(hintText: "Quiz Description"),
                    onChanged: (val) {
                      quizDesc = val;
                    },
                  ),
                  isLoading
                      ? Container(
                          height: 50,
                        )
                      : Spacer(),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : GestureDetector(
                          onTap: () {
                            updateQuiz();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Update Quiz",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
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
