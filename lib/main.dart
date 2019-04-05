import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

var playerOut = true;

var dim = Offset(300.0, 500.0);

List<Offset> balls = new List();
List<double> radius = new List();
List<double> velocity = new List();
var score = 0;
var ballOs;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  var toOs;
  var lastOs;

  var con;
  var anim;
  Tween<Offset> tween;

  double random(double min, double max) {
    return min +
        (Random().nextInt(max.toInt() - min.toInt()) + Random().nextDouble());
  }

  start() {
    balls.clear();
    radius.clear();
    velocity.clear();
    ballOs = Offset(200.0, 500.0);
    lastOs = Offset(200.0, 500.0);
    toOs = Offset(200.0, 500.0);
    score = 0;
    for (var i = 0; i <= 20; i++) {
      balls.add(Offset(random(0, dim.dx).toDouble(), -random(0, 5000)));
      radius.add(random(5, 40));
      velocity.add(random(0.5, 4));
    }
  }

  void onTapDown(BuildContext c, TapDownDetails pos) {
    setState(() {
      if (con.isAnimating) {
        con.stop(canceled: true);
        lastOs = anim.value;
      } else
        lastOs = toOs;

      toOs = pos.globalPosition;
      tween = Tween<Offset>(begin: Offset(0.0, 0.0), end: ballOs);
      con.reset();
      tween.begin = lastOs;
      tween.end = toOs;

      anim = tween.animate(con)
        ..addListener(() {
          setState(() {
            ballOs = anim.value;
          });
        });

      con.forward();
    });
  }

  @override
  void initState() {
    super.initState();
    start();
    con = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    var ballR;

    Timer.periodic(Duration(milliseconds: 10), (_) {
      setState(() {
        if (!playerOut) {
          for (var i = 0; i <= 20; i++) {
            if (i <= 6)
              ballR = 22;
            else
              ballR = radius[i];

            if (balls[i].dy - radius[i] > dim.dy) {
              if (i <= 6) score -= 10;

              balls[i] = Offset(
                  random(0, dim.dx), -random(0, 5000 - score.toDouble()));
            }

            if (sqrt(((balls[i].dx - ballOs.dx) * (balls[i].dx - ballOs.dx)) +
                    ((balls[i].dy - ballOs.dy) * (balls[i].dy - ballOs.dy))) <
                ballR + 13.0) {
              if (i <= 6) {
                balls[i] = Offset(random(0, dim.dx), -random(0, 4000));
                score += 10;
              } else {
                playerOut = true;
              }
            } else {
              balls[i] = Offset(balls[i].dx, (balls[i].dy + velocity[i]));
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: GestureDetector(
          onTapDown: (TapDownDetails pos) => onTapDown(c, pos),
          child: CustomPaint(
            painter: BackPaint(),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 100,
                height: 50,
                padding: EdgeInsets.only(right: 15.0, bottom: 15.0),
                child: playerOut
                    ? RaisedButton(
                        color: Colors.black,
                        textColor: Colors.white,
                        child: Text("start"),
                        onPressed: () {
                          setState(() {
                            playerOut = false;
                            start();
                          });
                        },
                      )
                    : Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    dim = Offset(size.width, size.height);
    Paint paint = Paint();
    paint.color = Colors.black;
    canvas.drawCircle(ballOs, 13.0, paint);
    TextPainter sr = TextPainter(
        text: TextSpan(
            style: TextStyle(color: Colors.black), text: "score: $score"),
        textDirection: TextDirection.ltr);
    sr.layout();
    sr.paint(canvas, Offset(20.0, size.height - 30.0));
    for (var i = 0; i <= 20; i++) {
      if (i <= 6) {
        paint.color = Colors.pinkAccent;
        canvas.drawCircle(balls[i], 22.0, paint);
      } else {
        paint.color = Colors.black54;
        canvas.drawCircle(balls[i], radius[i], paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackPaint old) {
    if (playerOut)
      return false;
    else
      return true;
  }
}
