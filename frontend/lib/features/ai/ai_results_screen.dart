import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String department;
  const ResultScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(child: Text("Go to $department department")),
    );
  }
}
