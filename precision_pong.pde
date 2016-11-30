import processing.serial.*;
import java.lang.Math;

// Define serial reader
Serial port;

// Define image objects
PImage table;

// Set default dimensions
int CANVAS_WIDTH = 888;
int CANVAS_HEIGHT = 603;

// Define game objects
Ball b;
Paddle p1;
Paddle p2;

// Define hit variables
int ACCURACY = 40;
int ACCEL_HIT = 8000;
Boolean hit;

// Gameplay variables
int recieving_paddle = 2;
int p1_score;
int p2_score;
int level;
Boolean p1_win;
Boolean p2_win;
Boolean reset;
Boolean game_over;

void setup() {
  // initialize serial reader to read data from serial port
  printArray(Serial.list()); 
  port = new Serial(this, Serial.list()[3], 9600);
  port.bufferUntil('#'); // end of data transmission
  
  // Setup canvas parameters
  size(888, 603);
  noStroke();
  smooth();
  textSize(25);
  
  // Initialize game objects
  b = new Ball();
  p1 = new Paddle("1");
  p2 = new Paddle("2");
  hit = false;
  
  level = 0;
  p1_score = 0;
  p2_score = 0;
  p1_win = false;
  p2_win = false;
  reset = false;
  game_over = false;
 
  // assign image objects an actual image
  table = loadImage("ping_pong_bg.jpg");
  
  draw_canvas();
}

// Used to control the computer's paddle and draw the GUI
void draw() {
  if (!game_over) {
    if (isHit()) {
      hit = true;
      b.setSlope();
      
      if (recieving_paddle == 1) {
        recieving_paddle = 2;
        p2.setHitPos(b.getHitPos());
      } else if (recieving_paddle == 2) {
        recieving_paddle = 1;
      }
    }
    
    if (recieving_paddle == 1) {
      if (b.curr_x < p1.curr_x - 100) {
        p2_score++;
        p2_win = true;
        reset();
      }
    }
    else if (recieving_paddle == 2) {
      if (b.curr_x > p2.curr_x + 100) {
        p1_score++;
        p1_win = true;
        reset();
      } else {
        p2.move();
      }
    }
  }
  
  draw_canvas();
  
  if (p1_score == 3 || p2_score == 3) {
    game_over = true;
    reset();
  } else {
    b.move();
  }
}

void reset() {
  if (!game_over) {
    b.curr_x = 345;
  } else {
    b.curr_x = 700;
  }
  
  b.curr_y = 8;
  p1.curr_x = -350;
  p1.curr_y = 30;
  p2.curr_x = 350;
  p2.curr_y = 30;
  reset = true;
}

// Used to control the user's paddle
void serialEvent(Serial port) {
  try {
    int dist = getData(port.readString());
    if (dist > -1) {
      println(dist);
      println("Accel:" + Integer.toString(p1.curr_accel));
      int new_dist = pix_map(dist);
      if (abs(new_dist - p1.curr_y) > 10)
        p1.curr_y = new_dist;
    }
  } catch (RuntimeException e) { /* do nothing */ }
}

int getData(String data) {
    if (data != null) {
      String dist_str, accel_str;
      int dist = 0;
      //data = data.substring(0, data.length() - 1); // removes bufferUntil character
      int split_idx = data.indexOf('*');
      dist_str = data.substring(0, split_idx);
      accel_str = data.substring(split_idx + 1, data.length() - 1);
      
      try {
        dist = Integer.parseInt(dist_str.trim());
        p1.curr_accel = Integer.parseInt(accel_str.trim());
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
  
  String p1_str = "You: " + Integer.toString(p1_score);
  String p2_str = "Computer: " + Integer.toString(p2_score);
  String level_str = "Level " + Integer.toString(level);
  
  fill(255, 255, 255);
  text(p1_str, -410, -275);
  text(p2_str, 260, -275);
  fill(0, 0, 205);
  textSize(40);
  text(level_str, -75, -215);
  textSize(25);
  
  if (p1_win) {
    fill(0, 255, 0);
    textSize(60);
    text("You Scored!", -175, 0);
    textSize(25);
    delay(1000);
    p1_win = false;
  } else if (p2_win) {
    fill(255, 0, 0);
    textSize(60);
    text("Computer Scored!", -250, 0);
    textSize(25);
    delay(1000);
    p2_win = false;
  } else if (reset) {
    delay(2000);
    reset = false;
  }
  
  if (game_over) {
    if (p1_score == 3) {
      fill(0, 255, 0);
      textSize(60);
      text("You Win!", -150, 0);
      textSize(25);
      noLoop();
    } else if (p2_score == 3) {
      fill(255, 0, 0);
      textSize(60);
      text("You Loose!", -175, 0);
      textSize(25);
      noLoop();
    }
  }
}

void draw_image(PImage i, int x, int y, int w, int h, Boolean isBall) {
  if (y <= CANVAS_HEIGHT && abs(x) <= CANVAS_WIDTH) {
    image(i, x, y, w, h);
    
    // draw hit points
    color c = color(255, 0, 0);  
    fill(c);  
    if (isBall == false) {
      if (x < 0) {
        ellipse(x + 5, y - 20, 10, 10); // paddle 1
      } else {
        ellipse(x - 5, y - 20, 10, 10); // paddle 2
      }
    } else {
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
 
  if (dist_between(paddle_x, paddle_y) <= ACCURACY) {
    if (recieving_paddle == 1 && abs(p1.curr_accel) > ACCEL_HIT) {
      hit = true;
    } else if (recieving_paddle == 2) {
      hit = true;
    }
  }
  
  return hit;
}

float dist_between(int p_x, int p_y) {
  return sqrt(pow(b.curr_x - p_x, 2) + pow(b.curr_y - p_y, 2));
}