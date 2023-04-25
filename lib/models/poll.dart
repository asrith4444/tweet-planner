import 'package:flutter/material.dart';

class Poll{
  Poll({required this.index});
  int index;
  int days = 0;
  int hours = 2;
  int minutes = 0;
  List<String> options = [];
  int getDurationMinutes(){
    return days*24*60 + hours*60 + minutes;
  }
  TextEditingController choice1 = TextEditingController();
  TextEditingController choice2 = TextEditingController();
  TextEditingController choice3 = TextEditingController();
  TextEditingController choice4 = TextEditingController();
}