// Model class representing a Todo item
class TodoItem {
  // Title of the todo item
  String title;

  // Boolean indicating whether the todo item is done
  bool isDone;

  // Deadline of the todo item
  final DateTime deadline;

  // Constructor to initialize the todo item
  TodoItem({required this.title, this.isDone = false, required this.deadline});

  // Convert a TodoItem into a Map. The keys must correspond to the names of the fields.
  Map<String, dynamic> toJson() => {
    'title': title,
    'deadline': deadline.toIso8601String(),
    'isDone': isDone,
  };

  // Convert a Map into a TodoItem.
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      deadline: DateTime.parse(json['deadline']),
      isDone: json['isDone'],
    );
  }
}
