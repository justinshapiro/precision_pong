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

void setup() {
  // initialize serial reader to read data from serial port
  port = new Serial(this, Serial.list()[0], 9600);
  
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
  draw_canvas();
}

void draw() { // loop
  if (port.available() > 0) {
    port.read();
    // everything goes here
    // call data parsing methods to get locations
    // parse serial data so that we can determine a screen position
  }
  draw_canvas(); // do not remove
}

void draw_canvas() {
  imageMode(CENTER);
  background(table);
  translate(width / 2, height / 2);
  draw_image(paddle1, P1_DEFAULT_POS_X, P1_DEFAULT_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT, false);
  draw_image(paddle2, P2_DEFAULT_POS_X, P2_DEFAULT_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT, false);
  draw_image(ball, BALL_DEFAULT_POS_X, BALL_DEFAULT_POS_Y, BALL_DIMENSIONS, BALL_DIMENSIONS, true);
}

void draw_image(PImage i, int x, int y, int w, int h, Boolean isBall) {
  image(i, x, y, w, h);
  
  // draw hit points
  color c = color(255, 0, 0);  
  fill(c);  
  if (isBall == false) {
    if (x < 0)
      ellipse(x + 5, y - 20, 10, 10); // paddle 1
    else
      ellipse(x - 5, y - 20, 10, 10); // paddle 2
  }
  else {
    c = color(255, 255, 255);
    fill(c);
    ellipse(-1, 8, 10, 10); // ball
  }
}