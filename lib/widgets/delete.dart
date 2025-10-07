import 'dart:io';

import 'package:flutter/material.dart';

class Delete extends StatefulWidget {
  const Delete({super.key, required this.path, required this.lastDelete});
  final String path;
  final Function lastDelete;
  @override
  State<Delete> createState() => _DeleteState();
}

class _DeleteState extends State<Delete> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:  Container(
                  width: 45,
                  height: 45,
                  child: Icon(Icons.delete_rounded),
                                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(200),
                    borderRadius: BorderRadius.circular(50)
                  ),
                ),
                onTap: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text("Подтверждение"),
                      content: Text('Вы уверены что хотит уалить фотографию?'),
                      actions: [
                        TextButton(onPressed: () async {
                          await File(widget.path).delete();
                          Navigator.pop(context);
                          widget.lastDelete();
                        }, style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ), child: Text('ок')),
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ), child: Text('отмена'))
                      ],
                    );
                  }
                  );
                },
    );
  }
}