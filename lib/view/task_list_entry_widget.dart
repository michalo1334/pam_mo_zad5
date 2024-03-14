import 'package:flutter/material.dart';
import 'package:mo_zad5/model/task.dart';

import 'package:mo_zad5/view/task_details_widget.dart';

class TaskListEntryWidget extends StatefulWidget {
  final int _initTaskIndex;
  final List<Task> _initTaskList;
  final Function removeTaskCallback;
  final Function updateParentCallback;

  const TaskListEntryWidget(this._initTaskIndex, this._initTaskList, this.removeTaskCallback, this.updateParentCallback, {super.key});

  @override
  _TaskListEntryWidgetState createState() => _TaskListEntryWidgetState();
}

class _TaskListEntryWidgetState extends State<TaskListEntryWidget> {
  late List<Task> _taskList;
  late int _taskIndex;

  get _task => _taskList[_taskIndex];

  @override
  void initState() {
    super.initState();
    _taskList = widget._initTaskList;
    _taskIndex = widget._initTaskIndex;
  }

  Color colorForPriority(TaskPriority priority, {bool text = false}) {
    switch (priority) {
      case TaskPriority.low:
        return text ? Colors.green[900]! : Colors.green[100]!;
      case TaskPriority.medium:
        return text ? Colors.yellow[900]! : Colors.yellow[100]!;
      case TaskPriority.high:
        return text ? Colors.red[900]! : Colors.red[100]!;
    }
  }

  void removeFromList() {
    widget.removeTaskCallback(_taskIndex);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetailsWidget(_task, widget.updateParentCallback, _taskList)));
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: colorForPriority(_task.priority, text: false),
          border: Border.all(color: Colors.black12),
        ),
        child: ListTile(
          title: Text(_task.name),
          subtitle: Text(_task.desc),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text((_task.priority.index + 1).toString()),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              removeFromList();
            },
          ),
        ),
      ),
    );
  }
}