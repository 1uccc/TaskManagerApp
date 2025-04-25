import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';

class TaskForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String category;
  final String assignedTo;
  final bool completed;
  final DateTime? dueDate;
  final File? attachment;
  final List<UserModel> users;
  final List<String> statusOptions;
  final List<String> priorityOptions;
  final List<String> categoryOptions;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;
  final Function(String) onStatusChanged;
  final Function(String) onPriorityChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onAssignedToChanged;
  final Function(bool) onCompletedChanged;
  final Function(DateTime) onDueDateChanged;
  final Function(File) onAttachmentPicked;

  const TaskForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.assignedTo,
    required this.completed,
    required this.dueDate,
    required this.attachment,
    required this.users,
    required this.statusOptions,
    required this.priorityOptions,
    required this.categoryOptions,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onAssignedToChanged,
    required this.onCompletedChanged,
    required this.onDueDateChanged,
    required this.onAttachmentPicked,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      widget.onAttachmentPicked(file);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      widget.onDueDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: widget.title,
            decoration: InputDecoration(labelText: 'Tiêu đề'),
            validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            onChanged: widget.onTitleChanged,
          ),
          TextFormField(
            initialValue: widget.description,
            decoration: InputDecoration(labelText: 'Mô tả'),
            onChanged: widget.onDescriptionChanged,
          ),
          DropdownButtonFormField<String>(
            value: widget.status,
            decoration: InputDecoration(labelText: 'Trạng thái'),
            items: widget.statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => widget.onStatusChanged(value!),
          ),
          DropdownButtonFormField<String>(
            value: widget.priority,
            decoration: InputDecoration(labelText: 'Độ ưu tiên'),
            items: widget.priorityOptions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (value) => widget.onPriorityChanged(value!),
          ),
          DropdownButtonFormField<String>(
            value: widget.category,
            decoration: InputDecoration(labelText: 'Danh mục'),
            items: widget.categoryOptions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => widget.onCategoryChanged(value!),
          ),
          DropdownButtonFormField<String>(
            value: widget.assignedTo.isNotEmpty ? widget.assignedTo : null,
            decoration: InputDecoration(labelText: 'Giao cho'),
            items: widget.users.map((user) {
              return DropdownMenuItem<String>(
                value: user.id,
                child: Text(user.username),
              );
            }).toList(),
            onChanged: (value) => widget.onAssignedToChanged(value ?? ''),
          ),
          ListTile(
            title: Text(
              widget.dueDate != null
                  ? 'Hạn chót: ${widget.dueDate!.toLocal().toString().split(' ')[0]}'
                  : 'Chọn ngày hết hạn',
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          if (widget.attachment != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Tệp: ${widget.attachment!.path.split('/').last}'),
            ),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: Icon(Icons.attach_file),
            label: Text('Chọn tệp đính kèm'),
          ),
        ],
      ),
    );
  }
}
