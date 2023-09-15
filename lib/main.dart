import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_bridge/gen/common/primitive_messages.pbserver.dart';
import 'package:go_bridge/gen/common/response.pb.dart';
import 'package:go_bridge/helpers.dart';
import 'package:gof/button.dart';
import 'package:gof/proto/core/proto/gameboy.pbserver.dart';
import 'package:gof/src/lib_go.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';

var path = "";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
    path = Directory.current.path;
  } else if (Platform.isAndroid) {
    path = (await getApplicationDocumentsDirectory()).path;
  }

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
      home: const MyHomePage(title: 'GameBoy Emulator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _KeyBoardMap {
  static int a = 0;
  static int b = 1;
  static int select = 2;
  static int start = 3;
  static int right = 4;
  static int left = 5;
  static int up = 6;
  static int down = 7;
  static int pause = 8;
  static int press = 0;
  static int release = 1;
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    String libName = "libgo.so";
    if (Platform.isMacOS) {
      libName = "libgo.dylib";
    }
    dylib = libgo(ffi.DynamicLibrary.open(libName));
    dylib!.initialize(ffi.NativeApi.initializeApiDLData);
  }
  libgo? dylib;
  String sta = "";
  List<int> img = [];

  final FocusNode _focusNode = FocusNode();

  // Handles the key events from the Focus widget and updates the
  // _message.
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    int key = 0;
    debugPrint("event is  ${event is RawKeyDownEvent ? 'press' : 'release'}  ");
    int mode = event is RawKeyDownEvent ? 0 : 1;
    KeyEventResult handled = KeyEventResult.handled;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        key = 0;
        break;
      case LogicalKeyboardKey.keyB:
        key = 1;
        break;
      case LogicalKeyboardKey.keyD:
        key = 2;
        break;
      case LogicalKeyboardKey.keyS:
        key = 3;
        break;
      case LogicalKeyboardKey.arrowRight:
        key = 4;
        break;
      case LogicalKeyboardKey.arrowLeft:
        key = 5;
        break;
      case LogicalKeyboardKey.arrowUp:
        key = 6;
        break;
      case LogicalKeyboardKey.arrowDown:
        key = 7;
        break;
      case LogicalKeyboardKey.keyP:
        key = 8;
        break;
      default:
        handled = KeyEventResult.ignored;
    }
    callGoFunc(
        request: ButtonEvent(key: key, mode: mode),
        goFunc: dylib!.handleEvent,
        responseToFill: Response());

    return handled;
  }

  handleVirtualKeyBoardEvent(int mode, int key) {
    callGoFunc(
        request: ButtonEvent(key: key, mode: mode),
        goFunc: dylib!.handleEvent,
        responseToFill: Response());
  }

  // Focus nodes need to be disposed.
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRom() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final fpath = result.files.first.path;
      debugPrint("select file $fpath");
      getGoStream(
              request: StringMessage(value: fpath),
              goFunc: dylib!.loadGame,
              responseToFill: EventToC())
          .listen((event) {
        setState(() {
          switch (event.type) {
            case 1:
              img = event.value;
            case 2:
              sta = String.fromCharCodes(event.value);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Focus(
          focusNode: _focusNode,
          onKey: _handleKeyEvent,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(sta),
                Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(
                            width: 800, height: 400),
                        child: Center(
                            // padding: EdgeInsets.all(20),
                            child: CustomPaint(
                                isComplex: true,
                                size: const Size(400, 400),
                                willChange: true,
                                painter: LCDPainter(img, 2, 240, 160))))),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      // Buttons (DPAD + AB)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // DPAD
                          Column(
                            children: <Widget>[
                              GestureDetector(
                                  child: Button(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        handleVirtualKeyBoardEvent(
                                            _KeyBoardMap.press,
                                            _KeyBoardMap.up);
                                      },
                                      onReleased: () {
                                        handleVirtualKeyBoardEvent(
                                            _KeyBoardMap.release,
                                            _KeyBoardMap.up);
                                      },
                                      label: "Up")),
                              Row(children: <Widget>[
                                Button(
                                    color: Colors.blueAccent,
                                    onPressed: () {
                                      handleVirtualKeyBoardEvent(
                                          _KeyBoardMap.press,
                                          _KeyBoardMap.left);
                                    },
                                    onReleased: () {
                                      handleVirtualKeyBoardEvent(
                                          _KeyBoardMap.release,
                                          _KeyBoardMap.left);
                                    },
                                    label: "Left"),
                                const SizedBox(width: 50, height: 50),
                                Button(
                                    color: Colors.blueAccent,
                                    onPressed: () {
                                      handleVirtualKeyBoardEvent(
                                          _KeyBoardMap.press,
                                          _KeyBoardMap.right);
                                    },
                                    onReleased: () {
                                      handleVirtualKeyBoardEvent(
                                          _KeyBoardMap.release,
                                          _KeyBoardMap.right);
                                    },
                                    label: "Right")
                              ]),
                              Button(
                                  color: Colors.blueAccent,
                                  onPressed: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.press, _KeyBoardMap.down);
                                  },
                                  onReleased: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.release,
                                        _KeyBoardMap.down);
                                  },
                                  label: "Down"),
                            ],
                          ),
                          // AB
                          Column(
                            children: <Widget>[
                              Button(
                                  color: Colors.red,
                                  onPressed: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.press, _KeyBoardMap.a);
                                  },
                                  onReleased: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.release, _KeyBoardMap.a);
                                  },
                                  label: "A"),
                              Button(
                                  color: Colors.green,
                                  onPressed: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.press, _KeyBoardMap.b);
                                  },
                                  onReleased: () {
                                    handleVirtualKeyBoardEvent(
                                        _KeyBoardMap.release, _KeyBoardMap.b);
                                  },
                                  label: "B"),
                            ],
                          ),
                        ],
                      ),
                      // Button (SELECT + START)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Button(
                              color: Colors.orange,
                              onPressed: () {
                                handleVirtualKeyBoardEvent(
                                    _KeyBoardMap.press, _KeyBoardMap.start);
                              },
                              onReleased: () {
                                handleVirtualKeyBoardEvent(
                                    _KeyBoardMap.release, _KeyBoardMap.start);
                              },
                              labelColor: Colors.black,
                              label: "Start"),
                          Container(width: 20),
                          Button(
                              color: Colors.yellowAccent,
                              onPressed: () {
                                handleVirtualKeyBoardEvent(
                                    _KeyBoardMap.press, _KeyBoardMap.select);
                              },
                              onReleased: () {
                                handleVirtualKeyBoardEvent(
                                    _KeyBoardMap.release, _KeyBoardMap.select);
                              },
                              labelColor: Colors.black,
                              label: "Select"),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Button(
                                onPressed: () {
                                  handleVirtualKeyBoardEvent(
                                      _KeyBoardMap.press, _KeyBoardMap.pause);
                                },
                                color: Colors.black,
                                label: 'Pause'),
                            Button(
                                onPressed: () async {
                                  await _loadRom();
                                },
                                color: Colors.black,
                                label: "Load"),
                          ]),
                      // Button (Start + Pause + Load)
                      Expanded(
                          child: ListView(
                        // padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[],
                      ))
                    ]))
              ])),

      floatingActionButton: FloatingActionButton(
        onPressed: _loadRom,
        tooltip: 'Select GameBoy file',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// LCD painter is used to copy the LCD data from the gameboy PPU to the screen.
class LCDPainter extends CustomPainter {
  LCDPainter(this.img, this.scale, this.width, this.height);

  /// Indicates if the LCD is drawing new content
  bool drawing = false;
  List<int> img;

  int scale;
  int width;
  int height;

  @override
  void paint(Canvas canvas, Size size) {
    drawing = true;
    if (img.isEmpty) {
      drawing = false;
      return;
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Paint color = Paint();
        color.style = PaintingStyle.stroke;
        color.strokeWidth = 1.0;
        final i = x + y * width;
        if (i * 4 > img.length) {
          return;
        }
        color.color = ColorConverter.toColor1(
            0xFF, img[i * 4], img[i * 4 + 1], img[i * 4 + 2]);

        List<Offset> points = [];
        var xStart = x * scale + 40;
        var yStart = y * scale + 40;
        final xEnd = (x + 1) * scale + 40;
        final yEnd = (y + 1) * scale + 40;
        if (scale > 1) {
          for (int actualY = yStart; actualY < yEnd; actualY++) {
            for (int actualX = xStart; actualX < xEnd; actualX++) {
              points.add(Offset(actualX.toDouble(), (actualY).toDouble()));
            }
          }
        } else {
          points.add(Offset(xStart.toDouble(), yStart.toDouble()));
        }
        canvas.drawPoints(PointMode.points, points, color);
      }
    }

    drawing = false;
  }

  @override
  bool shouldRepaint(LCDPainter oldDelegate) {
    return !drawing;
  }
}

class ColorConverter {
  static int toRGB(Color color) {
    return (color.red & 0xFF) << 16 |
        (color.green & 0xFF) << 8 |
        (color.blue & 0xFF);
  }

  static Color toColor(int r, int g, int b) {
    debugPrint("$r $g $b");
    return Color(0xFF000000 | ((r & 0xFF) << 16 | (g & 0xFF) << 8 | b & 0xFF));
  }

  static Color toColor1(int f, int r, int g, int b) {
    return Color(
        (f & 0xff) << 24 | ((r & 0xFF) << 16 | (g & 0xFF) << 8 | b & 0xFF));
  }
}
