/*
  draw the buttons;
  set buttons' appearance and positions when certain inputs are received
*/
void buttons() {
  for(int i = 0;i < 4;i++) {
    PVector pos;
    if(i <= 1) {
      pos = new PVector(width/2 - 250 + i * 500/4, height/2 + 330);
    }else{
      pos = new PVector(width / 2 - 250 + (i + 1) * 500 / 4, height / 2 + 330);
    }
    stroke(255);
    if(buttonStatus[i] == 0){
      if(dist(mouseX, mouseY, pos.x, pos.y) < 22){
        fill(100);
      }else{
        fill(20);
      }  
    }else if(buttonStatus[i] == 1){
      fill(175);
    }
    ellipse(pos.x, pos.y, 35, 35);
    icons[i].disableStyle();
    noFill();
    stroke(255);
    shapeMode(CENTER);
    shape(icons[i], pos.x, pos.y, 30, 30);
  }
  //speed adjusting button
  PVector pos = new PVector(width / 2, height / 2 + 330);
  if(mousePressed) {
    if(!adjustSpeed && dist(mouseX, mouseY, width / 2, pos.y - 55 / 2 + weizhi) < 5) {
      adjustSpeed = true;
    }
  }else {
    adjustSpeed = false;
  }
  if(adjustSpeed) {
    weizhi = mouseY - (pos.y - 55 / 2);
    if(weizhi < 12) weizhi = 12;
    else if(weizhi > 50) weizhi = 50;
  }
  if(dist(mouseX, mouseY, width / 2, pos.y - 55 / 2 + weizhi) < 5) {
    onSpeed = true;
  }else{
    onSpeed = false;
  }
  rectMode(CENTER);
  fill(120, 255, 90);
  noStroke();
  rect(pos.x, pos.y, 28, 48, 30);
  {
    //
    rectMode(CORNER);
    noStroke();
    fill(0);
    rect(pos.x - 34 / 2, pos.y - 55 / 2 + 2, 35, weizhi);
    //
    if(onSpeed || adjustSpeed) fill(50);
    else fill(30);
    rect(pos.x - 34 / 2, pos.y - 55 / 2, 35, weizhi);
    //
  }
  //
  //
  rectMode(CENTER);
  noFill();
  strokeWeight(15);
  stroke(0);
  rect(pos.x, pos.y, 40, 60, 30);
  //
  strokeWeight(2);
  stroke(255);
  rect(pos.x, pos.y, 30, 50, 30);
  //
  noStroke();
  fill(0);
  ellipse(pos.x, pos.y - 55 / 2 + weizhi - 3, 12, 12);
  if(onSpeed || adjustSpeed) fill(255);
  else fill(150);
  ellipse(pos.x, pos.y - 55 / 2 + weizhi - 3, 10, 10);
  //* end of speed adjusting button
}

void mouseReleased() {
  println(weizhi);
  if(adjustSpeed) {
    /*
      set a new target speed of moving for the "creature",
      according to the position of the toggle;
    */
    float s = map(weizhi, 12, 50, 0.2, 0.05);
    for(int i = 0;i < targetSpeed.length;i++) {
      if(weizhi == 50) {
        targetSpeed[i] = 0;
      }else{
        targetSpeed[i] = random(s - 0.01, s + 0.01);
      }
    }
  }
  //write down the time of operation to a csv file
  if(recordLearn) {
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("adjust ends," + m + ":" + s);
    recordLearn = false;
  }
}

