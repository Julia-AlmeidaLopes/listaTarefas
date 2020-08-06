import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePageView extends StatefulWidget {
  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  List listaTarefas = [];
  Map<String, dynamic> desfazer;
  int posicaoDesfazer;

  @override
  void initState(){
    super.initState();
    _readTarefa().then((data){
      listaTarefas = json.decode(data);
    });
  }

final tarefasController = TextEditingController();

void addTarefa(){
  setState((){
    Map<String, dynamic> newTarefa = Map();
      newTarefa["title"] = tarefasController.text;
      tarefasController.text = "";
      newTarefa["ok"] = false;
      listaTarefas.add(newTarefa);
      _saveTarefa();
  });
}

    Future<Null> atualizar() async{
    await Future.delayed(Duration(seconds: 1));
   setState(() {
      listaTarefas.sort((a, b){
      if(a["ok"] && !b["ok"]) return 1;
      else if (!a["ok"] && b["ok"]) return -1;
      else return 0;
    });
    _saveTarefa();
   });
   return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.yellow[300],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 6, 8, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: tarefasController,
                    decoration: InputDecoration(
                      labelText: "Add nova tarefa",
                      labelStyle: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                  ),
                ),
                Container(
                  height: 57,
                  width: 44,
                  child: FloatingActionButton(
                    onPressed: addTarefa,
                    child: Icon(Icons.add),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: atualizar,
                child: ListView.builder(
                itemCount: listaTarefas.length,
                itemBuilder: (context, index){
                  return Dismissible(
                    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment(-0.9, 0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: CheckboxListTile(
                      checkColor: Colors.white,
                      activeColor: Colors.green[900],
                      onChanged: (c){
                        setState(() {
                          listaTarefas[index]["ok"] = c;
                          _saveTarefa();
                        });
                      },
                      title: Text(listaTarefas[index] ["title"]),
                      value: listaTarefas[index] ["ok"],
                      secondary: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          listaTarefas[index]["ok"] ? Icons.check : Icons.error,
                          size: 27,
                          color: Colors.white,
                          
                        ),
                      ),
                    ),
                    onDismissed: (direction){
                      setState(() {
                      desfazer = Map.from(listaTarefas[index]);
                      posicaoDesfazer = index;
                      listaTarefas.removeAt(index);
                      _saveTarefa();
                      final snack = SnackBar( 
                        content: Text("Tarefa ${desfazer["title"]} removida"),
                        action: SnackBarAction(label: "Desfazer", onPressed: (){
                          setState(() {
                            listaTarefas.insert(posicaoDesfazer, desfazer);
                          _saveTarefa();
                          });
                        }),
                        duration: Duration(seconds: 3),
                      );
                      Scaffold.of(context).removeCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(snack);
                      });
                    },
                  );
                },
                padding: EdgeInsets.all(10),
              ),
            ),
          )
        ],
      )
    );
  }

  Future<File> _getFile() async{
    //buscando o diretório
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/tarefa.json");
  } 

  Future<File> _saveTarefa() async{
    String tarefa = json.encode(listaTarefas);
    final file = await _getFile();
    return file.writeAsString(tarefa);
  }

  Future<String> _readTarefa() async{
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch (e) {
      return "erro";
    }
  }
}