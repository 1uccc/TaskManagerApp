import 'package:flutter/material.dart';
import '../services/task_api_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskAPIService _taskService = TaskAPIService();
  late Future<Map<String, dynamic>> _task;

  @override
  void initState() {
    super.initState();
    _task = _taskService.getTaskById(widget.taskId);
  }

  void _showStatusDialog(String currentStatus) {
    String selectedStatus = currentStatus;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cập nhật trạng thái"),
          content: DropdownButtonFormField<String>(
            value: currentStatus,
            items: ['todo', 'in_progress', 'done']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              selectedStatus = value!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _taskService.updateTask(widget.taskId, {
                  'status': selectedStatus,
                });
                Navigator.pop(context);
                setState(() {
                  _task = _taskService.getTaskById(widget.taskId);
                });
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskInfo(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            task['title'] ?? 'Không có tiêu đề',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(task['description'] ?? 'Không có mô tả'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 8),
              Text("Hạn: ${task['dueDate'] ?? 'Không xác định'}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flag),
              const SizedBox(width: 8),
              Text("Ưu tiên: ${task['priority'] ?? 'Không xác định'}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle),
              const SizedBox(width: 8),
              Text("Trạng thái: ${task['status'] ?? 'Không rõ'}"),
              const Spacer(),
              TextButton(
                onPressed: () => _showStatusDialog(task['status'] ?? 'todo'),
                child: const Text("Cập nhật"),
              )
            ],
          ),
          const Divider(),
          if (task['attachmentUrl'] != null && task['attachmentUrl'] != '')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tệp đính kèm:"),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // TODO: mở liên kết trong trình duyệt hoặc app
                  },
                  child: Text(
                    task['attachmentUrl'],
                    style: const TextStyle(color: Colors.blue),
                  ),
                )
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết Công việc"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _task,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final task = snapshot.data!;
          return _buildTaskInfo(task);
        },
      ),
    );
  }
}