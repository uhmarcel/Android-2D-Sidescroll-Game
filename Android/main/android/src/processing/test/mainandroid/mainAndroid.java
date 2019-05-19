package processing.test.mainandroid;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class mainAndroid extends PApplet {


Caracter Player; //<>//
Level Stage;
TileTable TilePad;
final int MAIN = 0;
final int EDITOR = 1;
final int COLLISION = 1;
final int TILESPRITE = 0;

int mode = 0;

int TILESAMOUNT = 100;
int TILESIZE; 
int TILESPERROW = 13;
int OFFSET = 50;
int[][][] localData;
int COLORKEY = color(0,255,0);
PImage background;
PImage tiles;
PImage player;
PImage aux;
PImage[][] t; // Tile sprites
PImage[][] p; // Player sprites

public void setup() 
{
  
  background(255);
  OFFSET = formatAndroid(OFFSET, 'x');
  switch (mode) {
   case MAIN:
      aux = loadImage("background2.bmp");
      tiles = loadImage("tiles-2.bmp");
      player = loadImage("player.bmp");
      background = formatAndroid(aux);
      p = loadGrid(player, color(0), COLORKEY);
      t = loadGrid(tiles, color(0), COLORKEY);
      TILESIZE = t[0][0].width;
      Player = new Caracter(p, TILESIZE*1, TILESIZE*5);
      Stage = new Level("newLevel.txt");
      break;
   case EDITOR:
      aux = loadImage("background2.bmp");
      background = formatAndroid(aux);
      tiles = loadImage("tiles-2.bmp");
      File f = new File(dataPath("newLevel.txt"));
      if (f.exists())  Stage = new Level("newLevel.txt");
      else  Stage = new Level();
      t = loadGrid(tiles, color(0), COLORKEY);
      TilePad = new TileTable(t);
      localData = Stage.data;
      TILESIZE = t[0][0].width;
      println(TILESIZE);
      break;
  }
}

public void draw() {
  switch (mode) {
   case MAIN:
      displayBackground(background, Stage);
      Stage.display();
      Player.movementManager(Stage);
      Player.display();
      if(Player.y > height+100) setup();
      if (mousePressed) {
        if (mouseX < width/2) 
          Player.move = -2; 
        else 
          Player.move = 2;
      }
      else
        Player.move = 1;
      break;
   case EDITOR:
      displayBackground(background, Stage);
      Stage.display();
      TilePad.display();
      
      break;
  }    
  println(frameRate);
}

// EVENTS

public void keyPressed() {
  switch(mode) {
    case MAIN:
      if (key == CODED) {
        if (keyCode == LEFT)
          Player.move = -2; 
        else if (keyCode == RIGHT)
          Player.move = 2;
        else if (keyCode == UP && Player.localCollision[1] == 1)
          Player.jump();
      } 
    break;
    case EDITOR:
      if (key == CODED) {
        if (keyCode == LEFT && Stage.pos >= 4)
          Stage.pos -= 4; 
        else if (keyCode == RIGHT && Stage.pos <= (Stage.wide * (TILESIZE) - width)- 4)
          Stage.pos += 4;
      }
    break;
  } 
}
public void keyReleased() {
  switch(mode) {
    case MAIN:
      if (key == CODED) {
        if (keyCode == LEFT)
          Player.move = -1; 
        else if (keyCode == RIGHT)
          Player.move = 1;
      }
    break;
    case EDITOR:
      if (key == 's') {
        Stage.export();
    break;
    }
  }
}

int savedTile;
/*void mouseClicked() {
  switch (mode) {
    case EDITOR:
      int tileX = floor((mouseX + Stage.pos) / TILESIZE);
      int tileY = floor(mouseY / TILESIZE); //<>//
      int temp;
      if (mouseButton == LEFT) {
        if(TilePad.active && mouseX>TilePad.pos) {
          temp = TilePad.check(mouseX,mouseY);
          if (temp != -1) savedTile = temp;
        }
        else
          localData[0][tileY][tileX] = savedTile;
      }
      if (mouseButton == RIGHT) 
        TilePad.active = !TilePad.active;
      break;
  }
}     */
    
      


// CLASSES

class Point {
  int x = 0;
  int y = 0;
  Point (int xvalue, int yvalue) {
    x = xvalue;
    y = yvalue;
  }
}
class Line {
  Point A = new Point(0,0);
  Point B = new Point(0,0);
  Line (Point a, Point b) {
    A = a;
    B = b;
  }
}


// FUNCTIONS

public void displayBackground(PImage img, Level lvl) {
  image(img, floor(-1 * lvl.pos * (img.width - width) / PApplet.parseFloat(lvl.wide * TILESIZE - width)), 0);
}
public PImage tile(PImage tiles, int tileNumber) 
{
  PImage t;
  int pixel;
  int x = tileNumber % 10;
  int y = floor(tileNumber / 10);
  t = createImage(TILESIZE,TILESIZE, ARGB);
  t.loadPixels();
  tiles.loadPixels();

  pixel = (y * (TILESIZE+1) * 10) * (TILESIZE+1) + x * (TILESIZE+1);
  for (int i = 0; i < TILESIZE; i++)  {
    for (int j = 0; j < TILESIZE; j++)  {      
      t.pixels[j*TILESIZE + i] = tiles.pixels[(TILESIZE+1)*10*j+pixel+i];
      if (t.pixels[j*TILESIZE + i] == color(0, 255, 0))  {
          t.pixels[j*TILESIZE + i] = color(0, 0); 
      }
    }
  }
  t.updatePixels();
  return t;
}
public PImage[][] loadGrid(PImage grid, int discriminant, int colorkey) 
{
  Line[] data = new Line[1];
  PImage[][] sprite;
  grid.loadPixels();
  Point A = new Point(0,0);
  Point B = new Point(0,0);
  boolean done = false;
  int[] row = new int[1];
  int k = 0;
  int y = 0;
  //  MEASUREMENTS
  while (done == false) {
    for (int x = 0; x < grid.width; x++) {
      if (grid.pixels[y * grid.width + x] == discriminant) {
        for (int n = 0; n + y < grid.height; n++) {
          if (grid.pixels[n * grid.width] == discriminant) {
            B = new Point(x - 1, y + (n - 1));
            if (data[0] == null)
              data[0] = new Line(A,B);
            else
              data = (Line[])append(data, new Line(A,B));
            if (k < row.length)  
              row[k] = row[k] + 1;
            else
              row = append(row, 1);
            break;
          }
        }
        x = x + 1;
        A = new Point(x, y);
      }
    }
    y = y + data[data.length-1].B.y - data[data.length-1].A.y + 2;
    if (y < grid.height)
      A = new Point(0, y);
    else
      done = true;
    k++;
  }
  int count = 0;
  sprite = new PImage[0][0];
  for (int j = 0; j < row.length; j++) {
    sprite = (PImage[][])append(sprite, new PImage[0]);
    for (int i = 0; i < row[j]; i++) {
      Line local = data[count];
      count++;
      int fix = 1;
      local.B.x+=fix; local.B.y+=fix;
      PImage I = createImage(local.B.x-local.A.x,local.B.y-local.A.y, ARGB);
      I.loadPixels();
      for (int Y = 0; Y < local.B.y - local.A.y; Y++) {
        for (int x = 0; x < local.B.x - local.A.x; x++) {
          if (grid.pixels[(local.A.y + Y)*grid.width + local.A.x + x] == colorkey) 
            I.pixels[Y*(local.B.x-local.A.x)+x] = color(0,0);
          else 
            I.pixels[Y*(local.B.x-local.A.x)+x] = grid.pixels[(local.A.y + Y)*grid.width + local.A.x + x];
        }
      } 
      PImage temp = formatAndroid(I);
      sprite[j] = (PImage[])append(sprite[j], temp);
    }    
  } 
  return sprite;
}
      
 public PImage formatAndroid(PImage img, int refWidth, int refHeight) {
   int w = floor(map(img.width, 0, refWidth, 0, width));
   int h = floor(map(img.height, 0, refHeight, 0, height));
   PImage temp = createImage(w,h,ARGB);
   temp.copy(img, 0, 0, img.width, img.height, 0, 0, w, h);
   return temp;
 }
 
 public PImage formatAndroid(PImage img) {
   return formatAndroid(img, 600, 300);
 }
 
 public float formatAndroid(float i, char xy) {
   if (xy == 'x')
     return map(i, 0, 600, 0, width);   
   else
     return map(i, 0, 300, 0, height);   
 }
 public int formatAndroid(int i, char xy) {
   if (xy == 'x')
     return floor(map(i, 0, 600, 0, width));   
   else
     return floor(map(i, 0, 300, 0, height));   
 }
    
   
  
  

  

  
 
class Caracter {
  PImage[][] img;
  int lives;
  float x;
  float y;
  float x_vel = 0;
  float y_vel = 0;
  float x_acc = 0;
  float real_X;
  int move = 1; // can only be -2,-1, 1 or 2
  int tilesWide;
  int[] localCollision;
  float GRAVITY = 0.16f;
  float MAXSPEED = 2;
  float DEFAULT_ACCELERATION = 0.2f;
  float JUMPVALUE = -5; 
  float STOPFACTOR = 1.2f; // higher value implies shorter stopping time 
  int s = 0;
  
  
  Caracter (PImage[][] caracterImg, float xpos, float ypos) {
    img = caracterImg;
    x = xpos;
    y = ypos;
    lives = 3;
    GRAVITY = formatAndroid(GRAVITY,'y');
    MAXSPEED = formatAndroid(MAXSPEED, 'x');
    DEFAULT_ACCELERATION = formatAndroid(DEFAULT_ACCELERATION, 'x');
    JUMPVALUE = formatAndroid(JUMPVALUE, 'y');
  }
  
  public int sprite(int amountOfSprites, int interval) {
    int n = floor(millis()/interval);
    return n % amountOfSprites;
  }
          
    
  
  public void display() {
    int index = 0;
    switch (move) {
      case 1:
        index = 0; s = 0; break;
      case -1:
        index = 2; s = 0; break;
      case 2:
        index = 1; s = sprite(4, 200); break;
      case -2:
        index = 3; s = sprite(4, 200); break;
      case 3:
        if (localCollision[1] == 1) { index = 0; s = 0; }
        else {index = 1; s = 0; } break;
      case -3: 
        if (localCollision[1] == 1) { index = 2; s = 0; }
        else {index = 3; s = 0; } break;
    }
    image(img[index][s], x - img[index][s].width/2, y - img[index][s].height);
  }
  
  public void movementManager(Level stage) 
  {
    int[] collision;
    if (move == 2) { 
      x_acc = DEFAULT_ACCELERATION;
      x_vel = x_vel + x_acc;
      if (x_vel > MAXSPEED) x_vel = MAXSPEED;
    }
    else if (move == -2) { 
      x_acc = (-1) * DEFAULT_ACCELERATION;
      x_vel = x_vel + x_acc;
      if (x_vel < (-1)*MAXSPEED) x_vel = (-1)*MAXSPEED;
    }
    else if (abs(move) == 1 && x_vel != 0) { 
      x_acc = 0;
      x_vel = x_vel / STOPFACTOR;
      if (abs(x_vel) < 0.1f) x_vel = 0;
    }
    collision = checkCollision(stage.data[COLLISION]);
    localCollision = collision;
    if (collision[1] != 1) // If not on ground, add gravity.
      y_vel = y_vel + GRAVITY;
    else if (y_vel > 0 && collision[1] == 1)
      y_vel = 0;
    if ((x_vel > 0 && collision[0] == 1) || (x_vel < 0 && collision[0] == -1)) // If not colliding, move on x-axis
      x_vel = 0;
    if (y_vel < 0 && collision[1] == -1) // Stop jumping if collide
      y_vel = 0; 
     
    if ((x_vel > 0 && x < width/2 + OFFSET) || (x_vel < 0 && x > width/2 - TILESIZE - OFFSET))
       x = x + x_vel;
    else if (x_vel > 0 && stage.pos >= stage.wide * TILESIZE - width)
       x = x + x_vel;
    else if (x_vel < 0 && stage.pos <= 0)
       x = x + x_vel;
    else       
       stage.pos += x_vel;
     y = y + y_vel;
     real_X = x + stage.pos;
     tilesWide = stage.wide; 
  }
  
  public void jump() {
    y_vel = JUMPVALUE;
    if (move > 0) move = 3;
    else move = -3;
  }
  
  public int[] checkCollision(int[][] levelCollision) 
  {
    int x_tile = floor((real_X) / TILESIZE);
    int y_tile = floor((y - TILESIZE/2) / TILESIZE);
    int[] a = new int[2];
    
    if (x_tile < 0) x_tile = 0;
    if (y_tile < 1) y_tile = 1;
    if (x_tile > levelCollision[0].length-1) x_tile = levelCollision[0].length-1;
    if (y_tile > levelCollision.length-2) y_tile = levelCollision.length-2;
    
    if (x_tile == 0)
      a[0] = -1;
    else if (x_tile == tilesWide-1)
      a[0] = 1;
    else if (levelCollision[y_tile][x_tile+1] == 1 && abs((real_X)-(x_tile+1)*TILESIZE)<=TILESIZE/2)
      a[0] = 1;
    else if (levelCollision[y_tile][x_tile-1] == 1 && abs((real_X)-(x_tile)*TILESIZE)<=TILESIZE/2)
      a[0] = -1;
    else  a[0] = 0;
    if (levelCollision[y_tile+1][x_tile] == 1 && abs((y-TILESIZE/2)-(y_tile+1)*TILESIZE)<=TILESIZE/2)
      a[1] = 1;
    else if (levelCollision[y_tile-1][x_tile] == 1 && abs((y-TILESIZE/2)-(y_tile)*TILESIZE)<=TILESIZE/2)
      a[1] = -1;
    else a[1] = 0;
    
    return a;
 
  }
  
}   
    
  

class TileTable {
  int pos;
  boolean active = false;
  int selectedTile;
  PImage guiBase;
  PImage guiButtons;
  int base = color(100, 180);
  int buttons = color(0,0);
  int buttonPos[][] = new int[TILESAMOUNT][2];
  
  TileTable(PImage[][] tileset) {
    TILESIZE = tileset[0][0].width;
    guiBase = createImage(14 + (TILESIZE/2) * 7, width, ARGB);
    guiButtons = createImage(14 + (TILESIZE/2) * 7, width, ARGB);
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
        guiButtons.copy(t[count / TILESPERROW][count % TILESPERROW],0, 0, TILESIZE, TILESIZE, 4+i*(TILESIZE/2+1), 10 +j*(TILESIZE/2+1), TILESIZE/2, TILESIZE/2);
        buttonPos[count][0] = pos+4+i*(TILESIZE/2+1)+TILESIZE/4;
        buttonPos[count][1] = 10+j*(TILESIZE/2+1)+TILESIZE/4;
        count++;
      }
    }
  }
      
  public void display() { 
    if(active) {
    image(guiBase, pos, 0);
    image(guiButtons, pos, 0);
    }
  }
    
  public int check(int x1, int y1) {
    for (int i = 0; i < buttonPos.length; i++) {
      if (abs(buttonPos[i][0]-x1) < TILESIZE/4 && abs(buttonPos[i][1]-y1) < TILESIZE/4)
        return i;
    }
    return -1;
  }
}

