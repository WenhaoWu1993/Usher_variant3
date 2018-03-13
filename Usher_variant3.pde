 import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
//save process
PrintWriter write;
int minute, second;
//
Creature creature;

PShape[] icons = new PShape[4];

PShape speedIcon;

float[] cornerLength = new float[6];
float[] animationDistance = new float[6];
float[] targetSpeed = new float[6];
float[] animationSpeed = new float[6];
//int[] lengthOrder = {0, 1, 2, 3, 4, 5};

float[][] targets = new float[6][2];
float[] speeds = new float[6];

int[] buttonStatus = new int[4];
int[] buttonCounter = new int[4];

int[] tagStatus = new int[6];
float[] tagSize = new float[6];

File file;
File[] fileList;
String[] fileNames = new String[0];

boolean[] played;

boolean start = false;
boolean loop = false;
String playingName;

Minim minim;
AudioPlayer song;
AudioMetaData meta;
int beginTime;
float skipWeight = 0;

float barWidth, barYpos;

float[] factors;
int[][] tagValues;
int[] factorsOrder;

float weizhi;
boolean onSpeed = false;
boolean adjustSpeed = false;
boolean recordLearn = false;
float transparency;

void setup() {
  fullScreen();
  pixelDensity(2);
  //initiate the recording
  String head = "participant5_test3";
  write = createWriter(head + ".csv");
  write.println(head);
  write.println("button," + "time," + "relaxing," + "ambient," + "stimulating," + "energetic," + "rhythmic," + "trendy," + "song");
  //
  //initiate creature status
  for(int i =0;i < 6;i++) {
    cornerLength[i] = 60;
    animationDistance[i] = random(5,7);
    targetSpeed[i] = random(0.06,0.12);
    animationSpeed[i] = targetSpeed[i];
    //set tagStatus
    tagStatus[i] = 0;
  }  
  creature = new Creature(cornerLength, animationDistance, animationSpeed, width/2,height/2-40);
  //initiate button status
  for(int i = 0;i < 4;i++) {
    buttonStatus[i] = 0;
    buttonCounter[i] = 0;
  }
  //load icons
  icons[0] = loadShape("loop.svg");
  icons[1] = loadShape("like.svg");
  icons[2] = loadShape("skip.svg");
  icons[3] = loadShape("dislike.svg");
  speedIcon = loadShape("learn.svg");
  //get the names for all the music files and save them as an array
  file = new File(sketchPath() + File.separator + "data");
  fileList = file.listFiles();
  for(File f : fileList) {
    String n = f.getName();
    if(n.indexOf(".mp3") != -1) {
      fileNames = append(fileNames, n);
    }
  }
  played = new boolean[fileNames.length];
  //read each song's scores on six tags and save them to a two-dimensional array
  factors = new float[fileNames.length];
  factorsOrder = new int[fileNames.length];
  tagValues = new int[fileNames.length][6];
  for(int i = 0;i < fileNames.length;i++) {
    String[] nam = splitTokens(fileNames[i], "_.");
    factorsOrder[i] = i;
    for(int j = 0;j < 6;j++) {
      tagValues[i][j] = int(nam[1].substring(j, j + 1));
    }
  }
  //
  /*
    set all the songs' status to "unplayed"
    "played" songs won't be played again in one loop
  */
  for(int i = 0;i < played.length;i++) {
    played[i] = false;
  }
  minim = new Minim(this);
  song = minim.loadFile(fileNames[0]);
  
  barWidth = 600.0;
  barYpos = height - 190;
  beginTime = 0;
  
  weizhi = 50;
  if(weizhi == 50) transparency = 0;
  else transparency = 1;
}

void draw() {
  background(0);
  updateSong();
  backGround();
  learningSpeed();
  creature.drawFinal();
  buttons();
  setTagSize();
  //"progress bar" of the song being played
  noStroke();
  fill(50);
  rectMode(CORNER);
  rect(width / 2 - barWidth / 2, barYpos, barWidth, 5);
  //automatically play next song
  if(!song.isPlaying() && start) {
    if(loop == true) {
      song = minim.loadFile(playingName);
      song.play();
      beginTime = millis();
    }else{
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
  }
  setTagStatus();
  bouncing();
}

/*
  following three functions are for:
  1. getting the playing song's scores on six tags
  2. set the sizes (of the circles) for each song depending their scores on six tags
*/
void setTagStatus() {
  if(song.isPlaying()) {
    meta = song.getMetaData();
    String n = meta.fileName();
    playingName = n;
    String[] l = splitTokens(n, "_.");
    for(int i = 0;i < tagStatus.length;i++) {
      String s = l[1].substring(i, i + 1);
      tagStatus[i] = int(s);
    }
    fill(255);
    textAlign(CENTER, TOP);
    textSize(14);
    text(meta.title() + " - " + meta.author(), width / 2, barYpos + 17);
    noStroke();
    fill(120, 255, 90);
    rect(width / 2 - barWidth / 2, barYpos, map(int((millis() - beginTime) / 1000), 0, int(meta.length() / 1000), 0, int(barWidth)), 5);
    //set the "weight" of "skip" depending on how long a song has been played
    skipWeight = map(millis() - beginTime, 0, meta.length(), 1.0, 0);
  }
}

float tagSize(int tag) {
  float size;
  size = tagStatus[tag] * 15;
  return size;
}

void setTagSize() {
  for(int i = 0;i < 6;i++) {
    float d = tagSize(i) - tagSize[i];
    tagSize[i] += 0.2 * d;
    fill(200);
    noStroke();
    pushMatrix();
    translate(width/2, height/2-40);
    ellipse(230 * sin(i * PI/3), 230 * cos(i * PI/3), tagSize[i], tagSize[i]);
    popMatrix();
  }
}

void backGround() {
  //strokes
  for(int i = 0;i < 3;i++) {
    pushMatrix();
    translate(width/2,height/2-40);
    stroke(30);
    strokeWeight(1);
    line(230 * sin(i * PI/3), 230 * cos(i * PI/3), 230 * sin(i * PI/3 + PI), 230 * cos(i * PI/3 + PI));
    popMatrix();
  }
  //inner polygon
  pushMatrix();
  translate(width/2,height/2-40);
  noFill();
  stroke(50);
  beginShape();
  for(int i = 0;i < 6;i++) {
   vertex(230 * sin(i * PI/3), 230 * cos(i * PI/3));
  }
  endShape(CLOSE);
  popMatrix();
  //outer circle
  noFill();
  stroke(255);
  ellipse(width/2,height/2-40,460,460);
  //text
  //0
  textAlign(CENTER, TOP);
  pushMatrix();
  translate(width/2, height/2 - 40);
  fill(255);
  textSize(12);
  text("relaxing", 0, 260);
  popMatrix();
  //1
  textAlign(CENTER, TOP);
  pushMatrix();
  translate(width/2, height/2 - 40);
  fill(255);
  rotate(-PI/3);
  text("ambient", 0, 260);
  popMatrix();
  //2
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(width/2, height/2 - 40);
  fill(255);
  rotate(PI/3);
  text("stimulating", 0, -260);
  popMatrix();
  //3
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(width/2, height/2 - 40);
  fill(255);
  text("energetic", 0, -260);
  popMatrix(); 
  //4
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(width/2, height/2 - 40);
  rotate(-PI/3);
  fill(255);
  text("rhythmic", 0, -260);
  popMatrix(); 
  //5
  textAlign(CENTER, TOP);
  pushMatrix();
  translate(width/2, height/2 - 40);
  rotate(PI/3);
  fill(255);
  text("trendy", 0, 260);
  popMatrix();   
}