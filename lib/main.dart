import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  BlocProvider(
        create: (_) => PersonsBloc(),
        child: MyHomePage(title: 'Bloc Home Page'),
      ),
    );
  }
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final PersonUrl url;
  const LoadPersonAction({required this.url}) : super();
}

enum PersonUrl { person1, person2 }

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        // TODO: Handle this case.
        return "http://127.0.0.1:5500/testingbloc_course/api/persons1.json";

      case PersonUrl.person2:
        return "http://127.0.0.1:5500/testingbloc_course/api/persons2.json";
    }
  }
}

// person class
@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        age = json["age"] as int;
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

// State
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetrievedFromCache});

  @override
  String toString() {
    // TODO: implement toString
    return "FetchResult (isRetrievedFrom Cache = $isRetrievedFromCache, person = $persons)";
  }
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      // todo
      final url = event.url;
      if (_cache.containsKey(url)) {
        // we have the value in the cache
        final cachedPersons = _cache[url]!;
        final result = FetchResult(
          persons: cachedPersons,
          isRetrievedFromCache: true,
        );

        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result =
            FetchResult(persons: persons, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index):null;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
          onPressed: (){
            context.read<PersonsBloc>()
               .add(LoadPersonAction(url: PersonUrl.person1));
          },
           child: Text("Loaed json #1"),
           ),

          TextButton(
          onPressed: (){
            context.read<PersonsBloc>()
               .add(LoadPersonAction(url: PersonUrl.person2));
          },
           child: Text("Loaed json #2"),
           ),
            ],
           ),

           BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult){
              return previousResult?.persons != currentResult?.persons;
            },
            builder: (context, fetchResult){
              final persons = fetchResult?.persons;
              if (persons == null){
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      title:  Text(person!.name),
                    );

                    
                  }
                  ),
              );
            }
            
            )

        ],
      ),
    );
  }
}
