/*
  make the "creature" in the middle bounce
  the "target" variable only changes when inputs from users are received
*/
void bouncing() {
  for(int i = 0;i < cornerLength.length;i++) {
    //expand
    cornerLength[i] += 1.5 * speeds[i];
    if(((targets[i][0] > targets[i][1] && cornerLength[i] > targets[i][0]) || (targets[i][0] < targets[i][1] && cornerLength[i] < targets[i][0])) && (speeds[i] * (targets[i][0] - targets[i][1]) > 0)) {
      speeds[i] *= -1;
    }
    //shrink
    if(speeds[i] * (targets[i][0] - targets[i][1]) < 0) {
      speeds[i] = 1.5 * 0.1 * (targets[i][1] - cornerLength[i]);
    }
  }
}

/*
  when all the songs in the database have been played all over
  they will be reset as "unplayed" to avoid error
*/
void updateSong() {
  int c = 0;
  for(boolean p : played) {
    if(p == false) c++;
  }
  if(c == 0) {
    for(int i = 0;i < fileNames.length;i++) {
      played[i] = false;
    }
  }
}