import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/Models/note.dart';
import 'package:notes/Screens/note_details.dart';
import 'package:intl/intl.dart';
import 'package:notes/utils/db_helper.dart';


class NoteList extends StatefulWidget {
  NoteListState createState() => NoteListState();
}

class NoteListState extends State<NoteList> {
  var dbHelper = DatabaseHelper.instance;
  List<Note> _myNotes = [];
  List<Note> _originalNotes = []; // Add a list to store the original notes
  Set<int> _selectedNoteIndexes = Set();
  bool _isSelectionMode = false;

  void queryAll() async {
    var allRows = await dbHelper.queryAll();
    List<Note> notes = [];
    allRows.forEach((element) {
      print(element);
      notes.add(Note.fromJson(element));
    });

    setState(() {
      _myNotes = notes;
      _originalNotes = List.from(notes); // Store the original notes
    });
  }

  void initState() {
    super.initState();
    queryAll();
  }

  void addNote(Note note) {
    setState(() {
      _myNotes.add(note);
    });
  }

  void deleteNote(Note note) {
    setState(() {
      _myNotes.remove(note);
    });
  }



  Map<String, List<Note>> groupNotesByMonth(List<Note> notes) {
    Map<String, List<Note>> groupedNotes = {};

    for (var note in notes) {
      String monthYear = DateFormat('MMMM yyyy').format(note.date);
      if (!groupedNotes.containsKey(monthYear)) {
        groupedNotes[monthYear] = [];
      }
      groupedNotes[monthYear]!.add(note);
    }

    return groupedNotes;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Note>> groupedNotes = groupNotesByMonth(_myNotes);
    return WillPopScope(
onWillPop: () async => true  ,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.orange,
          title: Text(
            'Folder',
            style: TextStyle(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              // Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_horiz),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        _selectedNoteIndexes.forEach((element) {
                          Note note = _myNotes[element];
                          dbHelper.delete(note.id!);
                        });
                        _selectedNoteIndexes.clear();
                        _isSelectionMode = false;
                        queryAll(); // Refresh the list of notes after deleting
                      });
                    },
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ],
        ),
        //body background to grey
        backgroundColor: Colors.grey[100],
        body: Container(
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 10, bottom: 10),
                child: Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16,top: 5),
                child: CupertinoSearchTextField(
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        // If the search query is empty, restore the original notes.
                        _myNotes = List.from(_originalNotes);
                      } else {
                        // Filter the notes based on the search query.
                          String upppercaseValue = value.toUpperCase();
                        _myNotes = _originalNotes
                            .where((element) => element.title.toUpperCase().contains(upppercaseValue))
                            .toList();
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: groupedNotes.length,
                  itemBuilder: (context, index) {
                    String monthYear = groupedNotes.keys.toList()[index];
                    List<Note> notesForMonth = groupedNotes[monthYear]!;
    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 16),
                          child: Text(
                            monthYear, // Use the month and year as the title
                            style: TextStyle(
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: notesForMonth.length,
                                itemBuilder: (context, noteIndex) {
                                  bool isLastItem = noteIndex == notesForMonth.length - 1;
                                  Note note = notesForMonth[noteIndex];
                                  bool isSelected = _selectedNoteIndexes.contains(noteIndex);
                          
                                  return InkWell(
                                    onLongPress: () {
                                      setState(() {
                                        _isSelectionMode = true;
                                        _selectedNoteIndexes.add(noteIndex);
                                      });
                                    },
                                    onTap: () {
                                      if (_isSelectionMode) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedNoteIndexes.remove(noteIndex);
                                            if (_selectedNoteIndexes.isEmpty) {
                                              _isSelectionMode = false;
                                            }
                                          } else {
                                            _selectedNoteIndexes.add(noteIndex);
                                          }
                                        });
                                      } else {
                                        editNote('Edit Note', note);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withOpacity(0.7) : Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: _isSelectionMode && isSelected
                                                  ? Checkbox(
                                                      value: true,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedNoteIndexes.remove(noteIndex);
                                                          if (_selectedNoteIndexes.isEmpty) {
                                                            _isSelectionMode = false;
                                                          }
                                                        });
                                                      },
                                                    )
                                                  : null,
                                              title: Text(
                                                note.title,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${DateFormat.jm().format(note.date)}',
                                              ),
                                              trailing: _isSelectionMode && isSelected
                                                  ? null
                                                  : Icon(Icons.chevron_right),
                                            ),
                                            Visibility(
                                              visible: !isLastItem,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left:18.0),
                                                child: Divider(
                                                  color: Colors.grey[300],
                                                  thickness: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        //cupertinonav
        bottomNavigationBar: BottomAppBar(
          elevation: 10,
          color: Colors.white.withOpacity(0.7),
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    editNote(
                      'Add Note',
                    );
                  },
                  iconSize: 30.0,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editNote(String appBarTitle, [Note? note]) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NoteDetail(
          appBarTitle: appBarTitle,
          note: note,
          onAdd: (note) {
            addNote(note);
          },
          onEdit: (note) {
            int index = _myNotes.indexWhere((element) => element.title == note.title);
            _myNotes[index] = note;
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
