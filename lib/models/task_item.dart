class TaskItem {
  final String id;
  final String task;
  final DateTime dueDate;
  final String? linkedTransactionId;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.task,
    required this.dueDate,
    this.linkedTransactionId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'due_date': dueDate.millisecondsSinceEpoch,
      'linked_transaction_id': linkedTransactionId,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'],
      task: map['task'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date']),
      linkedTransactionId: map['linked_transaction_id'],
      isCompleted: map['is_completed'] == 1,
    );
  }
}