void mousePressed() {
  //change buttons' status when clicking
  for(int i = 0;i < 4;i++) {
    PVector pos;
    if(i <= 1) {
      pos = new PVector(width/2 - 250 + i * 500/4, height/2 + 330);
    }else{
      pos = new PVector(width / 2 - 250 + (i + 1) * 500 / 4, height / 2 + 330);
    }
    if(dist(mouseX, mouseY, pos.x, pos.y) < 22) {
      buttonStatus[i] = 1 - buttonStatus[i];
      if(i <= 1 && buttonStatus[i] == 1) {
        buttonStatus[3] = 0;
      }else if(i == 3 && buttonStatus[3] == 1) {
        buttonStatus[0] = 0;
        buttonStatus[1] = 0;
      }else if(i == 2 && buttonStatus[2] == 1) {
        buttonStatus[0] = 0;
        buttonStatus[1] = 0;
        buttonStatus[3] = 0;
      }
    }
  }
  /*
    change the "target" positions of the "horns" of the "creature";
    firstly check which "horns" are supposed to be changed,
    according to the status of the tags of the song being played;
    then check what operation is being done,
    and set the target distance accordingly;
  */
  for(int i = 0;i < 6;i++) {
    if(tagStatus[i] > 0) {
      //weight of "learning speed" depending on the position of the toggle
      float coef = map(weizhi, 12, 50, 1.2, 0);
      //"loop"
      if(dist(mouseX, mouseY, width/2 - 250, height/2 + 330) < 22) {
        targets[i][1] = cornerLength[i] + coef * (2 * buttonStatus[0] - 1) * 10.0 * tagStatus[i] / 2.0;
        targets[i][0] = cornerLength[i] + coef * (2 * buttonStatus[0] - 1) * 10.0 * 4 * tagStatus[i] / 2.0;
        if(targets[i][0] != cornerLength[i]) speeds[i] = 1.5 * 2.1 * (targets[i][0] - cornerLength[i]) / abs(targets[i][0] - cornerLength[i]);
      }
      //"like"
      if(dist(mouseX, mouseY, width/2 - 250 + 500/4, height/2 + 330) < 22) {
        targets[i][1] = cornerLength[i] + coef * (2 * buttonStatus[1] - 1) * 7.0 * tagStatus[i] / 2.0;
        targets[i][0] = cornerLength[i] + coef * (2 * buttonStatus[1] - 1) * 7.0 * 4 * tagStatus[i] / 2.0;
        if(targets[i][0] != cornerLength[i]) speeds[i] = 1.5 * 2.1 * (targets[i][0] - cornerLength[i]) / abs(targets[i][0] - cornerLength[i]);
      }
      //"skip"
      if(dist(mouseX, mouseY, width/2 - 250 + 3 * 500/4, height/2 + 330) < 22) {
        targets[i][1] = cornerLength[i] - coef * skipWeight * 3 * tagStatus[i] / 2.0;
        targets[i][0] = cornerLength[i] - coef * skipWeight * 3 * 4 * tagStatus[i] / 2.0;
        if(targets[i][0] != cornerLength[i]) speeds[i] = 1.5 * 2.1 * (targets[i][0] - cornerLength[i]) / abs(targets[i][0] - cornerLength[i]);
      }
      //"dislike"
      if(dist(mouseX, mouseY, width/2 - 250 + 4 * 500/4, height/2 + 330) < 22) {
        targets[i][1] = cornerLength[i] + coef * (1 - 2 * buttonStatus[3]) * 7.0 * tagStatus[i] / 2.0;
        targets[i][0] = cornerLength[i] + coef * (1 - 2 * buttonStatus[3]) * 7.0 * 4 * tagStatus[i] / 2.0;
        if(targets[i][0] != cornerLength[i]) speeds[i] = 1.5 * 2.1 * (targets[i][0] - cornerLength[i]) / abs(targets[i][0] - cornerLength[i]);
      }
    }
  }
  /*
    latent factor model:
    when clicking "skip", calculate the scores of all the songs in the database,
    then set the highest-score one to be played next;
  */
  if(dist(mouseX, mouseY, width/2 - 250 + 3 * 500/4, height/2 + 330) < 22) {
    start = true;
    loop = false;
    buttonStatus[2] = 1 - buttonStatus[2];
    //calculate the factors
    for(int i = 0;i < factors.length;i++) {
      float factor = 0;
      for(int j = 0;j < 6;j++) {
        //calculate the score
        factor += tagValues[i][j] * targets[j][1];
      }
      factors[i] = factor;
    }
    //get the largest factor and play
    for(int i = 1;i < factorsOrder.length;i++) {
      for(int j = 0;j < factorsOrder.length - i;j++) {
        if(factors[factorsOrder[j]] < factors[factorsOrder[j + 1]]) {
          int temp = factorsOrder[j];
          factorsOrder[j] = factorsOrder[j + 1];
          factorsOrder[j + 1] = temp;
        }
      }
    }
    int sel = 0;
    while(played[factorsOrder[sel]]) {
      sel++;
    }
    song.pause();
    song = minim.loadFile(fileNames[factorsOrder[sel]]);
    song.play();
    beginTime = millis();
    played[factorsOrder[sel]] = true;
  }
  //record operations' kinds and the time
  //loop
  if(dist(mouseX, mouseY, width / 2 - 250, height / 2 + 330) < 22) {
    loop = !loop;
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("loop" + "," + m + ":" + s);
  }
  //like
  if(dist(mouseX, mouseY, width / 2 - 250 + 500 / 4, height / 2 + 330) < 22) {
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("like" + "," + m + ":" + s);
  }
  //adjust speed
  if(dist(mouseX, mouseY, width / 2, height / 2 + 330 - 55 / 2 + weizhi) < 5) {
    recordLearn = true;
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("adjust starts," + m + ":" + s);
  }
  //skip
  if(dist(mouseX, mouseY, width / 2 - 250 + 3 * 500 / 4, height / 2 + 330) < 22) {
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    meta = song.getMetaData();
    String n = meta.title();
    String nam = meta.fileName();
    String[] nams = splitTokens(nam, "_.");
    String[] tags = new String[6];
    for(int i = 0;i < tags.length;i++) {
      tags[i] = nams[1].substring(i, i + 1);
    }
    String t = join(tags, ",");
    write.println("skip," + m + ":" + s + "," + t + "," + n);
  }
  //dislike
  if(dist(mouseX, mouseY, width / 2 - 250 + 4 * 500 / 4, height / 2 + 330) < 22) {
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("dislike," + m + ":" + s);
  }
  //adjusting learning

  //end record
}

/*
  at the end of the experiment,
  flush all the data to the csv file and stop the program;
*/
void keyPressed() {
  if(keyCode == ESC) {
    minute = (millis() / 1000) / 60;
    second = millis() / 1000 - minute * 60;
    String m = nf(minute, 2);
    String s = nf(second, 2);
    write.println("end," + m + ":" + s);
    write.flush();
    write.close();
  }
}