import 'package:cloud_portrait/data/googleSignIn.dart';
import 'package:cloud_portrait/presentation/listViewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  void initState() {
    FirebaseAuth.instance.userChanges().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(child: ListViewer()),
                  bottomBar(),
                ],
              ),
            ),
          )
        : _loginScreen();
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

  _loginScreen() {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: InkWell(
            onTap: () {
              MyGoogleSignIn().signInWithGoogle();
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  height: 150,
                  width: 150,
                  child: Image.asset('lib/data/assets/logo-google.png')),
            ),
          ),
        ),
      ),
    );
  }
}
