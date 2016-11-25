import processing.serial.*;

// Define serial reader
Serial port;

// Define image objects
PImage table;
PImage paddle1;
PImage paddle2;
PImage ball;

// Set image object width and height
int PADDLE_WIDTH    = 90;
int PADDLE_HEIGHT   = 140;
int BALL_DIMENSIONS = 25;

// Set default dimensions
int CANVAS_WIDTH       = 888;
int CANVAS_HEIGHT      = 603;
int P1_DEFAULT_POS_X   = -350;
int P1_DEFAULT_POS_Y   = 30;
int P2_DEFAULT_POS_X   = -P1_DEFAULT_POS_X;
int P2_DEFAULT_POS_Y   = P1_DEFAULT_POS_Y;
int BALL_DEFAULT_POS_X = 0;
int BALL_DEFAULT_POS_Y = 8;

// Save last recorded distance
int P1_CURRENT_DIST = 0;
int P2_CURRENT_DIST = 0;

// Variables for computer player motion
Boolean comp_up = true;
Boolean comp_down = false;

// Set hit accuracy (in pixels)
int ACCURACY = 10;

// Define motion parameters
int acc_x, acc_y;

void setup() {
  // initialize serial reader to read data from serial port
  /*printArray(Serial.list());
  delay(100000);*/
  //port = new Serial(this, Serial.list()[3], 9600);
  //port.bufferUntil('*'); // end of data transmission
  
  // setup canvas parameters
  size(888, 603);
  noStroke();
  smooth();
  
  P1_CURRENT_DIST = P1_DEFAULT_POS_Y;
  P2_CURRENT_DIST = P2_DEFAULT_POS_Y;
 
  // assign image objects an actual image
  table   = loadImage("ping_pong_bg.jpg");
  paddle1 = loadImage("paddle1.png");
  paddle2 = loadImage("paddle2.png");
  ball    = loadImage("ball.png");
  draw_canvas(P1_DEFAULT_POS_Y, P2_DEFAULT_POS_Y);
}

// Used to control the computer's paddle 
void draw() {
  if (comp_up)
    P2_CURRENT_DIST -= 10;
  else
    P2_CURRENT_DIST += 10;
  
  if (P2_CURRENT_DIST > (CANVAS_HEIGHT / 2)) {
    comp_up = true;
    comp_down = false;
  }
  else if (P2_CURRENT_DIST < (-CANVAS_HEIGHT / 2)) {
    comp_down = true;
    comp_up = false;
  }
  
  draw_canvas(P1_CURRENT_DIST, P2_CURRENT_DIST);
}

// Used to control the user's paddle
void serialEvent(Serial port) {
  int dist = getData(port.readString());
  if (dist > -1) {
    println(dist);
    int new_dist = pix_map(dist);
    if (abs(new_dist - P1_CURRENT_DIST) > 10)
      P1_CURRENT_DIST = new_dist;
  }
}

int getData(String data) {
    if (data != null) {
      data = data.substring(0, data.length() - 1);
      int dist = 0;
      
      try {
        dist = Integer.parseInt(data.trim());
      } catch (NumberFormatException e) { /* do nothing */ }
      
      if (dist > 0)
        return dist;
      else 
        return -1;
    } 
    else 
      return -1;
}

int pix_map(int dist) {
  int max_dist = (CANVAS_HEIGHT - P1_DEFAULT_POS_Y) / 2;
  int return_dist = 2 * (dist - max_dist) + 286;
  
  if (return_dist > 286)
    return_dist = 286;

  return return_dist;
}

void draw_canvas(int P1_CURRENT_DIST, int P2_CURRENT_DIST) {
  imageMode(CENTER);
  background(table);
  translate(width / 2, height / 2);
  draw_image(paddle1, P1_DEFAULT_POS_X, P1_CURRENT_DIST, PADDLE_WIDTH, PADDLE_HEIGHT, false);
  draw_image(paddle2, P2_DEFAULT_POS_X, P2_CURRENT_DIST, PADDLE_WIDTH, PADDLE_HEIGHT, false);
  draw_image(ball, BALL_DEFAULT_POS_X, BALL_DEFAULT_POS_Y, BALL_DIMENSIONS, BALL_DIMENSIONS, true);
}

ArrayList<Integer> draw_image(PImage i, int x, int y, int w, int h, Boolean isBall) {
  ArrayList<Integer> pos_vals = new ArrayList<Integer>();
  if (y <= 603 && abs(x) <= 888) {
    image(i, x, y, w, h);
    
    // draw hit points
    color c = color(255, 0, 0);  
    fill(c);  
    if (isBall == false) {
      if (x < 0) {
        ellipse(x + 5, y - 20, 10, 10); // paddle 1
        pos_vals.add(x + 5);
        pos_vals.add(y - 20);
      }
      else {
        ellipse(x - 5, y - 20, 10, 10); // paddle 2
        pos_vals.add(x - 5);
        pos_vals.add(y - 20);
      }
    }
    else {
      c = color(255, 255, 255);
      fill(c);
      ellipse(-1, 8, 10, 10); // ball
      pos_vals.add(-1);
      pos_vals.add(8);
    }
  }
  
  return pos_vals;
}

Boolean isHit(ArrayList<Integer> pos_vals) {
  Boolean hit = false;
  
  if (pos_vals.size() > 0) {
    if (abs(abs(pos_vals.get(0)) - abs(pos_vals.get(2))) <= ACCURACY)
      hit = true;
    else if  (abs(abs(pos_vals.get(1)) - abs(pos_vals.get(3))) <= ACCURACY)
      hit = true;
  }
  
  return hit;
}