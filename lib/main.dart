import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    title: "Lista de tarefas",
    home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  List _toDoList = [];

  Future<File> _getFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    File file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      File file = await _getFile();
      return file.readAsString();
    } catch(e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.red
      ),
    );
  }
}