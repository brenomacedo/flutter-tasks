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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedIndex;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  TextEditingController addController = TextEditingController();

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = addController.text;
      newTodo["ok"] = false;
      addController.text = "";
      _toDoList.add(newTodo);

      _saveData();
    });
  }

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

  Widget buildItem (context, index) {
    return Dismissible(
      background: Container(
        color: Colors.blue,
        child: Align(
          child: Icon(Icons.delete, color: Colors.white),
          alignment: Alignment(-0.9, 0.0),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;

            _saveData();
          });
        },
      ),
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      onDismissed: (direction) {
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedIndex = index;
        
        setState(() {
          _toDoList.removeAt(index);
        });

        _saveData();

        SnackBar snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedIndex, _lastRemoved);
              });
            }
          ),
          duration: Duration(seconds: 2)
        );

        Scaffold.of(context).showSnackBar(snack);

      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.red
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.red),
                    ),
                    controller: addController
                  ),
                ),
                RaisedButton(
                  color: Colors.red,
                  child: Text("Add", style: TextStyle(color: Colors.white)),
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _toDoList.length,
              itemBuilder: buildItem
            )
          )
        ],
      ),
    );
  }
}