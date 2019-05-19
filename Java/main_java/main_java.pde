///////////////////////////////////
//             JAVA              //
///////////////////////////////////

//import android.view.MotionEvent;
 
Caracter Player;
Caracter[] Enemies = new Caracter[14];
Level Stage;
TileTable TilePad;

final int MAIN = 0;
final int EDITOR = 1;

final int COLLISION = 0;
final int LAYER_1 = 1;
final int LAYER_2 = 2;
final int LAYER_3 = 3;
final int PLAYER = 0;
final int ENEMY = 1;

int mode = MAIN;

int savedTile;
int TILESAMOUNT = 100;
int TILESIZE_X;
int TILESIZE_Y;
int TILESPERROW = 13;
int[][][] localData;
int pointers = 0;
color COLORKEY = color(0,255,0);

PImage background;
PImage tiles;
PImage player;
PImage enemy;
PImage[][] t; // Tile sprites
PImage[][] p; // Player sprites
PImage[][] e;
PImage aux;
boolean loading = true;

void setup() 
{
  size(600, 300);
  background(0);
  setupLoadingText();
  thread("load");
}

void draw() {
  if (loading) loadingScreen(); 
  else
  switch (mode) {
    case MAIN:
       displayBackground(background, Stage);
       Stage.display();
       manageEntities();
       Player.update();
       if(Player.y > height+formatAndroid(100,'Y')) setup();
       break;
    case EDITOR:
       displayBackground(background, Stage);
       Stage.display(); //<>//
       TilePad.display();
       break;
  }   
  //println("framerate = " + floor(frameRate));
}
/*
public boolean surfaceTouchEvent(MotionEvent me) {
  pointers = me.getPointerCount();
  int action = me.getActionMasked();
  int i = me.getActionIndex();
  switch (action) {
    case MotionEvent.ACTION_DOWN:
    case MotionEvent.ACTION_POINTER_DOWN:
    inputManager(me.getX(i), me.getY(i), true);
    break;
    case MotionEvent.ACTION_UP:
    case MotionEvent.ACTION_POINTER_UP:
    inputManager(me.getX(i), me.getY(i), false);
    break;  
}
  return super.surfaceTouchEvent(me);
}*/

void load() {
  switch (mode) {
   case MAIN:
      aux = loadImage("background.bmp");
      tiles = loadImage("tiles.bmp");
      player = loadImage("player.bmp");
      enemy = loadImage("poring.bmp");
      background = formatAndroid(aux);
      p = loadGrid(player, color(0), COLORKEY);
      t = loadGrid(tiles, color(0), COLORKEY);
      e = loadGrid(enemy, color(0), COLORKEY);
      TILESIZE_X = t[0][0].width;
      TILESIZE_Y = t[0][0].height;
      Stage = new Level("level.txt");
      Player = new Caracter(p, 1, 5, PLAYER);
      for (int i = 0; i < 14; i++)
        Enemies[i] = new Caracter(e, 24+i*2, 2, ENEMY);
   break;
   case EDITOR:
      aux = loadImage("background.bmp");
      background = formatAndroid(aux);
      tiles = loadImage("tiles.bmp");
      t = loadGrid(tiles, color(0), COLORKEY);
      TILESIZE_X = t[0][0].width;
      TILESIZE_Y = t[0][0].height;
      File f = new File(dataPath("newLevel.txt"));
      if (f.exists()) Stage = new Level("newLevel.txt");
      else  Stage = new Level();
      TilePad = new TileTable();
      localData = Stage.data;
   break;
  }
  loading = false;
}
  