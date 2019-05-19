
int layer = 3; // Can only be 1, 2 or 3

class TileTable {
  int pos;
  boolean active = false;
  int selectedTile;
  PImage guiBase;
  PImage guiButtons;
  color base = color(100, 180);
  color buttons = color(0,0);
  int buttonPos[][] = new int[TILESAMOUNT][2];
  
  TileTable() {
    guiBase = createImage(14 + (TILESIZE_X/2) * 7, width, ARGB);
    guiButtons = createImage(14 + (TILESIZE_X/2) * 7, width, ARGB);
    pos = width - guiBase.width;
    guiBase.loadPixels();
    guiButtons.loadPixels();
    for (int i = 0; i < guiBase.pixels.length; i++) {
      guiBase.pixels[i] = base; 
      guiButtons.pixels[i] = buttons;
    }
    int count = 0;
    for (int j = 0; j < ceil(TILESAMOUNT/7); j++) {
      for (int i = 0; i < 7; i++) {
        guiButtons.copy(t[count / TILESPERROW][count % TILESPERROW],0, 0, TILESIZE_X, TILESIZE_Y, 4+i*(TILESIZE_X/2+1), 10 +j*(TILESIZE_Y/2+1), TILESIZE_X/2, TILESIZE_Y/2);
        buttonPos[count][0] = pos+4+i*(TILESIZE_X/2+1)+TILESIZE_X/4;
        buttonPos[count][1] = 10+j*(TILESIZE_Y/2+1)+TILESIZE_Y/4;
        count++;
      }
    }
  }
      
  void display() { 
    if(active) {
    image(guiBase, pos, 0);
    image(guiButtons, pos, 0);
    }
  }
    
  int check(int x1, int y1) {
    for (int i = 0; i < buttonPos.length; i++) {
      if (abs(buttonPos[i][0]-x1) < TILESIZE_X/4 && abs(buttonPos[i][1]-y1) < TILESIZE_Y/4)
        return i;
    }
    return -1;
  }
}