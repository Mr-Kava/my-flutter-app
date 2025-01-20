import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<Task>> futureTasks;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    futureTasks = DatabaseHelper().getTasks();
    futureTasks.then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  void _toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper().updateTask(task);
    setState(() {});
  }

  void _deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Задачи'),
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет задач'));
          } else {
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                Task task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  trailing: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => _toggleTaskCompletion(task),
                  ),
                  onLongPress: () => _deleteTask(task.id!),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          if (result == true) {
            setState(() {
              futureTasks = DatabaseHelper().getTasks();
              futureTasks.then((value) {
                setState(() {
                  tasks = value;
                });
              });
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
