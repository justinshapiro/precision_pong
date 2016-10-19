import processing.serial.*;

// Define image objects
PImage bg, paddle1, paddle2, ball;

// Define serial reader
Serial port;

void setup() {
  // initialize serial reader to read data from serial port
  port = new Serial(this, Serial.list()[0], 9600);
  // Canvas-size
  size(888, 603);
  
  // assign image objects an actual image
  bg      = loadImage("ping_pong_bg.jpg");
  paddle1 = loadImage("paddle1.png");
  paddle2 = loadImage("paddle2.png");
  ball    = loadImage("ball.png");
  imageMode(CENTER);
}

void draw() { // loop
  // draw image object on screen
  background(bg);
  translate(width / 2, height / 2);
  image(paddle1, -350, 30, 90, 140);
  image(paddle2, 350, 30, 90, 140);
  image(ball, 0, 8, 25, 25);
  
  if (port.available() > 0) {
    port.read();
    // etc...
  }
}