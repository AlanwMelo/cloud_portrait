import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_portrait/data/firestore_database/firebaseCollectionManager.dart';
import 'package:cloud_portrait/data/googleSignIn.dart';
import 'package:cloud_portrait/data/navigationController.dart';
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
  NavigationController navigationController = NavigationController();
  FireBaseCollectionManager firebaseCollectionManager =
      FireBaseCollectionManager();
  late CollectionReference collectionReference;

  @override
  void initState() {
    collectionReference = firebaseCollectionManager.getUserCollection();
    FirebaseAuth.instance.userChanges().listen((event) async {
      collectionReference = firebaseCollectionManager.getUserCollection();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? appBody()
        : loginScreen();
  }

  appBody() {
    return WillPopScope(
      onWillPop: () => _popScope(),
      child: DocumentReferenceProvider(
          key: UniqueKey(),
          collectionReference: collectionReference,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: ListViewer(
                    firebasePath: collectionReference,
                    talkback: (map) {
                      talkbackHandler(map);
                    },
                  )),
                  bottomBar(),
                ],
              ),
            ),
          )),
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
    return InkWell(
      onTap: () {
        print(collectionReference.path);

        /*firebaseCollectionManager.createCollection(
            collectionReference: collectionReference, newFolderName: 'folder');*/
      },
      child: Container(
        child: bottomBarIcons(Icons.add),
      ),
    );
  }

  goToPresentation() {
    return Container(
      child: bottomBarIcons(Icons.playlist_play_rounded),
    );
  }

  profile() {
    return InkWell(
      onTap: () {
        FirebaseAuth.instance.signOut();
      },
      child: Container(
        child: bottomBarIcons(Icons.account_box_rounded),
      ),
    );
  }

  bottomBarIcons(IconData icon) {
    return Icon(
      icon,
      size: 35,
      color: Colors.white.withOpacity(0.9),
    );
  }

  loginScreen() {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
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
    );
  }

  void talkbackHandler(Map map) {
    if (map.containsKey('folder')) {
      DocumentReference doc = map['folder'];
      collectionReference =
          navigationController.goToFolder(documentReference: doc);
      setState(() {});
    }
  }

  Future<bool> _popScope() async {
    /// Ex de pasta raiz: users/cdwnImtdHuOHfgKbNfTwkZPxTo52/collections
    bool isInRootFolder = '/'.allMatches(collectionReference.path).length == 2;
    bool isInUserCollections = collectionReference.path
        .contains(FirebaseAuth.instance.currentUser!.uid);

    if (!isInRootFolder) {
      collectionReference = navigationController.backOneLevel(
          collectionReference: collectionReference);
      setState(() {});
    }

    return false;
  }
}

class DocumentReferenceProvider extends InheritedWidget {
  final CollectionReference collectionReference;

  const DocumentReferenceProvider({
    required Key key,
    required this.collectionReference,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(DocumentReferenceProvider oldWidget) =>
      collectionReference != oldWidget.collectionReference;

  static DocumentReferenceProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DocumentReferenceProvider>();
  }
}
