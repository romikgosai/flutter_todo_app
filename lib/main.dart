import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/todo_item.dart';

// Entry point of the application
void main() {
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Todo App'),
    );
  }
}

// Home page of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List to store todo items
  final List<TodoItem> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  // Method to load todo items from shared preferences
  void _loadTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoItemsString = prefs.getString('todoItems');
    if (todoItemsString != null) {
      final List<dynamic> todoItemsJson = jsonDecode(todoItemsString);
      setState(() {
        _todoItems.clear();
        _todoItems.addAll(todoItemsJson.map((item) => TodoItem.fromJson(item)));
      });
    }
  }

  // Method to save todo items to shared preferences
  void _saveTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String todoItemsString = jsonEncode(_todoItems);
    await prefs.setString('todoItems', todoItemsString);
  }

  // Method to add a new todo item with a deadline
  void _addTodoItem(String title, DateTime? deadline) {
    setState(() {
      _todoItems.add(
        TodoItem(title: title, deadline: deadline ?? DateTime.now()),
      );
      _saveTodoItems();
    });
  }

  // Method to toggle the completion status of a todo item
  void _toggleTodoItem(TodoItem item) {
    setState(() {
      item.isDone = !item.isDone;
      _saveTodoItems();
    });
  }

  // Method to delete a todo item
  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  // Method to prompt the user to add a new todo item with a deadline
  void _promptAddTodoItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodoTitle = '';
        DateTime? selectedDeadline;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a new task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newTodoTitle = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter task here',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000), // Allow past dates
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDeadline) {
                        setState(() {
                          selectedDeadline = picked;
                        });
                      }
                    },
                    child: Text(
                      selectedDeadline == null
                          ? 'Select Deadline'
                          : 'Deadline: ${selectedDeadline!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (newTodoTitle.isNotEmpty) {
                      _addTodoItem(newTodoTitle, selectedDeadline);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to calculate remaining or exceeded days with color indication
  String _calculateRemainingDays(DateTime deadline) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDay = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    final Duration difference = targetDay.difference(today);

    if (difference.inDays < 0) {
      return '${difference.inDays.abs()} days exceeded';
    } else if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else {
      return '${difference.inDays} days remaining';
    }
  }

  Color _getDeadlineColor(DateTime deadline) {
    final Duration difference = deadline.difference(DateTime.now());
    if (difference.inDays.isNegative) {
      return Colors.red; // Red color for exceeded days
    } else {
      return Colors.black; // Default color for remaining days
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate lists for todos and completed items
    final List<TodoItem> todos =
        _todoItems.where((item) => !item.isDone).toList();
    final List<TodoItem> completed =
        _todoItems.where((item) => item.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 10),
            Text(widget.title),
          ],
        ),
      ),
      body: Column(
        children: [
          if (todos.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Todos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todoItem = todos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ListTile(
                          title: Text(
                            todoItem.title,
                            style: TextStyle(
                              fontSize: 24, // Increased font size
                              fontFamily: 'Roboto', // Modern font
                            ),
                          ),
                          subtitle: Text(
                            _calculateRemainingDays(todoItem.deadline),
                            style: TextStyle(
                              color: _getDeadlineColor(todoItem.deadline),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: todoItem.isDone,
                                onChanged: (bool? value) {
                                  _toggleTodoItem(todoItem);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTodoItem(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (completed.isNotEmpty) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Completed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final todoItem = completed[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ListTile(
                          title: Text(
                            todoItem.title,
                            style: TextStyle(
                              fontSize: 24, // Increased font size
                              fontFamily: 'Roboto', // Modern font
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Text(
                            _calculateRemainingDays(todoItem.deadline),
                            style: TextStyle(
                              color: _getDeadlineColor(todoItem.deadline),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: todoItem.isDone,
                                onChanged: (bool? value) {
                                  _toggleTodoItem(todoItem);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTodoItem(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddTodoItem,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
