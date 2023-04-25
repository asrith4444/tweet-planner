import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tweet_planner/giphy.dart';
import 'screens/write.dart';
final supabaseUrl = 'https://qvxuhaqiyeudixntmuur.supabase.co';
final supabaseKey = String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2eHVoYXFpeWV1ZGl4bnRtdXVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIzMTU3NzgsImV4cCI6MTk5Nzg5MTc3OH0.U9CyKz97JY7BF3l5bUwAnbrOQa3mVL0I1iuuLEYFyIM');
Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}
//final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print(Supabase.instance.client.storageUrl);
    return MaterialApp(
      title: 'Tweet Planner',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Tweet Planner'),
      routes: {
        Write.route : (context)=> Write(),
        '/giphy': (context)=> MyHomePage1(title: 'HI Go GIF')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have no scheduled tweets, add some!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, Write.route);
        },
        tooltip: 'Schedule',
        child: const Icon(Icons.flash_on),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
