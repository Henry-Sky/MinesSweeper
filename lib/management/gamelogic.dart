import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'mineboard.dart';


// Debug Tool
const kDebugMode = false;
final logger = Logger();

// Board Size
const cellwidth = 40.0;
const cellroundwidth = 2.0;
const boardrows = 15;
const boardcols = 8;
const borderwidth = 5.0;

class GameLogic extends StateNotifier<GameStates>{
  GameLogic(this.ref) : super(GameStates());

  final StateNotifierProviderRef ref;
  final int minenums = (boardrows * boardcols * 0.15).floor();

  void initGame(){
    state.gameover = false;
    state.goodgame = false;
    state.board = MineBoard(rows: boardrows, cols: boardcols);
    state.board.randomMine(num: minenums);
    print("Game init finished");
  }

  void checkCell({required row, required col}){
    var dx = [1,0,-1,0];
    var dy = [0,1,0,-1];
    for(int i = 0; i < 4; i++){
      var nextrow = row + dy[i];
      nextrow = nextrow < 0 ? 0 : nextrow;
      nextrow = nextrow >= boardrows ? boardrows - 1 : nextrow;
      var nextcol = col + dx[i];
      nextcol = nextcol < 0 ? 0 : nextcol;
      nextcol = nextcol >= boardcols ? boardcols - 1 : nextcol;
      // get the next pose cell state
      var _cell = getCell(row: nextrow, col: nextcol);
      // check the next cell
      if(_cell["state"] == cellstate.covered && _cell["around"] == 0){
        changeCell(row: nextrow, col: nextcol, state: cellstate.blank);
        checkCell(row: nextrow, col: nextcol);
      }else if(!_cell["mine"] && _cell["state"] == cellstate.covered && _cell["around"] != 0){
        changeCell(row: nextrow, col: nextcol, state: cellstate.blank);
      }
    }
  }

  bool checkBlank({required row, required col}){
    int checkwidth = 1;
    int beginrow = row - checkwidth < 0 ? 0 : row - checkwidth;
    int endrow = row + checkwidth >= boardrows ? boardrows - 1 : row + checkwidth;
    int begincol = col - checkwidth < 0 ? 0 : col - checkwidth;
    int endcol = col + checkwidth >= boardcols ? boardcols - 1 : col + checkwidth;
    for(int r = beginrow; r <= endrow; r++){
      for(int c = begincol; c <= endcol; c++){
        if(getCell(row: r, col: c)["state"] == cellstate.blank){
          return true;
        }
      }
    }
    return false;
  }

  bool checkWin(){
    var coveredcells = state.board.countState(state: cellstate.covered);
    var flagedcells = state.board.countState(state: cellstate.flag);
    var minecells = state.board.countMines();
    if (kDebugMode) {
      logger.log(Level.debug, "mines: $minecells, covers: $coveredcells, flags: $flagedcells");
    }
    if(coveredcells + flagedcells == minecells){
      return true;
    }
    return false;
  }

  Map getCell({required row, required col}){
    return state.board.getCell(row: row, col: col);
  }

  void changeCell({required row, required col, required state}){
    this.state.board.changeCell(row: row, col: col, state: state);
  }
}

class GameStates{
  late bool gameover;
  late bool goodgame;
  late MineBoard board;
}

final boardManager = StateNotifierProvider<GameLogic, GameStates>((ref) {
  return GameLogic(ref);
});
