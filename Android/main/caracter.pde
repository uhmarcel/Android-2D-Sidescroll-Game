  //<>//
class Caracter {
  PImage[][] img;
  
  int type;
  int lives;

  float x;
  float y;
  float x_vel = 0;
  float y_vel = 0;
  float x_acc = 0;
  float real_X;
  
  int fRun = 1;
  int fIdle = 1;
  int fDelay = 200;
  
  int move = 1; 
  int direction = 1;
  int[] collision = new int[2];
  
  int A = 1; // Proportion
  float GRAVITY = 0.25*A;
  float MAXSPEED = 2.4*A;
  float ACCELERATION = 1*A;
  float JUMPVALUE = -6*A; 
  float STOPFACTOR = 2.4*A; // higher value implies shorter stopping time 
  int OFFSET = width / 12;
  
  int tilesWide;
  int clockOffset;
  int s = 0;

  
  Caracter (PImage[][] caracterImg, float xpos, float ypos, int entityType) {
    img = caracterImg;
    x = xpos * TILESIZE_X;
    y = ypos * TILESIZE_Y;
    
    switch(entityType) {
      case PLAYER:
        type = PLAYER;
        lives = 3;
        fIdle = 1;
        fRun = 4;
        fDelay = 140;
      break;
      case ENEMY:
        type = ENEMY;
        fIdle = 4;
        fRun = 8;
        fDelay = 100;
        MAXSPEED = 0.4*A;
        ACCELERATION = 0.1*A;
        JUMPVALUE = -3*A;
        clockOffset = int(random(6000));
      break;
    }
        
    GRAVITY = formatAndroid(GRAVITY,'y');
    MAXSPEED = formatAndroid(MAXSPEED, 'x');
    ACCELERATION = formatAndroid(ACCELERATION, 'x');
    JUMPVALUE = formatAndroid(JUMPVALUE, 'y');
  }
  
  
  int sprite(int amountOfSprites, int interval) {
    int n = floor(millis()/interval);
    return n % amountOfSprites;
  }
          
    
  void update() {
    int index = 0;
    if ((type == PLAYER) || (x>Stage.pos-2*OFFSET && x<Stage.pos+width+2*OFFSET)) {   // Only update if on screen
      checkCollision(Stage.data[COLLISION]);
      manageAI();
      movementManager();
     
      if (collision[1] == 1) {
        switch (move*direction) {
          case 1:
            index = 0; s = sprite(fIdle, fDelay); break;
          case -1:
            index = 2; s = sprite(fIdle, fDelay); break;
          case 2:
            index = 1; s = sprite(fRun, fDelay); break;
          case -2:      
            index = 3; s = sprite(fRun, fDelay); break;
        }
      }
      else {
        if (move*direction > 0) {index = 1; s = 0;}
        else if (move*direction < 0) {index = 3; s = 0;}
      }
      if (type == PLAYER) image(img[index][s], round(x - img[index][s].width/2), round(y - img[index][s].height));
      else if (type == ENEMY) image(img[index][s], round((x - Stage.pos) - img[index][s].width/2), round(y - img[index][s].height));  
    }
  }
  
  
  void movementManager() 
  {
    if (move*direction == 2) { 
      x_vel = x_vel + ACCELERATION;
      if (x_vel > MAXSPEED) x_vel = MAXSPEED;
    }
    else if (move*direction == -2) { 
      x_vel = x_vel - ACCELERATION;
      if (x_vel < (-1)*MAXSPEED) x_vel = (-1)*MAXSPEED;
    }
    else if (abs(move*direction) == 1 && x_vel != 0) { 
      if (collision[1] != 1) x_vel = x_vel * 0.9;
      else x_vel = x_vel / STOPFACTOR;
      if (abs(x_vel) < 0.1) x_vel = 0;
    }
    if (collision[1] != 1) // If not on ground, add gravity.
      y_vel = y_vel + GRAVITY;
    else if (y_vel > 0 && collision[1] == 1) {
      y_vel = 0;  y = floor(y / TILESIZE_Y)*TILESIZE_Y + 1; }
    if ((x_vel > 0 && collision[0] == 1) || (x_vel < 0 && collision[0] == -1)) // If not colliding, move on x-axis
      x_vel = 0;
    if (y_vel < 0 && collision[1] == -1) // Stop jumping if collide
      y_vel = 0; 
     
    if (type != PLAYER || (x_vel > 0 && x < width/2 + OFFSET) || (x_vel < 0 && x > width/2 - TILESIZE_X - OFFSET))
       x = x + x_vel;
    else if (x_vel > 0 && Stage.pos >= Stage.wide * TILESIZE_X - width)
       x = x + x_vel;
    else if (x_vel < 0 && Stage.pos <= 0)
       x = x + x_vel;
    else       
       Stage.pos += x_vel;
     y = y + y_vel;
     if (type == PLAYER) real_X = x + Stage.pos;
     else real_X = x;
     tilesWide = Stage.wide;
  }
   
   
  void jump() {
    if(collision[1] == 1) y_vel = JUMPVALUE;
  }
  
  
  void checkCollision(int[][] levelCollision) 
  {
    int x_tile = floor((real_X) / TILESIZE_X);
    int y_tile = floor((y - TILESIZE_Y/2) / TILESIZE_Y); //////////////////////////
    int[] a = new int[2];
    
    if (x_tile < 0) x_tile = 0;
    if (y_tile < 1) y_tile = 1;
    if (x_tile > levelCollision[0].length-1) x_tile = levelCollision[0].length-1;
    if (y_tile > levelCollision.length-2) y_tile = levelCollision.length-2;
    
    if (x_tile == 0)
      a[0] = -1;
    else if (x_tile == tilesWide-1) 
      a[0] = 1; 
    else if (levelCollision[y_tile][x_tile+1] == 1 && abs((real_X)-(x_tile+1)*TILESIZE_X)<=TILESIZE_X/2 )
      a[0] = 1;
    else if (levelCollision[y_tile][x_tile-1] == 1 && abs((real_X)-(x_tile)*TILESIZE_X)<=TILESIZE_X/2)
      a[0] = -1;
    else  a[0] = 0;
    if (levelCollision[y_tile+1][x_tile] == 1 && abs((y-TILESIZE_Y/2)-(y_tile+1)*TILESIZE_Y)<=TILESIZE_Y/2)
      a[1] = 1;
    else if (levelCollision[y_tile+1][x_tile] == 2 && abs((y-TILESIZE_Y/2)-(y_tile+1)*TILESIZE_Y)<=TILESIZE_Y/2)
      a[1] = 1;
    else if (levelCollision[y_tile-1][x_tile] == 1 && abs((y-TILESIZE_Y/2)-(y_tile)*TILESIZE_Y)<=TILESIZE_Y/2)
      a[1] = -1;
    else a[1] = 0;
    collision = a;
  }
  
  
  int currentCycle = -1;
  boolean newCycle = true;
  float run = 0;
  
  void manageAI() {
    if (type != PLAYER) {
    int cycleLenght = 6000; // Measured on Milliseconds
    int clock = millis() + clockOffset;
    float local_clock = clock % cycleLenght;
    float fraction = local_clock / cycleLenght; // Amount from 0 to 1, refering to 1 as full a cycle 
    if (clock/cycleLenght != currentCycle) newCycle = true;
    if (newCycle) run = random(0.1, 0.9);
    if (fraction < run) {
      move = 2;
      if (random(1)<0.25 && newCycle) direction = direction*-1;
    }
    else 
      move = 1;
    currentCycle = floor(clock/cycleLenght);
    newCycle = false;
  }
  }
}
  