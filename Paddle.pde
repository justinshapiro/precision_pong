public class Paddle {
  int move_rate;
  Boolean moveToHit;
  int curr_x;
  int curr_y;
  int p_width;
  int p_height;
  PImage img;
  
  Paddle(String init) {
    move_rate = 0;
    moveToHit = false;
    p_width = 90;
    p_height = 140;
    
    if (init.equals("1")) {
      curr_x = -350;
      curr_y = 30;
      img = loadImage("paddle1.png");
    } else if (init.equals("2")) {
      curr_x = 350;
      curr_y = 30;
      img = loadImage("paddle2.png");
    }
  }
  
  public void setMoveRate(ArrayList<Integer> pos_info) {
    int hit_location = pos_info.get(2);
    int time_till = pos_info.get(1);
    
    move_rate = (abs(curr_y) + abs(hit_location)) / time_till;
    
    if (hit_location - curr_y > 0) {
      move_rate = -move_rate;
    }
  }
}