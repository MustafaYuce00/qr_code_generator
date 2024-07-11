import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

class QrScreen extends StatefulWidget {
  QrScreen({super.key, required this.text});
  String text;

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  TextEditingController hexInputControllerBackground = TextEditingController();
  TextEditingController hexInputControllerQR = TextEditingController();
  List<XFile> pickedImages = [];

  Color pickerColorBackground = Color(0xff443a49);
  Color currentColorBackground = Color(0xffffffff);
  Color pickerColorQR = Color(0xff443a49);
  Color currentColorQR = Color(0xff000000);

  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('QR Code Generator'),
          ),
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.42,
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: PrettyQrView.data(
                          data: widget.text,
                          errorCorrectLevel: 3,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Uh oh! Something went wrong...',
                                style: TextStyle(fontSize: 25),
                              ),
                            );
                          },
                          // ignore: non_const_call_to_literal_constructor
                          decoration: PrettyQrDecoration(
                            background: currentColorBackground,
                            // ignore: non_const_call_to_literal_constructor
                            shape: PrettyQrSmoothSymbol(
                              color: currentColorQR,
                            ),
                            // ignore: non_const_call_to_literal_constructor
                            image: PrettyQrDecorationImage(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.8),
                                BlendMode.dstATop,
                              ),
                              repeat: ImageRepeat.noRepeat,
                              filterQuality: FilterQuality.high,
                              image: pickedImages.isNotEmpty
                                  ? Image.file(
                                      File(pickedImages[0].path),
                                    ).image
                                  : Image.asset(
                                      "",
                                    ).image,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // arkaplan rengi, qr rengi, qr resmi seçme
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "* The background color should be lighter than the qr color.",
                              style: TextStyle(color: Colors.red)),
                          TextButton(
                            onPressed: () {
                              backgrundMethod();
                            },
                            child: const Text('Change Background Color'),
                          ),
                          TextButton(
                            onPressed: () {
                              qrMethod();
                            },
                            child: const Text('Change QR Color'),
                          ),
                          TextButton(
                            onPressed: () {
                              iconPick(context);
                            },
                            child: const Text('Add QR Icon (Max 512x512 px)'),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          _captureAndSharePng();
                        },
                        child: const Text('Share QR Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // Methos
  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is my QR code' + widget.text,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void changeBackgroundColor(Color color) {
    setState(() => pickerColorBackground = color);
  }

  void changeQRColor(Color color) {
    setState(() => pickerColorQR = color);
  }

  backgrundMethod() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renk Seç '),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              hexInputController: hexInputControllerBackground,
              paletteType: PaletteType.hueWheel, // PaletteType.hsv,
              pickerColor: pickerColorBackground,
              onColorChanged: changeBackgroundColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Tamam'),
              onPressed: () async {
                setState(() {
                  currentColorBackground = pickerColorBackground;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((value) => setState(() {}));
  }

  qrMethod() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renk Seç '),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              hexInputController: hexInputControllerQR,
              paletteType: PaletteType.hueWheel, // PaletteType.hsv,
              pickerColor: pickerColorQR,
              onColorChanged: changeQRColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Tamam'),
              onPressed: () async {
                setState(() {
                  currentColorQR = pickerColorQR;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((value) => setState(() {}));
  }

  //! Kameradan Resim Seçme
  Future<void> resimSecCamera() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    pickedImages.clear();

    pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      pickedImages.add(pickedFile);
    }
  }

  //! Galeriden Resim Seçme
  Future<void> resimSecGaleri() async {
    final picker = ImagePicker();
    pickedImages.clear();
    List<XFile>? pickedFiles = await picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 1200,
    );
    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }
  }

  //! Tüm resimleri seçme Ekranı
  Future<dynamic> iconPick(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 10,
          ),
          Center(
              child: Container(
            width: 80,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          )),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Ürün Resmi Seç",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'OpenSans',
                        fontSize: 16),
                  )),
              Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Container(
                width: 70,
                height: 70,
                child: Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                        child: IconButton(
                          onPressed: () async {
                            await resimSecCamera();
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.blue[400],
                            size: 30,
                          ),
                        ),
                      ),
                      Text("Kamera")
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: 70,
                height: 70,
                child: Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                        child: IconButton(
                          onPressed: () async {
                            await resimSecGaleri();
                          },
                          icon: Icon(
                            Icons.photo_library,
                            color: Colors.blue[400],
                            size: 30,
                          ),
                        ),
                      ),
                      Text("Galeri")
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ]);
      },
    );
  }
}
