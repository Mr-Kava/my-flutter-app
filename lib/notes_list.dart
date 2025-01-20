import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';
import 'add_note_screen.dart';
import 'view_note_screen.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late Future<List<Note>> futureNotes;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    futureNotes = DatabaseHelper().getNotes();
    futureNotes.then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen()),
    );

    if (result == true) {
      setState(() {
        futureNotes = DatabaseHelper().getNotes();
        futureNotes.then((value) {
          setState(() {
            notes = value;
          });
        });
      });
    }
  }

  void _viewNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewNoteScreen(note: note),
      ),
    );

    if (result == true) {
      setState(() {
        futureNotes = DatabaseHelper().getNotes();
        futureNotes.then((value) {
          setState(() {
            notes = value;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Заметки'),
      ),
      body: FutureBuilder<List<Note>>(
        future: futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет заметок'));
          } else {
            return ReorderableGridView.count(
              padding: const EdgeInsets.all(16.0),
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              children: List.generate(notes.length, (index) {
                Note note = notes[index];
                return GestureDetector(
                  key: Key(note.id
                      .toString()), // Уникальный ключ для каждого элемента
                  onTap: () => _viewNote(note),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF4E586E) : Colors.grey[200]!,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Color(0xFF80CBC4),
                        width: 1.0,
                      ),
                      boxShadow: [
                        //тень
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            note.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${note.date.day}/${note.date.month}/${note.date.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final Note note = notes
                      .removeAt(oldIndex); // Удаляем элемент из старой позиции
                  notes.insert(
                      newIndex, note); // Вставляем элемент в новую позицию
                });
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
