import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/task_api_service.dart';
import 'task_form.dart';

class TaskEditScreen extends StatefulWidget {
  final TaskModel task;

  const TaskEditScreen({super.key, required this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}


class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late String _status;
  late String _priority;
  late String _assignedTo;
  late String _category;
  late bool _completed;
  late DateTime? _dueDate;
  File? _attachment;

  final List<String> _statusOptions = ['To do', 'In progress', 'Done', 'Cancelled'];
  final List<String> _priorityOptions = ['Thấp', 'Trung Bình', 'Cao'];
  final List<String> _categoryOptions = ['Work', 'Personal', 'Study'];

  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    final task = widget.task;

    _title = task.title;
    _description = task.description;
    _status = task.status;
    _priority = _mapPriorityValueToText(task.priority.toString());
    _assignedTo = task.assignedTo;
    _category = task.category;
    _completed = task.completed;
    _dueDate = task.dueDate;

    _fetchUsers();
  }


  String _mapPriorityValueToText(String value) {
    switch (value) {
      case '1':
        return 'Thấp';
      case '2':
        return 'Trung Bình';
      case '3':
        return 'Cao';
      default:
        return 'Thấp';
    }
  }

  String _mapPriorityTextToValue(String text) {
    switch (text) {
      case 'Thấp':
        return '1';
      case 'Trung Bình':
        return '2';
      case 'Cao':
        return '3';
      default:
        return '1';
    }
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> updatedData = {
        'title': _title,
        'description': _description,
        'status': _status,
        'priority': _mapPriorityTextToValue(_priority),
        'category': _category,
        'completed': _completed,
        'assignedTo': _assignedTo,
        'dueDate': _dueDate?.toIso8601String(),
      };

      try {
        await TaskAPIService().updateTask(widget.task.id, updatedData, file: _attachment);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật công việc')));
        Navigator.pop(context);
      } catch (e) {
        print('Lỗi khi cập nhật: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa công việc')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TaskForm(
              formKey: _formKey,
              title: _title,
              description: _description,
              status: _status,
              priority: _priority,
              category: _category,
              assignedTo: _assignedTo,
              completed: _completed,
              dueDate: _dueDate,
              attachment: _attachment,
              users: _users,
              statusOptions: _statusOptions,
              priorityOptions: _priorityOptions,
              categoryOptions: _categoryOptions,
              onTitleChanged: (val) => _title = val,
              onDescriptionChanged: (val) => _description = val,
              onStatusChanged: (val) => _status = val,
              onPriorityChanged: (val) => _priority = val,
              onCategoryChanged: (val) => _category = val,
              onAssignedToChanged: (val) => _assignedTo = val,
              onCompletedChanged: (val) => _completed = val,
              onDueDateChanged: (val) => _dueDate = val,
              onAttachmentPicked: (file) => setState(() => _attachment = file),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
