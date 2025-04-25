import 'package:flutter/material.dart';
import 'package:taskmanager/view/task_edit_screen.dart';
import '../services/task_api_service.dart';
import 'task_detail_screen.dart';
import 'task_add_screen.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskAPIService _taskService = TaskAPIService();
  late Future<List<TaskModel>> _tasks;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _taskService.getAllTasks();
    });
  }

  void _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _taskService.deleteTask(taskId); // Gọi API để xóa công việc
      _loadTasks();  // Gọi lại hàm để tải lại danh sách công việc
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Công việc"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm công việc...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (value) => setState(() => _searchKeyword = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải dữ liệu:\n${snapshot.error}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final tasks = snapshot.data!
              .where((task) => task.title.toLowerCase().contains(_searchKeyword))
              .toList();

          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có công việc nào', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final status = task.status.toLowerCase();
              final statusColor = status == 'done'
                  ? Colors.green
                  : status == 'in progress'
                  ? Colors.orange
                  : status == 'to do'
                  ? Colors.cyan
                  : Colors.red;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.circle, color: statusColor),
                  title: Text(task.title),
                  subtitle: Text('Trạng thái: ${task.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (_) {
                          final priority = task.priority;

                          Color flagColor;
                          switch (priority) {
                            case 3:
                              flagColor = Colors.red;
                              break;
                            case 2:
                              flagColor = Colors.orange;
                              break;
                            case 1:
                              flagColor = Colors.yellow.shade300;
                              break;
                            default:
                              flagColor = Colors.grey;
                          }

                          return Icon(Icons.flag, color: flagColor);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskEditScreen(task: task),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(task.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskAddScreen()),
          );

          // Sau khi thêm xong, nếu có kết quả, làm mới danh sách
          if (result == true) {
            setState(() {
              _tasks = _taskService.getAllTasks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
