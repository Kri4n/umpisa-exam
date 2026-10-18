import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_input.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /tasks
  Future<TaskPageModel> getTasks(TaskFilter filter) {
    return guardApi(() async {
      final res = await _dio.get<dynamic>(
        '/tasks',
        queryParameters: {
          'page': filter.page,
          'limit': filter.limit,
          if (filter.projectId != null) 'projectId': filter.projectId,
          if (filter.status != null) 'status': filter.status!.apiValue,
          if (filter.priority != null) 'priority': filter.priority!.apiValue,
          if (filter.search.isNotEmpty) 'search': filter.search,
        },
      );
      return TaskPageModel.fromJson(res.body);
    });
  }

  /// GET /tasks/:id
  Future<TaskModel> getTask(String id) {
    return guardApi(() async {
      final res = await _dio.get<dynamic>('/tasks/$id');
      return TaskModel.fromJson(res.dataMap);
    });
  }

  /// POST /tasks
  Future<TaskModel> createTask(TaskInput input) {
    return guardApi(() async {
      final res = await _dio.post<dynamic>('/tasks', data: _toJson(input));
      return TaskModel.fromJson(res.dataMap);
    });
  }

  /// PATCH /tasks/:id  (full edit; `dueDate: null` clears the due date)
  Future<TaskModel> updateTask(String id, TaskInput input) {
    return guardApi(() async {
      final res = await _dio.patch<dynamic>('/tasks/$id', data: _toJson(input));
      return TaskModel.fromJson(res.dataMap);
    });
  }

  /// PATCH /tasks/:id  { status: "completed" }
  Future<TaskModel> completeTask(String id) {
    return guardApi(() async {
      final res = await _dio.patch<dynamic>('/tasks/$id', data: {'status': 'completed'});
      return TaskModel.fromJson(res.dataMap);
    });
  }

  /// DELETE /tasks/:id
  Future<void> deleteTask(String id) {
    return guardApi(() async {
      await _dio.delete<dynamic>('/tasks/$id');
    });
  }

  Map<String, dynamic> _toJson(TaskInput input) => {
        'projectId': input.projectId,
        'title': input.title,
        'description': input.description,
        'status': input.status.apiValue,
        'priority': input.priority.apiValue,
        'dueDate': input.dueDate?.toUtc().toIso8601String(),
      };
}
