import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_bridge/gen/common/primitive_messages.pb.dart';
import 'package:go_bridge/gen/common/response.pb.dart';
import 'package:go_bridge/helpers.dart';
import 'package:gof/button.dart';
import 'package:gof/game_painter.dart';
import 'package:gof/keymap.dart';
import 'package:gof/proto/core/proto/gameboy.pb.dart';
import 'package:gof/src/lib_go.dart';
import 'dart:ffi' as ffi;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    dylib = libgo(getDynamicLibrary('libgo.so'));
    dylib!.initialize(ffi.NativeApi.initializeApiDLData);
  }
  libgo? dylib;
  String sta = "Press '+' to load game(.gb or .gba or zip)";
  List<int> img = [];
  bool loadGame = false;
  int gameOriginalWidth = 0;
  int gameOriginalHeight = 0;
  double scale = 1;
  double maxScale = 0;
  List<DropdownMenuItem> scaleDropdownItems = [];

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
      getGoStream(
              request: StringMessage(value: fpath),
              goFunc: dylib!.loadGame,
              responseToFill: EventToC())
          .listen((event) {
        setState(() {
          switch (event.type) {
            case 1:
              if (gameOriginalHeight == 0 || gameOriginalWidth == 0) {
                break;
              }
              img = event.value;
              break;
            case 2:
              sta = String.fromCharCodes(event.value);
              break;
            case 4:
              switch (String.fromCharCodes(event.value)) {
                case "gb":
                  gameOriginalWidth = 160;
                  gameOriginalHeight = 144;
                  break;
                case "gba":
                  gameOriginalWidth = 240;
                  gameOriginalHeight = 160;
                  break;
                default:
                  sta = "Unknow game type ${String.fromCharCodes(event.value)}";
              }
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              if (screenWidth > screenHeight) {
                maxScale = screenHeight / gameOriginalHeight;
              } else {
                maxScale = screenWidth / gameOriginalWidth;
              }
              debugPrint(
                  "maxscale $maxScale width:$screenWidth height:$screenHeight");
              for (double i = 1; i < maxScale; i = i + 0.5) {
                scaleDropdownItems.add(DropdownMenuItem(
                  value: i,
                  child: Text("Scale:$i"),
                ));
              }
              break;
          }
        });
      });
      setState(() {
        loadGame = true;
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(sta),
                Center(
                    child: CustomPaint(
                        isComplex: true,
                        size: Size((scale * gameOriginalWidth),
                            (scale * gameOriginalHeight)),
                        willChange: true,
                        painter: LCDPainter(img, scale, gameOriginalWidth,
                            gameOriginalHeight))),
                loadGame
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            // Buttons (DPAD + AB)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                // DPAD
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                        child: Button(
                                            color: Colors.blueAccent,
                                            onPressed: () {
                                              handleVirtualKeyBoardEvent(
                                                  KeyBoardMap.press,
                                                  KeyBoardMap.up);
                                            },
                                            onReleased: () {
                                              handleVirtualKeyBoardEvent(
                                                  KeyBoardMap.release,
                                                  KeyBoardMap.up);
                                            },
                                            label: "Up")),
                                    Row(children: <Widget>[
                                      Button(
                                          color: Colors.blueAccent,
                                          onPressed: () {
                                            handleVirtualKeyBoardEvent(
                                                KeyBoardMap.press,
                                                KeyBoardMap.left);
                                          },
                                          onReleased: () {
                                            handleVirtualKeyBoardEvent(
                                                KeyBoardMap.release,
                                                KeyBoardMap.left);
                                          },
                                          label: "Left"),
                                      const SizedBox(width: 50, height: 50),
                                      Button(
                                          color: Colors.blueAccent,
                                          onPressed: () {
                                            handleVirtualKeyBoardEvent(
                                                KeyBoardMap.press,
                                                KeyBoardMap.right);
                                          },
                                          onReleased: () {
                                            handleVirtualKeyBoardEvent(
                                                KeyBoardMap.release,
                                                KeyBoardMap.right);
                                          },
                                          label: "Right")
                                    ]),
                                    Button(
                                        color: Colors.blueAccent,
                                        onPressed: () {
                                          handleVirtualKeyBoardEvent(
                                              KeyBoardMap.press,
                                              KeyBoardMap.down);
                                        },
                                        onReleased: () {
                                          handleVirtualKeyBoardEvent(
                                              KeyBoardMap.release,
                                              KeyBoardMap.down);
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
                                              KeyBoardMap.press, KeyBoardMap.a);
                                        },
                                        onReleased: () {
                                          handleVirtualKeyBoardEvent(
                                              KeyBoardMap.release,
                                              KeyBoardMap.a);
                                        },
                                        label: "A"),
                                    const SizedBox(height: 10),
                                    Button(
                                        color: Colors.green,
                                        onPressed: () {
                                          handleVirtualKeyBoardEvent(
                                              KeyBoardMap.press, KeyBoardMap.b);
                                        },
                                        onReleased: () {
                                          handleVirtualKeyBoardEvent(
                                              KeyBoardMap.release,
                                              KeyBoardMap.b);
                                        },
                                        label: "B"),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Button(
                                    color: Colors.orange,
                                    onPressed: () {
                                      handleVirtualKeyBoardEvent(
                                          KeyBoardMap.press, KeyBoardMap.start);
                                    },
                                    onReleased: () {
                                      handleVirtualKeyBoardEvent(
                                          KeyBoardMap.release,
                                          KeyBoardMap.start);
                                    },
                                    labelColor: Colors.black,
                                    height: 80,
                                    label: "Start"),
                                const SizedBox(width: 10),
                                Button(
                                    color: Colors.yellowAccent,
                                    onPressed: () {
                                      handleVirtualKeyBoardEvent(
                                          KeyBoardMap.press,
                                          KeyBoardMap.select);
                                    },
                                    onReleased: () {
                                      handleVirtualKeyBoardEvent(
                                          KeyBoardMap.release,
                                          KeyBoardMap.select);
                                    },
                                    height: 80,
                                    labelColor: Colors.black,
                                    label: "Select"),
                                const SizedBox(width: 10),
                                Button(
                                    onPressed: () {
                                      handleVirtualKeyBoardEvent(
                                          KeyBoardMap.press, KeyBoardMap.pause);
                                    },
                                    height: 80,
                                    color: Colors.black,
                                    label: 'Pause'),
                                const SizedBox(width: 10),
                                Button(
                                    onPressed: () async {
                                      await _loadRom();
                                    },
                                    height: 80,
                                    color: Colors.black,
                                    label: "Load"),
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            scaleDropdownItems.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.greenAccent, //<-- SEE HERE
                                    ),
                                    child: DropdownButton(
                                        underline: const SizedBox(),
                                        value: scale,
                                        items: scaleDropdownItems,
                                        onChanged: (v) =>
                                            {setState(() => scale = v)}))
                                : const SizedBox()
                            // Button (Start + Pause + Load)
                          ])
                    : const SizedBox()
              ])),

      floatingActionButton: FloatingActionButton(
        onPressed: _loadRom,
        tooltip: 'Select GameBoy file',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
