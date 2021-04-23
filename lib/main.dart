//import 'dart:html';

import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/profile.dart';
import 'package:hello_me/user.dart';
import 'package:hello_me/utils.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => User(),
      child: ChangeNotifierProvider(
        create: (_) => BG(),
        child: MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(
            primaryColor: Colors.red,
            colorScheme: ColorScheme.dark(),
          ),
          home: RandomWords(),
        ),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final snapCtrl = SnappingSheetController();
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
            if (Provider.of<User>(context).status == LoginStatus.OUT)
              IconButton(icon: Icon(Icons.login_rounded), onPressed: _pushLogin)
            else
              IconButton(
                  icon: Icon(Icons.exit_to_app_rounded),
                  onPressed: Provider.of<User>(context, listen: false).logOut)
          ],
        ),
        body: Provider.of<User>(context).status == LoginStatus.OUT
            ? _buildSuggestions()
            : SnappingSheet(
                onSheetMoved: (sheetPos) {
                  sheetPos.pixels < 50
                      ? Provider.of<BG>(context, listen: false).unblur()
                      : Provider.of<BG>(context, listen: false).blur();
                },
                child: Stack(
                  children: Provider.of<BG>(context).isBlurred
                      ? [
                          _buildSuggestions(),
                          BackdropFilter(
                              filter: Provider.of<BG>(context).filter,
                              child: Container(color: Colors.transparent))
                        ]
                      : [_buildSuggestions()],
                ),
                controller: snapCtrl,
                grabbing: GestureDetector(
                  onTap: () {
                    snapCtrl.currentSnappingPosition ==
                            SnappingPosition.factor(positionFactor: 0.25)
                        ? snapCtrl.snapToPosition(SnappingPosition.factor(
                            positionFactor: 0.0,
                            grabbingContentOffset: GrabbingContentOffset.top,
                          ))
                        : snapCtrl.snapToPosition(
                            SnappingPosition.factor(positionFactor: 0.25));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Welcome back, " +
                                  Provider.of<User>(context).name,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          Icon(Icons.arrow_drop_up)
                        ]),
                  ),
                ),
                grabbingHeight: 50,
                snappingPositions: [
                  SnappingPosition.factor(
                    positionFactor: 0.0,
                    grabbingContentOffset: GrabbingContentOffset.top,
                  ),
                  SnappingPosition.factor(positionFactor: 0.25)
                ],
                sheetBelow: SnappingSheetContent(
                    draggable: false,
                    child: buildProfilePage(context, snapCtrl)),
              ));
  }

  void _pushLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(appBar: AppBar(title: Text('Login')), body: LoginForm());
    }));
  }

  void _pushSaved() {
    Navigator.of(context).push(SavedPage());
  }

  MaterialPageRoute<void> SavedPage() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: getFavList(Provider.of<User>(context).favorites));
      },
    );
  }

  Widget getFavList(Set<WordPair> favorites) {
    if (favorites.isEmpty) return Container();
    var tiles = favorites.map(
      (WordPair pair) {
        return ListTile(
            title: Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
            trailing: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            onTap: () {
              setState(() {
                Provider.of<User>(context, listen: false).deleteFav(pair);
              });
            });
      },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return ListView(children: divided);
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) return Divider();

          final int index = i ~/ 2;
          if (index >= _suggestions.length)
            _suggestions.addAll(generateWordPairs().take(10));

          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved =
        Provider.of<User>(context, listen: false).favorites.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved)
            Provider.of<User>(context, listen: false).deleteFav(pair);
          else
            Provider.of<User>(context, listen: false).addFav(pair);
        });
      },
    );
  }
}
