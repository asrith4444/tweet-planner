import 'package:flutter/material.dart';
import 'package:tweet_planner/models/media.dart';
import 'package:tweet_planner/models/poll.dart';

class Tweet {
  //final int userId;
  int index;
  Tweet({required this.index});
  bool isThread = false;
  //String text;
  bool isPoll = false;
  bool isMedia = false;
  Poll? poll;
  Media? media;
  Map? thread;
  final textController = TextEditingController();

  TextEditingController getTextController() {
    return textController;
  }

  String getTweetData() {
    String data =
        '{ text: ${textController.text}, isPoll: $isPoll, poll: {duration: ${poll?.getDurationMinutes()} , options: [${poll?.choice1.text}]}}';
    return data;
  }
}
