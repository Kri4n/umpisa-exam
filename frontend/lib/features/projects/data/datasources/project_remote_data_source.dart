import 'package:dio/dio.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/network/api_response.dart';
import '../models/project_model.dart';

class ProjectRemoteDataSource {
  const ProjectRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /projects   ([archived]: "true" | "false" | "all")
  Future<List<ProjectModel>> getProjects({required String archived, String? search}) {
    return guardApi(() async {
      final res = await _dio.get<dynamic>(
        '/projects',
        queryParameters: {
          'archived': archived,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return res.dataList
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET /projects/:id
  Future<ProjectModel> getProject(String id) {
    return guardApi(() async {
      final res = await _dio.get<dynamic>('/projects/$id');
      return ProjectModel.fromJson(res.dataMap);
    });
  }

  /// POST /projects
  Future<ProjectModel> createProject({required String name, required String description}) {
    return guardApi(() async {
      final res = await _dio.post<dynamic>(
        '/projects',
        data: {'name': name, 'description': description},
      );
      return ProjectModel.fromJson(res.dataMap);
    });
  }

  /// PATCH /projects/:id
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> changes) {
    return guardApi(() async {
      final res = await _dio.patch<dynamic>('/projects/$id', data: changes);
      return ProjectModel.fromJson(res.dataMap);
    });
  }
}
