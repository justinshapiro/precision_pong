import processing.serial.*;
import java.lang.Math;

// Define serial reader
Serial port;

// Define image objects
PImage table;

// Set default dimensions
int CANVAS_WIDTH       = 888;
int CANVAS_HEIGHT      = 603;

// Define game objects
Ball b;
Paddle p1;
Paddle p2;

// Set hit accuracy (in pixels)
int ACCURACY = 30;

// Gameplay variables
int recieving_paddle = 2;

void setup() {
  // initialize serial reader to read data from serial port
  //printArray(Serial.list()); 
 // port = new Serial(this, Serial.list()[3], 9600);
 // port.bufferUntil('*'); // end of data transmission
  
  // Setup canvas parameters
  size(888, 603);
  noStroke();
  smooth();
  
  // Initialize game objects
  b = new Ball();
  p1 = new Paddle("1");
  p2 = new Paddle("2");
 
  // assign image objects an actual image
  table = loadImage("ping_pong_bg.jpg");
  
  draw_canvas();
}

// Used to control the computer's paddle and draw the GUI
void draw() {
  if (isHit()) {
    println("Hit is true");
    b.setSlope();
    
    if (recieving_paddle == 1) {
      recieving_paddle = 2;
    } else if (recieving_paddle == 2) {
      recieving_paddle = 1;
    }
  }
  
  b.move();
  draw_canvas();
}

// Used to control the user's paddle
void serialEvent(Serial port) {
  int dist = getData(port.readString());
  if (dist > -1) {
    println(dist);
    int new_dist = pix_map(dist);
    if (abs(new_dist - p1.curr_y) > 10)
      p1.curr_y = new_dist;
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
  int max_dist = (CANVAS_HEIGHT - 30) / 2;
  int return_dist = 2 * (dist - max_dist) + 286;
  
  if (return_dist > 286)
    return_dist = 286;

  return return_dist;
}

void draw_canvas() {
  imageMode(CENTER);
  background(table);
  translate(width / 2, height / 2);
  draw_image(p1.img, p1.curr_x, p1.curr_y, p1.p_width, p1.p_height, false);
  draw_image(p2.img, p2.curr_x, p2.curr_y, p2.p_width, p2.p_height, false);
  draw_image(b.img, b.curr_x, b.curr_y, b.dim, b.dim, true);
}

void draw_image(PImage i, int x, int y, int w, int h, Boolean isBall) {
  if (y <= 603 && abs(x) <= 888) {
    image(i, x, y, w, h);
    
    // draw hit points
    color c = color(255, 0, 0);  
    fill(c);  
    if (isBall == false) {
      if (x < 0) {
        ellipse(x + 5, y - 20, 10, 10); // paddle 1
      }
      else {
        ellipse(x - 5, y - 20, 10, 10); // paddle 2
      }
    }
    else {
      c = color(255, 255, 255);
      fill(c);
      ellipse(-1, 8, 10, 10); // ball
    }
  }
}

Boolean isHit() {
  Boolean hit = false;
  int paddle_x = 0;
  int paddle_y = 0;
  
  if (recieving_paddle == 1) {
    paddle_x = p1.curr_x;
    paddle_y = p1.curr_y;
  } else if (recieving_paddle == 2) {
    paddle_x = p2.curr_x;
    paddle_y = p2.curr_y;
  }
  
  println(dist_between(paddle_x, paddle_y));
  if (dist_between(paddle_x, paddle_y) <= ACCURACY) {
    hit = true;
  }
  
  return hit;
}

float dist_between(int p_x, int p_y) {
  return sqrt(pow(b.curr_x - p_x, 2) + pow(b.curr_y - p_y, 2));
  
}