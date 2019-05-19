  
void inputManager(int x, int y, boolean active) {
  switch(mode) {
    case MAIN:
      if (active) {
        if (x < width/6) 
        { Player.move = 2; Player.direction = -1; }
        else if (x > width/6 && x < width*2/6)
        { Player.move = 2; Player.direction = 1; }
        else if (x > width*5/6)
         Player.jump();
      }
      else {
        if (x < width/6) 
        { Player.move = 1; Player.direction = -1; }
        else if (x > width/6 && x < width*2/6)
        { Player.move = 1; Player.direction = 1; }
      }
    break;
    case EDITOR:
      int tileX = floor((x + Stage.pos) / TILESIZE_X);
      int tileY = floor(y / TILESIZE_Y);
      int temp;
      if (pointers == 1) {
        if(TilePad.active && x >TilePad.pos) {
          temp = TilePad.check(x, y);
          if (temp != -1) savedTile = temp;
        }
        else {
          localData[0][tileY][tileX] = savedTile;
          Stage.update(tileX,tileY);
        }          
      }
      if (pointers == 2) 
        TilePad.active = !TilePad.active;
    break;
  }
}

void inputManager(float x, float y, boolean active){
  inputManager(round(x), round(y), active);
}

void keyPressed() {
  switch(mode) {
    case MAIN:
      if (key == CODED) {
        if (keyCode == LEFT)
          Player.move = -2; 
        else if (keyCode == RIGHT)
          Player.move = 2;
        else if (keyCode == UP && Player.collision[1] == 1)
          Player.jump();
      } 
    break;
    case EDITOR:
      if (key == CODED) {
        if (keyCode == LEFT && Stage.pos >= 4)
          Stage.pos -= 4; 
        else if (keyCode == RIGHT && Stage.pos <= (Stage.wide * (TILESIZE_X) - width)- 4)
          Stage.pos += 4;
      }
    break;
  } 
}
void keyReleased() {
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

void displayBackground(PImage img, Level lvl) {
  image(img, floor(-1 * lvl.pos * (img.width - width) / float(lvl.wide * TILESIZE_X - width)), 0);
}
PImage tile(PImage tiles, int tileNumber) 
{
  PImage t;
  int pixel;
  int x = tileNumber % 10;
  int y = floor(tileNumber / 10);
  t = createImage(TILESIZE_X, TILESIZE_Y, ARGB);
  t.loadPixels();
  tiles.loadPixels();

  pixel = (y * (TILESIZE_Y+1) * 10) * (TILESIZE_Y+1) + x * (TILESIZE_X+1);
  for (int i = 0; i < TILESIZE_X; i++)  {
    for (int j = 0; j < TILESIZE_Y; j++)  {      
      t.pixels[j*TILESIZE_Y + i] = tiles.pixels[(TILESIZE_Y+1)*10*j+pixel+i];
    }
  }
  t.updatePixels();
  return t;
}
PImage[][] loadGrid(PImage grid, color discriminant, color colorkey) 
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
      PImage I = createImage(local.B.x-local.A.x,local.B.y-local.A.y, RGB);
      I.loadPixels();
      for (int Y = 0; Y < local.B.y - local.A.y; Y++) {
        for (int x = 0; x < local.B.x - local.A.x; x++) {
          if (grid.pixels[(local.A.y + Y)*grid.width + local.A.x + x] != colorkey) 
            I.pixels[Y*(local.B.x-local.A.x)+x] = grid.pixels[(local.A.y + Y)*grid.width + local.A.x + x];
        }
      } 
      PImage temp = formatAndroid(I);
      sprite[j] = (PImage[])append(sprite[j], temp);
    }    
  } 
  return sprite;
}
      
PImage formatAndroid(PImage img, int refWidth, int refHeight) {
  int w = round(map(img.width, 0, refWidth, 0, width));
  int h = round(map(img.height, 0, refHeight, 0, height));
  PImage temp = createImage(w,h,ARGB);
  temp.copy(img, 0, 0, img.width, img.height, 0, 0, w, h);
  return temp;
}
 
PImage formatAndroid(PImage img) {
  return formatAndroid(img, 600, 300);
}
 
float formatAndroid(float i, char xy) {
  if (xy == 'x') return map(i, 0, 600, 0, width);   
  else return map(i, 0, 300, 0, height);   
}
int formatAndroid(int i, char xy) {
  if (xy == 'x') return floor(map(i, 0, 600, 0, width));   
  else return floor(map(i, 0, 300, 0, height));   
}

void stack(PImage source, PImage destination, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
  source.loadPixels();
  destination.loadPixels();
  for (int j = 0; j < sh - sy; j++) {
    for (int i = 0; i < sw - sx; i++) {
      if(source.pixels[source.width*j+i]!= 0 && destination.width*(dy+j)+(dx+i)<destination.width*destination.height && alpha(source.pixels[source.width*j+i]) == 255)
        destination.pixels[destination.width*(dy+j)+(dx+i)] = source.pixels[source.width*j+i];
    }
  }
  destination.updatePixels();
}
      
void setupLoadingText() {
  textAlign(CENTER, CENTER);
  textSize(height/6);
  fill(255);
}

void loadingScreen() {
  background(0);
  text("LOADING...", width/2, height/2);
  int value = (millis()/3) % 510;
  if (value < 255)
    fill(255, value);
  else 
    fill(255, 510 - value);
}