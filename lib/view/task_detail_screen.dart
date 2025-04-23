import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.description),
              SizedBox(height: 12),
              Text('Trạng thái: ${task.status}'),
              Text('Độ ưu tiên: ${task.priority}'),
              Text('Hạn hoàn thành: ${task.dueDate ?? 'Không có'}'),
              Text('Người giao: ${task.createdBy}'),
              Text('Người nhận: ${task.assignedTo ?? 'Chưa gán'}'),
              Text('Phân loại: ${task.category ?? 'Không có'}'),
              Text('Hoàn thành: ${task.completed ? 'Có' : 'Chưa'}'),
              Text('Đính kèm:'),
              ...(task.attachments).map((url) => Text(url)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Chuyển sang màn hình sửa
                  Navigator.pushNamed(
                    context,
                    '/task/edit',
                    arguments: task,
                  );
                },
                child: Text('Cập nhật trạng thái'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
