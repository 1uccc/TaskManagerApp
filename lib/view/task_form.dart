import 'package:flutter/material.dart';

class TaskForm extends StatefulWidget {
  final Map<String, dynamic> task;
  final void Function(Map<String, dynamic> updatedTask) onSubmit;

  const TaskForm({super.key, required this.task, required this.onSubmit});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late Map<String, dynamic> _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _saveTask() {
    widget.onSubmit(_task);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Tiêu đề'),
            controller: TextEditingController(text: _task['title']),
            onChanged: (value) => setState(() => _task['title'] = value),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Mô tả'),
            controller: TextEditingController(text: _task['description']),
            onChanged: (value) => setState(() => _task['description'] = value),
          ),
          ElevatedButton(
            onPressed: _saveTask,
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }
}
