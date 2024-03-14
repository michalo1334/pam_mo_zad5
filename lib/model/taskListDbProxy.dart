import 'dart:collection';
import 'dart:io';

import 'task.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaskListDbProxy extends ListBase<Task> with ChangeNotifier {
  List<Task> _tasks;
  late Future<Database> _db;

  static Future<Database> _initDB() async {
      var path = join(await getDatabasesPath(), 'default_tasks.db');

      var db = openDatabase(
        path,
        onCreate: (db, version) {
          return db.execute(
              "CREATE TABLE tasks(id INTEGER PRIMARY KEY, name TEXT, desc TEXT, date INTEGER, priority INTEGER)");
        },
        version: 1,
      );


      return await db;
  }

  TaskListDbProxy(this._tasks) {
    _db = _initDB();

    fetchRecords();
  }

  Future<void> fetchRecords() async {
    var records = await (await _db).query('tasks');

    var list = <Task>[];

    for (var record in records) {
      var task = Task(
        record['name'] as String,
        record['desc'] as String,
        DateTime.fromMillisecondsSinceEpoch(record['date'] as int),
        TaskPriority.values[record['priority'] as int],
      )..dbId = record['id'] as int;

      task.addListener(() {syncWithDB();});
      list.add(task);

      _tasks = list;
    }

    notifyListeners();
  }

  Future<void> commitRecords() async {
    (await _db).transaction((txn) async {
      //clear all
      //insert
      await txn.delete('tasks');

      for (var task in _tasks) {
        await txn.insert('tasks', {
          'name': task.name,
          'desc': task.desc,
          'date': task.date.millisecondsSinceEpoch,
          'priority': task.priority.index,
        });
      }
    });
  }

  @override
  int get length => _tasks.length;

  @override
  set length(int newLength) {
    _tasks.length = newLength;
  }

  @override
  void add(Task element) {
    _tasks.add(element);
    syncWithDB();
  }

  @override
  Task removeAt(int index) {
    var newList = _tasks.toList();
    var task = newList.removeAt(index);
    _tasks = newList;
    syncWithDB();
    return task;
  }

  @override
  Task operator [](int index) => _tasks[index];

  @override
  void operator []=(int index, Task value) {
    _tasks[index] = value;
    syncWithDB();
  }

  void closeDb() async {
    (await _db).close();
    notifyListeners();
  }

  void syncWithDB() {
    commitRecords();
  }

  Future<bool> get isDbOpen async {
    return (await _db).isOpen;
  }

}
