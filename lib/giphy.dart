

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy Get Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
),
      home: const MyHomePage1(title: 'Giphy Get Demo'),
    );
  }
}

class MyHomePage1 extends StatefulWidget {
  final String title;
  const MyHomePage1({super.key, required this.title});
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePage1State createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {

  //Gif
  late GiphyGif currentGif;


  // Random ID
  String randomId = "";

  String giphyApiKey = 'jFnxL5RmNTXCtaTPQNQR60L44sY6nScv';

  @override
  void initState() {
    super.initState();

    GiphyClient client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      client.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return GiphyGetWrapper(
        giphy_api_key: giphyApiKey,
        builder: (stream, giphyGetWrapper) {
          stream.listen((gif) {
            setState(() {
               currentGif = gif;
            });
          });

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset("assets/img/GIPHY Transparent 18px.png"),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text("GET DEMO")
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text("Dark Mode")),
                      Switch(
                          value:
                          Theme.of(context).brightness == Brightness.dark,
                          onChanged: (value) {

                          })
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text("Material 3")),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Random ID: $randomId"),
                  const Text(
                    "Selected GIF",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  currentGif != null
                      ? SizedBox(
                    child: GiphyGifWidget(
                      imageAlignment: Alignment.center,
                      gif: currentGif,
                      giphyGetWrapper: giphyGetWrapper,
                      borderRadius: BorderRadius.circular(30),
                      showGiphyLabel: true,
                    ),
                  )
                      : const Text("No GIF")
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  giphyGetWrapper.getGif(
                    '',
                    context,
                    showGIFs: true,
                    showStickers: true,
                    showEmojis: true,
                  );
                },
                tooltip: 'Open Sticker',
                child: const Icon(Icons
                    .insert_emoticon)), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}