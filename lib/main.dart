import 'package:flutter/material.dart';
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
      title: 'Flutter Demo',
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

  // Method to add a new todo item
  void _addTodoItem(String title) {
    setState(() {
      _todoItems.add(TodoItem(title: title));
    });
  }

  // Method to toggle the completion status of a todo item
  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isDone = !_todoItems[index].isDone;
    });
  }

  // Method to delete a todo item
  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  // Method to prompt the user to add a new todo item
  void _promptAddTodoItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodoTitle = '';
        return AlertDialog(
          title: const Text('Add a new task'),
          content: TextField(
            onChanged: (value) {
              newTodoTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter task here'),
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
                  _addTodoItem(newTodoTitle);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          final todoItem = _todoItems[index];
          return ListTile(
            title: Text(
              todoItem.title,
              style: TextStyle(
                decoration: todoItem.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todoItem.isDone,
                  onChanged: (bool? value) {
                    _toggleTodoItem(index);
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddTodoItem,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
