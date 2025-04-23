import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/task_api_service.dart';
import '../models/user.dart';

class TaskAddScreen extends StatefulWidget {
  @override
  _TaskAddScreenState createState() => _TaskAddScreenState();
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chưa đăng nhập')));
        return;
      }

      // Chuyển priority từ String sang int
      int priorityValue = 0;
      switch (_priority) {
        case 'Thấp':
          priorityValue = 1;
          break;
        case 'Trung Bình':
          priorityValue = 2;
          break;
        case 'Cao':
          priorityValue = 3;
          break;
        default:
          priorityValue = 0;
      }

      String priorityString = priorityValue.toString();


      Map<String, dynamic> taskData = {
        'title': _title,
        'description': _description,
        'status': _status,
        'priority': priorityString,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mô tả'),
                onSaved: (value) => _description = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Trạng thái'),
                onChanged: (value) => setState(() => _status = value!),
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                items: _priorityOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Độ ưu tiên'),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Danh mục'),
                onChanged: (value) => setState(() => _category = value!),
              ),
              DropdownButtonFormField<String>(
                value: _assignedTo.isNotEmpty ? _assignedTo : null,
                items: _users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user.id,
                    child: Text(user.username),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _assignedTo = value ?? ''),
                decoration: InputDecoration(labelText: 'Giao cho'),
              ),
              ListTile(
                title: Text(
                  _dueDate != null
                      ? 'Hạn chót: ${_dueDate!.toLocal().toString().split(' ')[0]}'
                      : 'Chọn ngày hết hạn',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              if (_attachment != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Tệp: ${_attachment!.path.split('/').last}'),
                ),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.attach_file),
                label: Text('Chọn tệp đính kèm'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Tạo công việc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
