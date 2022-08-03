import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Displays detailed information about a SampleItem.
class GuessFormView extends StatefulWidget {
  const GuessFormView({Key? key}) : super(key: key);

  static const routeName = '/guess';

  @override
  State<GuessFormView> createState() => _GuessFormViewState();
}

class _GuessFormViewState extends State<GuessFormView> {
  final _formKey = GlobalKey<FormState>();
  final _box = Hive.box('guessess');
  final _nameInputController = TextEditingController();
  final _guessInputController = TextEditingController();

  String? name;
  String? guess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kronkorken Schätzung'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Wie viele Kronkorken befinden sich im Gefäss?",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              TextFormField(
                controller: _nameInputController,
                validator: nameValidator,
                decoration: const InputDecoration(labelText: 'Dein Name'),
                onSaved: (newValue) => setState(() {
                  name = newValue;
                }),
              ),
              TextFormField(
                controller: _guessInputController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  // for version 2 and greater youcan also use this
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(labelText: 'Deine Schätzung'),
                validator: guessValidator,
                onSaved: (newValue) => setState(() {
                  guess = newValue;
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                    onPressed: onPressed,
                    child: const Text("Schätzung absenden")),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onPressed() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      form.save();
      _box.put(name, guess);
      _guessInputController.clear();
      _nameInputController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Danke für deine Schätzung'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Bitte gib deinen namen ein";
    }
    if (_box.containsKey(value)) {
      return "Jemand hat schon den selben Namen verwendet.";
    }
  }

  String? guessValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Bitte gib deine Schätzung ein";
    }
    if (int.tryParse(value) == null) {
      return "$value ist keine gültige Zahl";
    }
  }
}
