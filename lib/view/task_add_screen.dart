import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/task_api_service.dart';
import 'task_form.dart';

class TaskAddScreen extends StatefulWidget {
  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _status = 'To do';
  String _priority = 'Cao';
  String _assignedTo = '';
  String _category = 'Work';
  bool _completed = false;
  DateTime? _dueDate;
  File? _attachment;

  final List<String> _statusOptions = ['To do', 'In progress', 'Done', 'Cancelled'];
  final List<String> _priorityOptions = ['Thấp', 'Trung Bình', 'Cao'];
  final List<String> _categoryOptions = ['Work', 'Personal', 'Study'];

  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chưa đăng nhập')));
        return;
      }

      int priorityValue = {
        'Thấp': 1,
        'Trung Bình': 2,
        'Cao': 3,
      }[_priority] ?? 0;

      Map<String, dynamic> taskData = {
        'title': _title,
        'description': _description,
        'status': _status,
        'priority': priorityValue.toString(),
        'category': _category,
        'completed': _completed,
        'assignedTo': _assignedTo,
        'createdBy': user.uid,
        'dueDate': _dueDate?.toIso8601String(),
      };

      try {
        await TaskAPIService().createTask(taskData, file: _attachment);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Công việc đã được tạo')));
        Navigator.pop(context);
      } catch (e) {
        print('Lỗi khi tạo công việc: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tạo công việc: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Công Việc')),
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
              child: Text('Tạo công việc'),
            ),
          ],
        ),
      ),
    );
  }
}
