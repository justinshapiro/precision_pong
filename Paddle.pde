public class Paddle {
  public int curr_x;
  public int curr_y;
  public int curr_accel_x;
  public int curr_accel_y;
  private int goto_y;
  public int p_width;
  public int p_height;
  public PImage img;
  public SoundFile hit_sound;
  
  public Paddle(String init) {
    p_width = 90;
    p_height = 140;
    curr_accel_x = 0;
    curr_accel_y = 0;
    
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
    goto_y = hit_pos;
  }
  
  public void move() {
    if (curr_y != goto_y) {
      if (goto_y < curr_y) {
        curr_y--;
      } else {
        curr_y++;
      }
    }
  }
}