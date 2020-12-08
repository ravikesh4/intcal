
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Contact newInterest = new Contact();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<double> _rates = <double>[1, 1.5, 2, 2.5, 3, 3.5];
  double _rate;
  var map = new Map<String, dynamic>();

  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Future _startDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now) ? initialDate : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      _startDateController.text = DateFormat.yMd().format(result);
    });
  }
  Future _endDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 2018 && initialDate.isBefore(now) ? initialDate : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2018),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      _endDateController.text = DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try
    {
      var d = DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  bool isValidDob(String dob) {
    if (dob.isEmpty) return true;
    var d = convertToDate(dob);
    return d != null && d.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Interest Calculate')
      ),
      body: SafeArea(
          top: false,
          bottom: false,
          child: Form(
              key: _formKey,
              autovalidate: true,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Interest Calculator', style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      hintText: 'Enter start date',
                      labelText: 'Start Date',
                    ),
                    readOnly: true,
                    controller: _startDateController,
                    validator: (val) => isValidDob(val) ? null : 'Not a valid date',
                    keyboardType: TextInputType.datetime,
                    onTap: () {
                      _startDate(context, _startDateController.text);
                    },
                  ),
                  // Row(children: <Widget>[
                  //   Expanded(
                  //       child: TextFormField(
                  //         decoration: InputDecoration(
                  //           icon: const Icon(Icons.calendar_today_sharp),
                  //           hintText: 'Enter end date',
                  //           labelText: 'End Date',
                  //         ),
                  //         controller: _endDateController,
                  //         validator: (val) => isValidDob(val) ? null : 'Not a valid date',
                  //         keyboardType: TextInputType.datetime,
                  //       )),
                  //   IconButton(
                  //     icon: Icon(Icons.more_horiz),
                  //     tooltip: 'Choose date',
                  //     onPressed: (() {
                  //       _endDate(context, _endDateController.text);
                  //     }),
                  //   )
                  // ]),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today_sharp),
                      hintText: 'Enter end date',
                      labelText: 'End Date',
                    ),
                    readOnly: true,
                    controller: _endDateController,
                    validator: (val) => isValidDob(val) ? null : 'Not a valid date',
                    keyboardType: TextInputType.datetime,
                    onTap: () {
                      _endDate(context, _endDateController.text);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.attach_money),
                      hintText: 'Enter amount',
                      labelText: 'Amount',
                    ),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                  FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.margin),
                          labelText: 'Rate',
                        ),
                        isEmpty: _rate == null,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _rate,
                            isDense: true,
                            onChanged: (double newValue) {
                              setState(() {
                                newInterest.rate = newValue;
                                _rate = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _rates.map((double value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    validator: (val) {
                      return val != '' ? null : 'Please select a rate';
                    },
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: RaisedButton(
                        child: const Text('Submit'),
                        onPressed: _submitForm
                      )),
                ],
              ))),
    );
  }

  // Future<Interest> createAlbum() async {
  //   final FormState form = _formKey.currentState;
  //   form.save();
  //   map['start_date'] = _startDateController.text;
  //   map['end_date'] = _endDateController.text;
  //   map['amount'] = _amountController.text;
  //   map['rate'] = newInterest.rate;
  //   print(map);
  //
  //   final http.Response response = await http.post(
  //     'https://jsonplaceholder.typicode.com/albums',
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(map),
  //   );
  //   if (response.statusCode == 201) {
  //     // If the server did return a 201 CREATED response,
  //     // then parse the JSON.
  //     return Interest.fromJson(jsonDecode(response.body));
  //   } else {
  //     // If the server did not return a 201 CREATED response,
  //     // then throw an exception.
  //     throw Exception('Failed to load album');
  //   }
  // }


  void _submitForm() {
    final FormState form = _formKey.currentState;
    form.save();
    map['start_date'] = _startDateController.text;
    map['end_date'] = _endDateController.text;
    map['amount'] = _amountController.text;
    map['rate'] = newInterest.rate;
    print(map);
  }

}


class Contact {
  DateTime startDate;
  DateTime endDate;
  int amount;
  double rate;
}

class Interest {
  final String startDate;
  final String endDate;
  final int amount;
  final int rate;

  Interest({this.startDate, this.endDate, this.amount, this.rate});

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      startDate: json['start_date'],
      endDate: json['end_date'],
      amount: json['amount'],
      rate: json['rate'],
    );
  }
}
