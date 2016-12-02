import processing.serial.*;
import processing.sound.*;
import java.lang.Math;
import java.util.Random;

// Define serial reader
Serial port;

// Define image objects
PImage table;
PImage harambe;

// Set default dimensions
int CANVAS_WIDTH = 888;
int CANVAS_HEIGHT = 603;

// Define game objects
Ball b;
Paddle p1;
Paddle p2;

// Define hit and accuracy variables
int ACCURACY = 40;
int SMOOTH_FACTOR = 10;
int ACCEL_X_HIT = 8000;
int ACCEL_Y_HIT = 20000;
Boolean hit;

// Gameplay variables
int recieving_paddle = 2;
int p1_score;
int p2_score;
int winning_score = 1;
int level;
int num_levels = 10;
int center = 153;
Boolean p1_win;
Boolean p2_win;
Boolean reset;
Boolean game_start;
Boolean game_over;
Boolean started;
String start_str = "Swing UP or DOWN to Start!";
String started_str = "Good Luck!";
String score_str= "You Scored!";
String loss_str = "Computer Scored!";
String win_str = "You WIN!";
String loose_str = "You LOOSE!";
String game_over_str = "GAME OVER!";

// Used for calculation of sample rate
long last_time = System.nanoTime();
int samples = 0;
Boolean sample_calculated = false;

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
  
  // Sound file requires full path
  p1.hit_sound = new SoundFile(this, "/Users/justinshapiro/Desktop/precision_pong/p1_hit.mp3");
  p2.hit_sound = new SoundFile(this, "/Users/justinshapiro/Desktop/precision_pong/p2_hit.mp3");

  hit = false;
  
  level = 0;
  p1_score = 0;
  p2_score = 0;
  p1_win = false;
  p2_win = false;
  reset = false;
  game_start = false;
  started = false;
  game_over = false;
 
  // assign image objects an actual image
  table = loadImage("ping_pong_bg.jpg");
  
  draw_canvas();
}

// Used to control the computer's paddle and draw the GUI
void draw() {   
  if (game_start && !game_over) {
    if (started) {
      delay(2000);
      started = false;
    }
    
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
    } else if (recieving_paddle == 2) {
        if (b.curr_x > p2.curr_x + 100) {
          p1_score++;
          p1_win = true;
          reset();
        } else {
            p2.move();
        }
    }

  } else if (!game_start) {
    if (abs(p1.curr_accel_y) > ACCEL_Y_HIT) {
      started = true;
      p1.curr_accel_y = 0;
    }
  }
  
  // Update the gameboard
  draw_canvas();
  
  // Stop game if there is a winning score, otherwise move ball
  if (p1_score == winning_score * (level + 1)) {
    if (num_levels > level) {
      level++;
    } else {
      game_over = true;
    }
    reset();
  } else {
    b.move();
  }
}

// Used to control the user's paddle
void serialEvent(Serial port) {
  try {
    int dist = getData(port.readString());
    if (dist > -1) {
      getSampleRate();
      println(Integer.toString(dist) + "mm");
      int new_dist = pix_map(dist);
      if (abs(new_dist - p1.curr_y) > 2*SMOOTH_FACTOR + (level * 2))
        p1.curr_y = new_dist;
    }
  } catch (RuntimeException e) { /* do nothing */ }
}

// Parses serial data strings into distance, x-acceleration and 
// y-acceleration data; stores the in object variables
int getData(String data) {
    if (data != null) {
      String dist_str, accel_x_str, accel_y_str = "";
      int dist = 0;
      int sensor_split_idx = data.indexOf('*');
      int accel_split_idx = data.indexOf('&');
      dist_str = data.substring(0, sensor_split_idx);
      accel_x_str = data.substring(sensor_split_idx + 1, accel_split_idx);
      
      if (!game_start) {
        accel_y_str = data.substring(accel_split_idx + 1, data.length() - 1);
      }
      
      try {
        dist = Integer.parseInt(dist_str.trim());
        p1.curr_accel_x = Integer.parseInt(accel_x_str.trim());
        
        if (!game_start) {
          p1.curr_accel_y = Integer.parseInt(accel_y_str.trim());
        }
      } catch (NumberFormatException e) { /* do nothing */ }
      
      if (dist > 0)
        return dist;
      else 
        return -1;
    } 
    else 
      return -1;
}

// Determines if the paddle has hit the ball by considering the ball's distance 
// from the paddle and the x-acceleration (paddle 1 only)
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
    if (recieving_paddle == 1 && abs(p1.curr_accel_x) > ACCEL_X_HIT) {
      hit = true;
      p1.hit_sound.play();
    } else if (recieving_paddle == 2) {
      hit = true;
      p2.hit_sound.play();
    }
  }
  
  return hit;
}

// Helper method to isHit()
// Applies the distance formula to two coordinate points (paddle and ball)
float dist_between(int p_x, int p_y) {
  return sqrt(pow(b.curr_x - p_x, 2) + pow(b.curr_y - p_y, 2));
}

// Algorithm for mapping distance (mm) to pixels for each level
int pix_map(int dist) {
  int max_dist = (CANVAS_HEIGHT - 30) / 2;
  int return_dist = (level + 2) * dist - (max_dist - (level * 2));

  if (return_dist > max_dist)
    return_dist = max_dist;
  else if (return_dist < -max_dist) {
    return_dist = -max_dist;
  }

  return return_dist;
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

// Prints the current sample rate to the command line
void getSampleRate() {
  samples++;
  if (System.nanoTime() - last_time >= 1000000000) {
    println("Sample Rate: " + Integer.toString(samples) + " samples per second");
    samples = 0;
    last_time = System.nanoTime();
  } 
}

// Redraws the canvas to reflect the state changes any variables may of had
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
  
  if (game_start) {
    textSize(40);
    fill(0, 0, 205);
    text(level_str, -75, -215);
    textSize(25);
  } else {
    if (!started) {
      textSize(60);
      fill(255, 255, 255);
      text(start_str, -400, 30);
      textSize(25);
    }
  }
  
  if (started) {
    fill(255, 255, 255);
    textSize(80);
    if (!game_start) {
      text(started_str, -200, 30);
      game_start = true;
    }
  }
  
  if (p1_win) {
    fill(0, 255, 0);
    textSize(60);
    text(score_str, -175, 0);
    textSize(25);
    delay(1000);
    p1_win = false;
  } else if (p2_win) {
      fill(255, 0, 0);
      textSize(60);
      text(loss_str, -250, 0);
      textSize(25);
      delay(1000);
      p2_win = false;
  } else if (reset) {
      delay(2000);
      reset = false;
  }
  
  if (game_over) {
    harambe = loadImage("harambe.png");
    image(harambe, 0, 30, 500, 500);
    
    if (p1_score == 3) {
      fill(0, 255, 0);
      textSize(30);
      text(win_str, -100, 100);
      textSize(60);
      text(game_over_str, -150, 0);
      textSize(25);
      noLoop();
    } else if (p2_score == 3) {
      fill(255, 0, 0);
      textSize(30);
      text(loose_str, -100, 100);
      textSize(60);
      text(game_over_str, -150, 0);
      textSize(25);
      noLoop();
    }
  }
}

// Draws PNG images to the canvas
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