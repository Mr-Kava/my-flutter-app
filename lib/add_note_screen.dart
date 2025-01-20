import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final TextEditingController? titleController;
  final TextEditingController? contentController;

  AddNoteScreen({this.note, this.titleController, this.contentController});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = widget.titleController ?? TextEditingController();
    _contentController = widget.contentController ?? TextEditingController();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    Note newNote = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now(),
    );

    if (widget.note == null) {
      await DatabaseHelper().insertNote(newNote);
    } else {
      await DatabaseHelper().updateNote(newNote);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.note == null ? 'Новая заметка' : 'Редактировать заметку'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заглавие',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(),
              ),
              maxLines: 7,
            ),
          ],
        ),
      ),
    );
  }
}
