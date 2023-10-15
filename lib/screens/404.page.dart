import 'package:flutter/material.dart';

class Page404 extends StatefulWidget{
  const Page404({super.key});

  @override
  State<Page404> createState() => StatePage404();
}

class StatePage404 extends State<Page404>{

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body:  Center(child: Text("Esta pagina no se encuentra")),
    );
  }
}