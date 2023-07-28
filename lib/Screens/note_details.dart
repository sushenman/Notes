import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/Models/note.dart';
import 'package:notes/Screens/note_list.dart';
import 'package:notes/utils/db_helper.dart';

class NoteDetail extends StatefulWidget {
  NoteDetail({required this.appBarTitle, this.note, this.onAdd, this.onEdit});
  String appBarTitle;
  Note? note;
  final Function(Note)? onAdd;
  Function(Note)? onEdit;

  NoteDetailState createState() => NoteDetailState();
}

class NoteDetailState extends State<NoteDetail> {
  var dbHelper = DatabaseHelper.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  void initState() {
    widget.note != null
        ? setState(() {
            titleController.text = widget.note!.title;
            descriptionController.text = widget.note!.desc;
          })
        : null;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyMiddle: false,
        middle: Text(
          'Note',
          style: TextStyle(color: Color.fromARGB(255, 244, 138, 58)),
        ),
        backgroundColor: Colors.transparent,
        trailing: GestureDetector(
          child: Text(
            'Done',
            style: TextStyle(color: Color.fromARGB(255, 244, 138, 58)),
          ),
          onTap: () {
            if (widget.appBarTitle == 'Edit Note') {
              updateData();
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => NoteList())));
            } else {
              insertData();
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => NoteList())));
            }
          },
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 1.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: CupertinoTextFormFieldRow(
                placeholder: 'Title',
                controller: titleController,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: CupertinoTextFormFieldRow(
                controller: descriptionController,
                maxLines: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void insertData() async {
    Map<String, dynamic> note = {
      DatabaseHelper.columnTitle: titleController.text,
      DatabaseHelper.columnDesc: descriptionController.text,
      DatabaseHelper.columnDate: DateTime.now().toString()
    };
    dbHelper.insert(note);
  }

  //update
  void updateData() async {
    Map<String, dynamic> note = {
      DatabaseHelper.columnId: widget.note!.id,
      DatabaseHelper.columnTitle: titleController.text,
      DatabaseHelper.columnDesc: descriptionController.text,
      DatabaseHelper.columnDate: DateTime.now()
    };
    dbHelper.update(note);
  }
}
