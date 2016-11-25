import java.util.Random;

public class Ball {
  public int direction;
  public ArrayList<Integer> slope;
  public int curr_x;
  public int curr_y;
  
  public Ball() {
    direction = 0;
    slope = new ArrayList<Integer>(2);
    curr_x = BALL_DEFAULT_POS_X;
    curr_y = BALL_DEFAULT_POS_Y;
  }
  
  public void move() {
    curr_x += slope.get(0);
    curr_y += slope.get(1);
  }
  
  public ArrayList<Integer> getHitPos() {
    int temp_x = curr_x;
    int hit_pos = curr_y;
    int time_till_pos = 0;
    
    while (temp_x < P2_DEFAULT_POS_X) {
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
     int new_slope_rise = 1;
     int new_slope_run = 2;
     
     if (direction > 0) {
       new_slope_run = -new_slope_run;
       direction = -direction;
     }
     
     slope.set(0, new_slope_rise);
     slope.set(1, new_slope_run);
  }
}