import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';
import 'add_note_screen.dart';

class ViewNoteScreen extends StatefulWidget {
  final Note note;

  ViewNoteScreen({required this.note});

  @override
  _ViewNoteScreenState createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  void _editNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          note: widget.note,
          titleController: _titleController,
          contentController: _contentController,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        widget.note.title = _titleController.text;
        widget.note.content = _contentController.text;
      });
      Navigator.pop(context, true);
    }
  }

  void _deleteNote() async {
    await DatabaseHelper().deleteNote(widget.note.id!);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editNote,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.note.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.note.content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${widget.note.date.day}/${widget.note.date.month}/${widget.note.date.year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
