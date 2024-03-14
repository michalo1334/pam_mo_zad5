import 'package:flutter/material.dart';
import 'package:mo_zad5/model/task.dart';
import 'package:mo_zad5/model/taskListDbProxy.dart';
import 'package:mo_zad5/view/task_details_widget.dart';
import 'package:mo_zad5/view/task_list_entry_widget.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> _initTasks;

  const TaskListWidget(this._initTasks, {super.key});

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget._initTasks;
  }

  void addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  dispose() {
    (_tasks as TaskListDbProxy).closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return TaskListEntryWidget(index, _tasks, removeTask, refresh);
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            addTask(Task.empty());
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetailsWidget(_tasks.last, refresh, _tasks)));
          },
          child: const Icon(Icons.add)
      ),
    );
  }
}