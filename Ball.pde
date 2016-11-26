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
  
  public ArrayList<Integer> getHitPos() {
    int temp_x = curr_x;
    int hit_pos = curr_y;
    int time_till_pos = 0;
    
    while (temp_x < 350) {
      temp_x += slope.get(0);
      hit_pos += slope.get(1);
      time_till_pos++;
    }
    
    ArrayList<Integer> pos = new ArrayList<Integer>();
    pos.add(hit_pos);
    pos.add(time_till_pos);
    
    return pos;
  }
  
  public void setSlope() {
     float new_slope_rise = -1;
     float new_slope_run = 1;
     
     if (direction > 0) {
       new_slope_run = -new_slope_run;
       direction = -direction;
     }
     
     slope.set(0, new_slope_rise);
     slope.set(1, new_slope_run);
  }
}