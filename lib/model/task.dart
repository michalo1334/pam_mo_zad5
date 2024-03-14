import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task extends ChangeNotifier {
  String _name;
  String _desc;
  DateTime _date;
  TaskPriority _priority;

  int _dbId = -1;

  Task(this._name, this._desc, this._date, this._priority);

  Task.empty() : this('', '', DateTime.now(), TaskPriority.medium);

  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get desc => _desc;
  set desc(String value) {
    _desc = value;
    notifyListeners();
  }

  DateTime get date => _date;
  set date(DateTime value) {
    _date = value;
    notifyListeners();
  }

  TaskPriority get priority => _priority;
  set priority(TaskPriority value) {
    _priority = value;
    notifyListeners();
  }

  int get dbId => _dbId;
  set dbId(int value) {
    _dbId = value;
    notifyListeners();
  }
}

enum TaskPriority {
  low,
  medium,
  high,
}