import 'package:equatable/equatable.dart';

import 'task.dart';

class TaskPage extends Equatable {
  const TaskPage({
    required this.items,
    required this.page,
    required this.total,
    required this.totalPages,
  });

  final List<Task> items;
  final int page;
  final int total;
  final int totalPages;

  @override
  List<Object?> get props => [items, page, total, totalPages];
}
