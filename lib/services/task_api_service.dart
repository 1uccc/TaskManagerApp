import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:taskmanager/models/task.dart';

class TaskAPIService {
  final String _baseUrl = 'http://10.0.2.2:5000/api/tasks';

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      print("Token: $token");
      return token;
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((task) => TaskModel.fromJson(task)).toList();
    } else {
      throw Exception('Lỗi khi tải công việc: ${response.body}');
    }
  }

  Future<void> createTask(Map<String, dynamic> data, {File? file}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token hết hạn hoặc không hợp lệ');
    }

    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/create'));
    request.headers['Authorization'] = 'Bearer $token';

    // Thêm các trường công việc vào request
    request.fields.addAll({
      'title': data['title'],
      'description': data['description'],
      'status': data['status'],
      'priority': data['priority'],
      'category': data['category'],
      'assignedTo': data['assignedTo'] ?? '',
      'completed': data['completed'].toString(),
      'dueDate': data['dueDate'],
    });

    // Chỉ thêm tệp khi có tệp đính kèm
    if (file != null) {
      final mimeType = mime(file.path) ?? 'application/octet-stream';
      final fileType = mimeType.split('/');
      request.files.add(http.MultipartFile(
        'attachment',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.uri.pathSegments.last,
        contentType: MediaType(fileType[0], fileType[1]),
      ));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 401) {
        throw Exception('Token hết hạn hoặc không hợp lệ');
      }

      if (response.statusCode != 201) {
        final body = await response.stream.bytesToString();
        throw Exception('Tạo công việc thất bại: $body');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo công việc: $e');
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data, {File? file}) async {
    final token = await _getToken();
    var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/$id'));

    request.headers['Authorization'] = 'Bearer $token';

    // Thêm các trường công việc vào request
    request.fields.addAll({
      'title': data['title'],
      'description': data['description'],
      'status': data['status'],
      'priority': data['priority'],
      'category': data['category'],
      'assignedTo': data['assignedTo'] ?? '',
      'completed': data['completed'].toString(),
      'dueDate': data['dueDate'],
    });

    // Chỉ thêm tệp khi có tệp đính kèm
    if (file != null) {
      final mimeType = mime(file.path) ?? 'application/octet-stream';
      final fileType = mimeType.split('/');
      request.files.add(http.MultipartFile(
        'attachment',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.uri.pathSegments.last,
        contentType: MediaType(fileType[0], fileType[1]),
      ));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 401) {
        throw Exception('Token hết hạn hoặc không hợp lệ');
      }

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('Cập nhật công việc thất bại: $body');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật công việc: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode != 200) {
      throw Exception('Xóa thất bại: ${response.body}');
    }
  }

  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/$taskId/status');
    //final url = Uri.parse('http://10.0.2.2:5000/api/tasks/$taskId/status'); _baseUrl hay bị lỗi nhận diện

    // Chỉ gửi trường status trong body
    final body = jsonEncode({
      'status': newStatus,
    });

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật trạng thái thất bại: ${response.body}');
    }

    return response.statusCode == 200;
  }
}
