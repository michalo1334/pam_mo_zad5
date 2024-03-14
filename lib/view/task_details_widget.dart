import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/model/task.dart';
import '/model/taskListDbProxy.dart';

class TaskDetailsWidget extends StatefulWidget {
  final Task _initTask;
  final Function _updateParentCB;
  final List<Task> _tasks;

  const TaskDetailsWidget(this._initTask, this._updateParentCB, this._tasks, {super.key});

  @override
  _TaskDetailsWidgetState createState() => _TaskDetailsWidgetState();
}

class _TaskDetailsWidgetState extends State<TaskDetailsWidget> {
  late final Task _task;
  late final Task _taskWorkingCopy;

  late final TextEditingController _ctrlName;
  late final TextEditingController _ctrlDesc;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _task = widget._initTask;
    _taskWorkingCopy = Task(_task.name, _task.desc, _task.date, _task.priority);

    _ctrlName = TextEditingController(text: _taskWorkingCopy.name);
    _ctrlDesc = TextEditingController(text: _taskWorkingCopy.desc);
  }

  void saveChanges() {
    setState(() {
      _task.name = _taskWorkingCopy.name;
      _task.priority = _taskWorkingCopy.priority;
      _task.date = _taskWorkingCopy.date;
      _task.desc = _taskWorkingCopy.desc;
      _hasUnsavedChanges = false;

      (widget._tasks as TaskListDbProxy).commitRecords();

      widget._updateParentCB();
    });
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

  Widget buildTaskPriorityPopUpMenu() {
    return PopupMenuButton(
      onSelected: (TaskPriority value) {
        setState(() {
          _taskWorkingCopy.priority = value;
          _hasUnsavedChanges = true;
        });
      },
      itemBuilder: (BuildContext context) {
        return TaskPriority.values.map((TaskPriority priority) {
          return PopupMenuItem(
            value: priority,
            child: Text((priority.index + 1).toString(),
                style:
                    TextStyle(color: colorForPriority(priority, text: true))),
          );
        }).toList();
      },
    );
  }

  //priority indicator, TASK NAME (editable)
  Widget buildTaskNameBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text((_taskWorkingCopy.priority.index + 1).toString(),
              style: TextStyle(
                  fontSize: 20,
                  color:
                      colorForPriority(_taskWorkingCopy.priority, text: true))),
          buildTaskPriorityPopUpMenu(),
          Expanded(
            child: TextField(
              controller: _ctrlName,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                hintStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                hintText: 'Task name',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _taskWorkingCopy.name = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ),
          /* Task start date widget */
          //align right
          buildStartDateWidget(),
        ],
      ),
    );
  }

  Widget buildStartDateWidget() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        child: Text(
          DateFormat('yyyy-MM-dd').format(_taskWorkingCopy.date),
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
        onPressed: () {
          showDatePicker(
            context: context,
            initialDate: _taskWorkingCopy.date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          ).then((selectedDate) {
            if (selectedDate != null) {
              setState(() {
                _taskWorkingCopy.date = selectedDate;
                _hasUnsavedChanges = true;
              });
            }
          });
        },
      ),
    );
  }

  Widget buildTaskDescBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _ctrlDesc,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _taskWorkingCopy.desc = value;
            _hasUnsavedChanges = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Szczegóły zadania"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Container(
          color: colorForPriority(_taskWorkingCopy.priority),
          child: Column(
            children: [
              buildTaskNameBar(),
              buildTaskDescBody(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _hasUnsavedChanges ? Colors.red : Colors.green,
          onPressed: () {
            saveChanges();
          },
          child: const Icon(Icons.save),
        ));
  }

  @override
  void dispose() {
    _ctrlName.dispose();
    _ctrlDesc.dispose();
    super.dispose();
  }
}