class Level {
  String file;    // Import specific level
  int pos = 0;
  int wide;
  int high = 11;
  int[][][] data; // Noted as rows by columns
  int SOLID = 1;
  PImage image;
  Level(String fileName) {
    file = fileName;
    String[] loaded = loadStrings(file);
    String[] loaded1 = loadStrings("collision.txt");
    int[] solidsID = PApplet.parseInt(split(loaded1[0], ','));
    int row = loaded.length;
    int col = PApplet.parseInt(splitTokens(loaded[0], ", ")).length;
    data = new int[2][row][col];
    for (int r = 0; r < row; r++) {
      data[TILESPRITE][r] = PApplet.parseInt(splitTokens(loaded[r], ", "));
      for (int n = 0; n < data[TILESPRITE][r].length; n++) {
        for (int i = 0; i < solidsID.length; i++) {
          if (data[TILESPRITE][r][n] == solidsID[i])
            data[COLLISION][r][n] = SOLID;
        }  
      }
    }
    wide = col;
    high = row;
    image = createImage(col*TILESIZE, row*TILESIZE, ARGB);
    for (int j = 0; j < 11; j++) {
      for (int i = 0; i < wide; i++) {
        PImage temp = t[data[TILESPRITE][j][i]/TILESPERROW][data[TILESPRITE][j][i]%TILESPERROW];
        image.copy(temp, 0, 0, temp.width, temp.height, i*TILESIZE, j*TILESIZE, temp.width, temp.height);
      }
    }
  }
  
  Level() { 
    int row = 11;          // DEFAULT VALUES. Change later.
    int col = 40;
    data = new int[2][row][col];  
  }
      
  public void display() {
    image(image, -pos, 0);
    
  }
      
  public void export() {
    PrintWriter output = createWriter("data/newLevel.txt");
    String[] strData = new String[0];
    int row = localData[0].length;
    for (int r = 0; r < row; r++) {
        strData = append(strData, join(nf(localData[0][r], 0), ", "));
        strData[r] = strData[r] + ",";
        output.println(strData[r]);
    }
    output.flush();
    output.close();
    
  }
}
  
         
    
  

    
    
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "mainAndroid" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
