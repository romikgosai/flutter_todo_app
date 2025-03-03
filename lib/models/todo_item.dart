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
}
