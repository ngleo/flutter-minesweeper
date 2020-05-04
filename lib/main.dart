import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
      ),
      body: GameArea(),
    );
  }
}

class GameArea extends StatefulWidget {
  @override
  _GameAreaState createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  static int rows = 5;
  static int cols = 5;
  List<List<int>> _field =
      new List<List<int>>.generate(rows, (_) => new List(cols));

  final offsets = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ];

  @override
  void initState() {
    Random rand = Random();
    for (int i = 0; i < _field.length; i++) {
      for (int j = 0; j < _field[0].length; j++) {
        int randInt = rand.nextInt(10);
        // -1 represents unrevealed, -2 bomb, -3 revealed bomb
        _field[i][j] = (randInt == 0 || randInt == 1) ? -2 : -1;
      }
    }
  }

  int _countBombsAround(int i, int j) {
    int count = 0;
    for (var offset in offsets) {
      int ni = i + offset[0];
      int nj = j + offset[1];
      if (ni < 0 || ni >= rows || nj < 0 || nj >= cols) continue;

      if (_field[ni][nj] == -2) {
        count++;
      }
    }
    return count;
  }

  void _click(int i, int j) {
    if (_field[i][j] == -1) {
      _reveal(i, j);
    } else if (_field[i][j] == -2) {
      setState(() {
        for (int x = 0; x < _field.length; x++) {
          for (int y = 0; y < _field[0].length; y++) {
            if (_field[x][y] == -2) _field[x][y] = -3;
          }
        }
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          initState();
        });
      });
    }
  }

  ///  If unopened(-1) => count surrounding bombs(-2), show number and open
  ///  neighbouring unopened(-1)
  ///  If bomb(-2) => end game
  void _reveal(int i, int j) {
    if (i < 0 || i >= rows || j < 0 || j >= cols) return;
    int bombCount = _countBombsAround(i, j);

    setState(() {
      if (_field[i][j] == -1) {
        if (bombCount == 0) {
          _field[i][j] = 0;
          for (var offset in offsets) {
            _reveal(i + offset[0], j + offset[1]);
          }
        } else {
          _field[i][j] = bombCount;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _field
            .asMap()
            .map((i, row) => MapEntry(
                  i,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row
                        .asMap()
                        .map((j, elem) => MapEntry(j, _boxContent(i, j)))
                        .values
                        .toList(),
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }

  Widget _boxContent(i, j) {
    Widget content;
    Color boxColor;
    switch (_field[i][j]) {
      case -1:
        boxColor = Colors.amberAccent;
        content = Text("");
        break;
      case -2:
        boxColor = Colors.amberAccent;
        content = Text("");
        break;
      case -3:
        boxColor = Colors.red;
        content = Icon(
          Icons.brightness_high,
          size: 30.0,
        );
        break;
      default:
        boxColor = Colors.amber;
        content = Text(
          _field[i][j].toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        );
        break;
    }

    return InkWell(
      onTap: () => _click(i, j),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          color: boxColor,
        ),
        child: content,
      ),
    );
  }
}
