import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'task_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../services/task_api_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  UserModel? _assignedUser;
  UserModel? _createdByUser;
  final List<String> _statusOptions = ['To do', 'In progress', 'Done', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (widget.task.assignedTo.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.task.assignedTo)
          .get();

      if (snapshot.exists) {
        setState(() {
          _assignedUser = UserModel.fromMap(snapshot.data()!);
        });
      }
    }

    if (widget.task.createdBy.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.task.createdBy)
          .get();

      if (snapshot.exists) {
        setState(() {
          _createdByUser = UserModel.fromMap(snapshot.data()!);
        });
      }
    }
  }

  String _mapPriority(String value) {
    switch (value) {
      case '1':
        return 'Thấp';
      case '2':
        return 'Trung Bình';
      case '3':
        return 'Cao';
      default:
        return value;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không có';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    final success = await TaskAPIService().updateTaskStatus(widget.task.id!, newStatus);
    if (success) {
      setState(() {
        widget.task.status = newStatus;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cập nhật trạng thái thành công')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cập nhật trạng thái thất bại')));
    }
  }


  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskEditScreen(task: task)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Tiêu đề', task.title),
            _buildDetailRow('Mô tả', task.description),
            _buildDetailRow('Hạn chót', _formatDate(task.dueDate)),
            _buildDetailRow('Trạng thái', task.status),
            _buildDetailRow('Độ ưu tiên', _mapPriority(task.priority.toString())),
            _buildDetailRow('Danh mục', task.category),
            _buildDetailRow('Ngày tạo', _formatDate(task.createdAt)),
            _buildDetailRow('Ngày cập nhật', _formatDate(task.updatedAt)),
            _buildDetailRow('Đã hoàn thành', task.completed ? 'Rồi' : 'Chưa'),
            _buildDetailRow(
              'Người giao',
              _createdByUser != null
                  ? '${_createdByUser!.username} (${_createdByUser!.email})'
                  : 'Không rõ',
            ),
            _buildDetailRow(
              'Người được giao',
              _assignedUser != null
                  ? '${_assignedUser!.username} (${_assignedUser!.email})'
                  : 'Không có',
            ),
            if (task.attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tệp đính kèm:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    ...task.attachments.map(
                          (url) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              url,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: url));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã sao chép liên kết')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cập nhật trạng thái:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: task.status,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != task.status) {
                        _updateStatus(newStatus);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
