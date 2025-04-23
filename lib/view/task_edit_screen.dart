import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskEditScreen extends StatefulWidget {
  final TaskModel task;

  const TaskEditScreen({super.key, required this.task});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final updatedTask = TaskModel(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: widget.task.status,
      priority: widget.task.priority,
      category: widget.task.category,
      completed: widget.task.completed,
      assignedTo: widget.task.assignedTo,
      createdBy: widget.task.createdBy,
      dueDate: widget.task.dueDate,
      createdAt: widget.task.createdAt,
      updatedAt: DateTime.now(),
      attachments: widget.task.attachments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
