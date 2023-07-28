import 'package:flutter/material.dart';
import 'package:notes/Screens/note_details.dart';
import 'package:notes/Screens/note_list.dart';

void main() {
  runApp(const Notes());
}

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();  
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,  
        title: 'Notes',
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        // ),
        home: NoteList());
  }
}
