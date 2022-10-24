import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud Portrait',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Alan\'s Collections'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: ListViewer()),
            bottomBar(),
          ],
        ),
      ),
    );
  }

  bottomBar() {
    return Container(
      height: 50,
      color: Colors.blue,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              child: newButton(),
            ),
          ),
          Expanded(
            child: Container(
              child: goToPresentation(),
            ),
          ),
          Expanded(
            child: Container(
              child: profile(),
            ),
          ),
        ],
      ),
    );
  }

  newButton() {
    return Container(
      child: bottomBarIcons(Icons.add),
    );
  }

  goToPresentation() {
    return Container(
      child: bottomBarIcons(Icons.playlist_play_rounded),
    );
  }

  profile() {
    return Container(
      child: bottomBarIcons(Icons.account_box_rounded),
    );
  }

  bottomBarIcons(IconData icon) {
    return Icon(
      icon,
      size: 35,
      color: Colors.white.withOpacity(0.9),
    );
  }
}
