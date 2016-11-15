import processing.serial.*;

// Define serial reader
Serial port;

// Define image objects
PImage table, paddle1, paddle2, ball;

// Set dimensions
int CANVAS_WIDTH = 888,
    CANVAS_HEIGHT = 603,
    P1_DEFAULT_POS_X = -350,
    P1_DEFAULT_POS_Y = 30,
    P2_DEFAULT_POS_X = -P1_DEFAULT_POS_X,
    P2_DEFAULT_POS_Y = P1_DEFAULT_POS_Y,
    BALL_DEFAULT_POS_X = 0,
    BALL_DEFAULT_POS_Y = 8;

// Set object width and height
int PADDLE_WIDTH = 90,
    PADDLE_HEIGHT = 140,
    BALL_DIMENSIONS = 25;
    
// Set hit accuracy (in pixels)
int ACCURACY = 10;

// Define motion parameters
int acc_x, acc_y, acc_z, gyr_x, gyr_y, gyr_z, pos_y;

void setup() {
  // initialize serial reader to read data from serial port
  port = new Serial(this, Serial.list()[2], 9600);
  port.bufferUntil('*');
  
  // setup canvas parameters
  size(888, 603);
  frameRate(1000);
  noStroke();
  smooth();
 
  // assign image objects an actual image
  table   = loadImage("ping_pong_bg.jpg");
  paddle1 = loadImage("paddle1.png");
  paddle2 = loadImage("paddle2.png");
  ball    = loadImage("ball.png");
  draw_canvas(P1_DEFAULT_POS_Y);
}

void draw() {
  if (port.available() > 0) {
    int dist = getData(port.readStringUntil('*'));
    if (dist > -1)
      draw_canvas(pix_map(dist));
  }
  else {
    draw_canvas(P1_DEFAULT_POS_Y); // do not remove
  }
}

int pix_map(int dist) {
  int max_dist = (CANVAS_HEIGHT - P1_DEFAULT_POS_Y) / 2;
  return dist - max_dist;
}

int getData(String data) {
    if (data != null) {
      data = data.substring(0, data.length() - 1);
      int dist = P1_DEFAULT_POS_Y;
      
      try {
        dist = Integer.parseInt(data.trim());
      } catch (NumberFormatException e) { /* do nothing */ }
      
      return dist;
    } 
    else 
      return -1;
}

void draw_canvas(int dist) {
  imageMode(CENTER);
  background(table);
  translate(width / 2, height / 2);
  draw_image(paddle1, P1_DEFAULT_POS_X, dist, PADDLE_WIDTH, PADDLE_HEIGHT, false);
  draw_image(paddle2, P2_DEFAULT_POS_X, P2_DEFAULT_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT, false);
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