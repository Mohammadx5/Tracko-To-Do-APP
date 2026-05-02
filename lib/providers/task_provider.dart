import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _autoRefresh;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;

  void _setLoading(bool v) {
    _isLoading = v;
    Future.microtask(() => notifyListeners());
  }

  void _setError(String m) {
    _errorMessage = m;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Auto refresh every 30 seconds ───────────────────────
  void startAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh =
        Timer.periodic(const Duration(seconds: 30), (_) => loadTasks());
  }

  void stopAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  // ── Load ─────────────────────────────────────────────────
  Future<void> loadTasks() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _tasks = await _api.getAllTasks();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return;
    }
    _setLoading(false);
  }

  // ── Add ──────────────────────────────────────────────────
  Future<bool> addTask(String title, String priority, String? deadline) async {
    if (title.trim().isEmpty) {
      _setError('Title cannot be empty');
      return false;
    }
    _setLoading(true);
    try {
      final t = await _api.addTask(title.trim(), priority, deadline);
      _tasks.insert(0, t);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
    _setLoading(false);
    return true;
  }

  // ── Edit ─────────────────────────────────────────────────
  Future<bool> editTask(int id, String title, String priority, String? deadline,
      bool clearDeadline) async {
    if (title.trim().isEmpty) {
      _setError('Title cannot be empty');
      return false;
    }
    _setLoading(true);
    try {
      final u = await _api.updateTask(id,
          title: title.trim(),
          priority: priority,
          deadline: deadline,
          clearDeadline: clearDeadline);
      final i = _tasks.indexWhere((t) => t.id == id);
      if (i != -1) _tasks[i] = u;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
    _setLoading(false);
    return true;
  }

  // ── Toggle ───────────────────────────────────────────────
  Future<void> toggleStatus(int id) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final old = _tasks[i].isDone;
    _tasks[i] = _tasks[i].copyWith(isDone: !old);
    notifyListeners();
    try {
      final u = await _api.updateStatus(id, !old);
      _tasks[i] = u;
    } catch (e) {
      _tasks[i] = _tasks[i].copyWith(isDone: old);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return;
    }
    notifyListeners();
  }

  // ── Delete ───────────────────────────────────────────────
  Future<bool> deleteTask(int id) async {
    _setLoading(true);
    try {
      await _api.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
    _setLoading(false);
    return true;
  }
}
