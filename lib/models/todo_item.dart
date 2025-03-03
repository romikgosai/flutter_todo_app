// Model class representing a Todo item
class TodoItem {
  // Title of the todo item
  String title;

  // Boolean indicating whether the todo item is done
  bool isDone;

  // Constructor to initialize the todo item
  TodoItem({required this.title, this.isDone = false});
}
