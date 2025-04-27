import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';
import 'task_edit_screen.dart';

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final Function(String) onDelete;
  final VoidCallback onRefresh;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskEditScreen(task: task),
                  ),
                );
                if (result == true) {
                  onRefresh();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete(task.id),
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
  }
}
