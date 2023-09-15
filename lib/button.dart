import 'package:flutter/material.dart';

/// Button widget with up and down callbacks.
class Button extends StatefulWidget {
  /// Callback method executed when the button is pressed.
  Function onPressed;

  /// Callback method executed on the button is released.
  Function? onReleased;

  /// Color of the button
  Color color;

  /// Color of the label
  Color labelColor;

  /// Label
  String label;

  double width;
  double height;

  Button(
      {required this.label,
      required this.color,
      required this.onPressed,
      this.width = 50,
      this.height = 50,
      this.onReleased,
      this.labelColor = Colors.white,
      Key? key})
      : super(key: key);

  @override
  ButtonState createState() {
    return ButtonState();
  }
}

class ButtonState extends State<Button> {
  /// Indicates if the user is tapping the button.
  bool pressed = false;

  ButtonState();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 0.0),
        child: InkWell(
            enableFeedback: true,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onHighlightChanged: (bool highlight) {
              if (!pressed && highlight) {
                widget.onPressed();
              }

              if (pressed && !highlight && widget.onReleased != null) {
                widget.onReleased!();
              }

              pressed = highlight;
              setState(() {});
            },
            onTap: () {},
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                  height: widget.width,
                  width: widget.height,
                  decoration: BoxDecoration(
                      color: pressed ? Colors.grey : widget.color,
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Center(
                      child: Text(
                    widget.label,
                    style: TextStyle(color: widget.labelColor),
                  )))
            ])));
  }
}
