import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: TaskScreen()));
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List tasks = [];
  final TextEditingController _controller = TextEditingController();

  // final String baseUrl = 'http://127.0.0.1:8000/api/tasks';
  final String baseUrl = 'http://192.168.0.233:8000/api';

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/tasks"));
    debugPrint("getstatus code: ${response.statusCode}");
    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body);
      });
    }
  }

  Future<void> addTask(String title) async {
    print('Adding task: $title');
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/task/store"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'title': title}),
      );
      print('Response body: ${response.body}');
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        _controller.clear();
        fetchTasks(); // নতুন task যোগ হলে লিস্ট রিফ্রেশ করো
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo App")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Enter task"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addTask(_controller.text);
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(tasks[index]['title']));
              },
            ),
          ),
        ],
      ),
    );
  }
}
