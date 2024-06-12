import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_memory_card/list_item_mc.dart';
import 'package:flutter_memory_card/mc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MC? mc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickMCFile,
            child: const Text(
              'Select file',
            ),
          ),
          Expanded(
            child: mc == null
                ? const SizedBox.shrink()
                : ListView.builder(
                    itemCount: mc!.slots.length,
                    itemBuilder: (_, index) => ListItemMCSlot(
                      slot: mc!.slots[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _pickMCFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.first;
      final contents = await file.xFile.readAsBytes();
      mc = MC.fromBytes(contents);
      setState(() {});
    }
  }
}
