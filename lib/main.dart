import 'dart:io';
import 'package:cellular_automata_image_effects/image_painter.dart';
import 'package:cellular_automata_image_effects/image_picker.dart';
import 'package:cellular_automata_image_effects/image_resizer.dart';
import 'package:cellular_automata_image_effects/pixel_automata_manager.dart';
import 'package:cellular_automata_image_effects/pixel_info.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const CellularAutomataImageEffectsApp());
}

class CellularAutomataImageEffectsApp extends StatelessWidget {
  const CellularAutomataImageEffectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Art',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageEffectDemoPage(),
    );
  }
}

class ImageEffectDemoPage extends StatefulWidget {
  const ImageEffectDemoPage({super.key});

  @override
  State<ImageEffectDemoPage> createState() => _ImageEffectDemoPage();
}

class _ImageEffectDemoPage extends State<ImageEffectDemoPage> {
  final _imagePicker = ImagePicker();
  final _imageResizer = ImageResizer();
  final _pixelAutomataManager = PixelAutomataManager();
  final _textEditingController = TextEditingController();

  late final double _width = MediaQuery.sizeOf(context).width * 0.9;
  double _height = 300;

  File? _selectedImageFile;
  img.Image? _image;
  bool _loading = false;

  void _pickImage() async {
    try {
      _image = null;
      _loading = true;
      setState(() {});
      _selectedImageFile = await _imagePicker.pickImage();
      _image = await _imageResizer.resizeImage(
        imagePath: _selectedImageFile!.path,
        width: _width,
      );

      _height = _image?.height.toDouble() ?? 300;
      _loading = false;
      setState(() {});
      _pixelAutomataManager.applyEffect(
        image: _image!,
        rule: int.tryParse(_textEditingController.text) ?? 153,
      );
    } catch (e) {
      debugPrint("$e");
      _loading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pixelAutomataManager.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixel Automata Demo'),
      ),
      body: Stack(
        children: [
          if (_image != null)
            Positioned(
                top: kToolbarHeight / 3,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Wolfram Rule Number (0-255)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _textEditingController,
                      builder: (context, _, __) {
                        final rule =
                            int.tryParse(_textEditingController.text) ?? 153;
                        return _Chip(
                          selectedValue: rule,
                          value: rule,
                          onTap: (_) {
                            _pixelAutomataManager.applyEffect(
                              image: _image!,
                              rule: rule,
                            );
                          },
                        );
                      },
                    ),
                  ],
                )),
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "📸",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          Text(
                            "Upload an image to get started",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      )
                    : StreamBuilder<List<List<PixelInfo>>>(
                        stream: _pixelAutomataManager.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            return CustomPaint(
                              painter: ImagePainter(
                                pixelInfosCollection: snapshot.data!,
                              ),
                              size: Size(_width, _height),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.value,
    this.selectedValue,
    required this.onTap,
  });

  final int value;
  final int? selectedValue;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(value);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selectedValue == value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.background,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 2),
            Text(
              "Generate Image for Rule $selectedValue",
              style: TextStyle(
                color: selectedValue == value
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            if (selectedValue == value) ...{
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 16,
              )
            },
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
