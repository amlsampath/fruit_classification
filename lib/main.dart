import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions = [];

  loadModel()async{

    await Tflite.loadModel(
    model: 'assets/model_unquant.tflite',
    labels:"assets/labels.txt" );

  }

  Future<void>  _pickImage()async{

      try{

        final XFile? image=  await _picker.pickImage(source: ImageSource.gallery);

        setState(() {
          _image = image;
          file = File(_image!.path);
        });

        detectImage(file!);

      }catch(e){

        print(e);
      }


    }

    Future detectImage(File file) async{

        var recognitions = await Tflite.runModelOnImage(
          path: file.path,
          numResults: 6,
          threshold: 0.05,
          imageMean: 127.5,
          imageStd: 127.5,
        );

        print(recognitions.toString());

        setState(() {
          _recognitions = recognitions!;
        });

    }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

           file == null ?const Text("No selected image"): Image.file(file!),
            
            _recognitions.isEmpty?Container():Text("Name   :- "+ _recognitions[0]['label'],style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold,),),
   _recognitions.isEmpty?Container():Text("Confidence   :- "+ _recognitions[0]['confidence'].toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,),),
Divider(height: 25,),
            ElevatedButton(
          onPressed: (){

            _pickImage();
          },
          child: const Text('Pick Image From Gallery'),
        ),
          ],
        )
      ),
    
    );
  }
}
