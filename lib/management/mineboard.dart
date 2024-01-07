import '../management/gamelogic.dart';
import "package:flutter/foundation.dart";
import 'package:logger/logger.dart';
import 'dart:math';

enum cellstate{
  covered,
  blank,
  flag,
}

class Cell{
  bool mine = false;
  cellstate state = cellstate.covered;
  int around = 0;
}

class MineBoard{
  int mines = 0;
  final int rows;
  final int cols;
  late List<List<Cell>> board;

  MineBoard({required this.rows, required this.cols}){
    board = List.generate(rows, (row) => List.generate(cols,(col) => Cell()));
    if (kDebugMode) {
      logger.log(Level.info, "MineBoard Init Finished");
    }
  }

  int countState({required state}){
    var cnt = 0;
    for(int r = 0;r < rows;r++){
      for(int c = 0;c < cols;c++){
        if(board[r][c].state == state){
          cnt += 1;
        }
      }
    }
    return cnt;
  }

  int countMines(){
    // Return the default mines (required num) first
    if(mines != 0){
      return mines;
    }
    var cnt = 0;
    for(int r = 0;r < rows;r++){
      for(int c = 0;c < cols;c++){
        if(board[r][c].mine){
          cnt += 1;
        }
      }
    }
    return cnt;
  }

  void randomMine({required num, required clickrow, required clickcol}){
    mines = num;
    var cnt = 0;
    while(cnt < num){
      var value = Random().nextInt(cols * rows);
      var col = value % cols;
      var row = (value / cols).floor();
      if(!board[row][col].mine&&!(row == clickrow && col == clickcol)){
        board[row][col].mine = true;
        countMine(row: row, col: col); // count as mine created
        cnt += 1;
      }
    }
  }

  void countMine({required row, required col}){
    int beginrow = row - 1 < 0 ? 0 : row - 1;
    int endrow = row + 1 >= rows ? rows - 1 : row + 1;
    int begincol = col - 1 < 0 ? 0 : col - 1;
    int endcol = col + 1 >= cols ? cols - 1 : col + 1;
    for(int r = beginrow; r <= endrow; r++){
      for(int c = begincol; c <= endcol; c++){
        board[r][c].around += 1;
      }
    }
  }

  Cell getCell({required row, required col}){
    return board[row][col];
  }

  void changeCell({required row, required col, required state}){
    board[row][col].state = state;
  }

}
