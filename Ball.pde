import java.util.Random;

public class Ball {
  public int direction;
  public ArrayList<Float> slope;
  public int curr_x;
  public int curr_y;
  public int dim;
  public PImage img;
  
  public Ball() {
    direction = 1;
    slope = new ArrayList<Float>();
    slope.add(0, 0.0);
    slope.add(1, 0.0);
    curr_x = 345;
    curr_y = 8;
    dim = 25;
    img = loadImage("ball.png");
  }
  
  public void move() {
    curr_x += slope.get(0);
    curr_y += slope.get(1);
  }
  
  public int getHitPos() {
    int temp_x = curr_x;
    int hit_pos = curr_y;
    
    while (temp_x <= 350) {
      temp_x += slope.get(0);
      hit_pos += slope.get(1);
    }
    
    return hit_pos;
  }
  
  public void setSlope() {
     Random r = new Random();
     float new_slope_rise = r.nextInt((1 - (-1)) + 1) + (-1); // -1 - 1
     float new_slope_run = r.nextInt((10 - 4) + 1) + 4;  // 4 - 10
     
     if (direction > 0) {
       new_slope_run = -new_slope_run;
       direction = -direction;
     } else {
       direction = -direction;
     }
     
     if (abs(p1.curr_y) > 150 || abs(p2.curr_y) > 150) {
       new_slope_rise = -new_slope_rise;
     }
     
     slope.set(0, new_slope_run);
     slope.set(1, new_slope_rise);
  }
}