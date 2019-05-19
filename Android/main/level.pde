
class Level {
  String file;    // Import specific level
  float pos = 0;
  int wide;
  int high = 10;
  int[][][] data; // Noted as rows by columns
  int SOLID = 1;
  int FLOOR = 2;
  PImage image;
  Level(String fileName) {
    file = fileName;
    String[] loaded = loadStrings(file);
    String[] loaded1 = loadStrings("collision.txt");
    int[] solidsID = int(split(loaded1[0], ','));
    int[] floorsID = int(split(loaded1[1], ','));
    int row = loaded.length;
    int col = int(splitTokens(loaded[0], ", ")).length;
    data = new int[4][row][col];
    for (int r = 0; r < row; r++) {
      String[] temp;
      temp =  splitTokens(loaded[r], ", ");
      for (int i = 0; i < temp.length; i++) {
        int[] temp1;
        temp1 =  int(split(temp[i], "/"));
        data[LAYER_1][r][i] = temp1[0];
        data[LAYER_2][r][i] = temp1[1];
        data[LAYER_3][r][i] = temp1[2];
      }
      for (int n = 0; n < data[LAYER_1][r].length; n++) {
        for (int i = 0; i < solidsID.length; i++) {
          for (int u = 0; u < 3; u++) {
            if (data[u+1][r][n] == solidsID[i]) data[COLLISION][r][n] = SOLID;
          }
        } 
        for (int i = 0; i < floorsID.length; i++) {
          for (int u = 0; u < 3; u++) {
            if (data[u+1][r][n] == floorsID[i]) data[COLLISION][r][n] = FLOOR;
          }
        }
      }
    }
    wide = col;
    high = row;
    update();
  }
  Level() { 
    high = 10;          // DEFAULT VALUES. Change later.
    wide = 40;
    data = new int[4][high][wide];  
    update();
  }
   
  void update() {
    image = createImage(wide*TILESIZE_X, high*TILESIZE_Y, ARGB);
    for (int j = 0; j < high; j++) {
      for (int i = 0; i < wide; i++) {
        for (int u = 0; u < layer; u++) {
          PImage temp = t[data[u+1][j][i]/TILESPERROW][data[u+1][j][i]%TILESPERROW];
          if (u == 0) image.copy(temp, 0, 0, temp.width, temp.height, i*TILESIZE_X, j*TILESIZE_Y, temp.width, temp.height);
          else stack(temp, image, 0, 0, temp.width, temp.height, i*TILESIZE_X, j*TILESIZE_Y, temp.width, temp.height);
        }
      }
    }
  }
  
  void update(int xTile, int yTile) {
    for (int u = 0; u < layer; u++){
      PImage temp = t[data[u+1][yTile][xTile]/TILESPERROW][data[u+1][yTile][xTile]%TILESPERROW];
      if (u == 0) image.copy(temp, 0, 0, temp.width, temp.height, xTile*TILESIZE_X, yTile*TILESIZE_Y, temp.width, temp.height);
      else stack(temp, image, 0, 0, temp.width, temp.height, xTile*TILESIZE_X, yTile*TILESIZE_Y, temp.width, temp.height);
    }
  }
    
    
  void display() {
    image(image, 0, 0, width, height, floor(pos), 0, floor(pos) + width, height); 
  }
      
  void export() {
    PrintWriter output = createWriter("data/newLevel.txt");
    String temp3;
    int row = localData[1].length;
    for (int r = 0; r < row; r++) {
      String strData = new String();
      for (int i = 0; i < localData[LAYER_1][r].length; i++) {
        temp3 = localData[LAYER_1][r][i] + "/" + localData[LAYER_2][r][i] + "/" + localData[LAYER_3][r][i] + ", ";
        strData = strData + temp3;
      }
      output.println(strData);
    }
    output.flush();
    output.close();
    
  }
}
  
         
    
  

    
    