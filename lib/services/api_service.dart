import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/tracko_api/tasks_api.php';
  static const Map<String, String> _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<List<Task>> getAllTasks() async {
    final res = await http
        .get(Uri.parse(baseUrl), headers: _h)
        .timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode == 200 && body['success'] == true)
      return (body['data'] as List).map((j) => Task.fromJson(j)).toList();
    throw Exception(body['message'] ?? 'Failed to fetch');
  }

  Future<Task> addTask(String title, String priority, String? deadline) async {
    final res = await http
        .post(Uri.parse(baseUrl),
            headers: _h,
            body: json.encode(
                {'title': title, 'priority': priority, 'deadline': deadline}))
        .timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode == 201 && body['success'] == true)
      return Task.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to add');
  }

  Future<Task> updateTask(int id,
      {String? title,
      String? priority,
      String? deadline,
      bool clearDeadline = false}) async {
    final Map<String, dynamic> payload = {'id': id};
    if (title != null) payload['title'] = title;
    if (priority != null) payload['priority'] = priority;
    if (clearDeadline)
      payload['deadline'] = null;
    else if (deadline != null) payload['deadline'] = deadline;
    final res = await http
        .put(Uri.parse(baseUrl), headers: _h, body: json.encode(payload))
        .timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode == 200 && body['success'] == true)
      return Task.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to update');
  }

  Future<Task> updateStatus(int id, bool isDone) async {
    final res = await http
        .put(Uri.parse(baseUrl),
            headers: _h, body: json.encode({'id': id, 'is_done': isDone}))
        .timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode == 200 && body['success'] == true)
      return Task.fromJson(body['data']);
    throw Exception(body['message'] ?? 'Failed to update status');
  }

  Future<void> deleteTask(int id) async {
    final res = await http
        .delete(Uri.parse(baseUrl), headers: _h, body: json.encode({'id': id}))
        .timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (body['success'] != true)
      throw Exception(body['message'] ?? 'Failed to delete');
  }
}
