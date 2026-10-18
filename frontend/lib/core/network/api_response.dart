import 'package:dio/dio.dart';

/// Helpers for the API envelope: { success, data, pagination? }
extension ApiResponse on Response<dynamic> {
  Map<String, dynamic> get body => data as Map<String, dynamic>;
  Map<String, dynamic> get dataMap => body['data'] as Map<String, dynamic>;
  List<dynamic> get dataList => body['data'] as List<dynamic>;
}
