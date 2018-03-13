/*
  set if the "creature" will show up or not;
  adjust the moving speed of the "creature" to the "target speed";
*/
void learningSpeed() {
  if(weizhi == 50) transparency -= 0.1;
  else transparency += 0.1;
  if(transparency < 0) transparency = 0;
  else if(transparency > 1) transparency = 1;
  //moving speed
  for(int i = 0;i < animationSpeed.length;i++) {
    float d = targetSpeed[i] - animationSpeed[i];
    animationSpeed[i] += 0.3 * d;
  }
}