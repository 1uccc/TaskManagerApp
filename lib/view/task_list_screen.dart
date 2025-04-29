import 'package:flutter/material.dart';
import '../services/task_api_service.dart';
import '../models/task.dart';
import 'task_add_screen.dart';
import 'task_edit_screen.dart';
import 'task_detail_screen.dart';
import 'task_list_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskAPIService _taskService = TaskAPIService();
  late Future<List<TaskModel>> _tasks;
  String _searchKeyword = '';
  bool _isListView = true;
  String _selectedCategory = '';
  String _selectedStatus = '';


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _taskService.getAllTasks();
      _selectedCategory = '';
      _selectedStatus = '';
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
      try {
        await _taskService.deleteTask(taskId);
        _loadTasks();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Danh sách Công việc"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
          IconButton(
            icon: Icon(_isListView ? Icons.view_column : Icons.view_agenda),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm công việc...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onChanged: (value) => setState(() => _searchKeyword = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text("Trạng thái"),
                  value: _selectedStatus.isEmpty ? null : _selectedStatus,
                  items: ['To do', 'In progress', 'Done', 'Cancelled'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text("Danh mục"),
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  items: ['Work', 'Personal', 'Study'].map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff66fb9a), Color(0xff002d88)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<TaskModel>>(
          future: _tasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi khi tải dữ liệu:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final tasks = snapshot.data!
                .where((task) => task.title.toLowerCase().contains(_searchKeyword) &&
                (_selectedStatus.isEmpty || task.status == _selectedStatus) &&
                (_selectedCategory.isEmpty || task.category == _selectedCategory))
                .toList();

            tasks.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

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

            if (_isListView) {
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskListItem(
                    task: task,
                    onDelete: _deleteTask,
                    onRefresh: _loadTasks,
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumnWidget('To do', tasks),
                      _buildKanbanColumnWidget('In progress', tasks),
                      _buildKanbanColumnWidget('Done', tasks),
                      _buildKanbanColumnWidget('Cancelled', tasks),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[300],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskAddScreen()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        child:
        const Icon(color: Colors.black ,Icons.add),
      ),
    );
  }
  Widget _buildPriorityFlag(int? priority) {
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

    return Icon(Icons.flag, size: 16, color: flagColor);
  }

  Widget _buildKanbanColumnWidget(String title, List<TaskModel> tasks) {
    final filteredTasks = tasks.where((task) => task.status.toLowerCase() == title.toLowerCase()).toList();

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...filteredTasks.map((task) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(task: task),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 10),
                        _buildPriorityFlag(task.priority),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskEditScreen(task: task),
                              ),
                            );
                            if (result == true) {
                              _loadTasks();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

}
