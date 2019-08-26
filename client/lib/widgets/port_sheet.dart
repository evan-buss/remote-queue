import 'package:flutter/material.dart';

class PortSheet extends StatelessWidget {
  final TextEditingController controller;

  PortSheet(this.controller);

  @override
  Widget build(BuildContext context) {
    // Show a ModalBottomSheet to change port number
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(
            "Server Port",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              RaisedButton(
                child: Text("SAVE"),
                onPressed: () {
                  Navigator.pop(context, int.parse(controller.text));
                },
              )
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        )
      ],
    );
  }
}
