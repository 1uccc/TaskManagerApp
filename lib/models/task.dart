class TaskModel {
  String id;
  String title;
  String description;
  String status;
  int priority;
  DateTime dueDate;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String assignedTo;
  String category;
  List<String> attachments;
  bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.assignedTo,
    required this.category,
    required this.attachments,
    required this.completed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing task: ${json['id']}');
      print('Attachments from JSON: ${json['attachments']}');
      print('Type of attachments: ${json['attachments'].runtimeType}');
      print('Title: ${json['title']}');
      print('Due Date: ${json['dueDate']}');
      print('CreatedAt: ${json['createdAt']}');

      return TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        priority: json['priority'] as int,
        dueDate: DateTime.parse(json['dueDate'] as String),
        createdAt: _parseTimestamp(json['createdAt']),
        updatedAt: _parseTimestamp(json['updatedAt']),
        createdBy: json['createdBy'] as String,
        assignedTo: json['assignedTo'] as String,
        category: json['category'] as String,
        completed: json['completed'] as bool,
        attachments: json['attachments'] is List
            ? List<String>.from(json['attachments'].map((x) => x.toString()))
            : [],
      );
    } catch (error) {
      print('Error parsing task: $error');
      rethrow;
    }
  }

  // Hàm để xử lý Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Map<String, dynamic>) {
      // Nếu là Map (Firestore timestamp)
      return DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    }
    // Nếu là String, parse bình thường
    return DateTime.parse(timestamp as String);
  }
}
