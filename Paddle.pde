public class Paddle {
  int curr_x;
  int curr_y;
  int p_width;
  int p_height;
  PImage img;
  
  Paddle(String init) {
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
  
  public void setHitPos(int hit_pos) {
    curr_y = hit_pos;
  }
}