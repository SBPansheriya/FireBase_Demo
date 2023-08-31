// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/Item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Firebase_Demo(),
  ));
}

class Firebase_Demo extends StatefulWidget {
  const Firebase_Demo({super.key});

  @override
  State<Firebase_Demo> createState() => _Firebase_DemoState();
}

class _Firebase_DemoState extends State<Firebase_Demo> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  List<Item> items = <Item>[];
  final CollectionReference _products = FirebaseFirestore.instance.collection("Contact");
  ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  late FirebaseStorage firebaseStorage;
  UploadTask? uploadTask;

  void takephoto(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
    print(_selectedImage);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FireBase Demo"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          namecontroller.text;
          numbercontroller.text;
          insertdialog(context);
        },
      ),
      body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        updatedialog(documentSnapshot);
                      },
                      title: Text(
                        documentSnapshot['name'],
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(documentSnapshot['number'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
                itemCount: streamSnapshot.data!.docs.length,
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Future insertdialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Insert Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    foregroundImage: upload(),
                  ),
                  Positioned(
                      bottom: 10,
                      right: 10,
                      child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Choose Profile Photo",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                            onPressed: () {
                                              takephoto(ImageSource.camera);
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.camera),
                                            label: const Text("Camera")),
                                        ElevatedButton.icon(
                                            onPressed: () {
                                              takephoto(ImageSource.gallery);
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.image),
                                            label: const Text("Gallery")),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.camera_alt,
                              color: Colors.cyan, size: 25))),
                ],
              ),
              TextField(
                keyboardType: TextInputType.text,
                controller: namecontroller,
                decoration: const InputDecoration(hintText: "Enter Name"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: numbercontroller,
                decoration: const InputDecoration(hintText: "Enter Number"),
                onTap: () {},
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  addData(namecontroller.text, numbercontroller.text);
                  Navigator.pop(context);
                },
                child: const Text("ADD"))
          ],
        ),
      );

  late final DocumentSnapshot documentSnapshot;

  Future updatedialog(DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot != null) {
      namecontroller.text = documentSnapshot['name'];
      numbercontroller.text = documentSnapshot['number'];
    }
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.text,
              controller: namecontroller,
              decoration: const InputDecoration(hintText: "Enter Name"),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: numbercontroller,
              decoration: const InputDecoration(hintText: "Enter Number"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () async {
                String name = namecontroller.text;
                String number = numbercontroller.text;
                await _products
                    .doc(documentSnapshot!.id)
                    .update({"name": name, "number": number});
                Navigator.pop(context);
              },
              child: const Text("UPDATE")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                deletedialog(documentSnapshot.id);
              },
              child: const Text("DELETE")),
        ],
      ),
    );
  }

  Future deletedialog(String id) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Data'),
              content: const Text("Are Sure Delete This Data?"),
              actions: [
                TextButton(
                    onPressed: () async {
                      // deleteData();
                      _products.doc(id).delete();
                      Navigator.pop(context);
                    },
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No"))
              ],
            ));
  }

  void addData(String name, String number) {
    DocumentReference reference =
        FirebaseFirestore.instance.collection("Contact").doc();

    Map<String, dynamic> data = {
      "name": name,
      "number": number,
    };
    reference.set(data);
  }

  upload(){
    _selectedImage == null
        ? const AssetImage("Images/profile.png")
        : Image.file(_selectedImage!);
    print(_selectedImage);
  }

  // uploadtofirestorage() async {
  //   final path = 'Storage/${_selectedImage}';
  //   final file = File(_selectedImage!.path);
  //
  //   final firebaseStorage = FirebaseStorage.instance.ref().child(path);
  //   uploadTask = firebaseStorage.putFile(file);
  //
  //   final Snapshot  = await uploadTask!.whenComplete(() => () {
  //   });
  //
  //   final urlDownload = await Snapshot.ref.getDownloadURL();
  //   print("downloaded url = "+urlDownload);
  //
  // }

  Future<Widget> bottomSheet() async {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          const Text("Choose Profile Photo"),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera")),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery")),
            ],
          )
        ],
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Row(
          children: [
            Column(
              children: <Widget>[
                Text(
                  item.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(item.number),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
