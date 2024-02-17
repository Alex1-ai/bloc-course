import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cubit Course',
      theme: ThemeData(
      
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

const names = [
  'Foo',
  'Bar',
  'Baz'
];

// creating a custom iteration  and getting random 
extension RandomElement<T> on Iterable<T>{
  T getRandomElement() =>
    elementAt( math.Random().nextInt(length));

}

class NamesCubit extends Cubit<String?>{

  NamesCubit(): super(null);

  void pickleRandomName() => emit(
    names.getRandomElement()

  );

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final NamesCubit nameCubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameCubit = NamesCubit();
  }
  // int _counter = 0;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameCubit.close();
  }
  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
      
        title: Text(widget.title),
      ),
      body: Center(
       
        child: StreamBuilder<String?>(
          stream: nameCubit.stream,
          builder: (context, snapshot){
            final button = TextButton(
              onPressed: (){
                nameCubit.pickleRandomName();
              }, 
              
              child: Text("Pick a random name")
              
              ); 
              switch (snapshot.connectionState){
                
                case ConnectionState.none:
                  // TODO: Handle this case.
                  return button;
                case ConnectionState.waiting:
                  // TODO: Handle this case.
                  return button;

                case ConnectionState.active:
                  // TODO: Handle this case.
                    return Column(
                      children: [
                        Text(snapshot.data?? ""),
                        button
                      ],
                    );
                    
                case ConnectionState.done:
                    return const SizedBox();
              }

          },
          )
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
