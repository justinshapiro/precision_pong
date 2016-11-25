public class Paddle {
  int move_rate;
  Boolean moveToHit;
  
  Paddle() {
    move_rate = 0;
    moveToHit = false;
  }
  
  public void setMoveRate(ArrayList<Integer> pos_info) {
    int hit_location = pos_info.get(2);
    int time_till = pos_info.get(1);
    
    move_rate = (abs(P2_CURRENT_DIST) + abs(hit_location)) / time_till;
    
    if (hit_location - P2_CURRENT_DIST > 0) {
      move_rate = -move_rate;
    }
  }
}