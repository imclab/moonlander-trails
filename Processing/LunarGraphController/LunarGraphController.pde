
import processing.serial.*; 
import org.json.*;
//import wsp5.*;


import muthesius.net.*;
import org.webbitserver.*;


int viewWidth = 1920; 
int viewHeight = 1080; 
float viewScale;


boolean fullSizePreview = false; 
PVector renderOffset = new PVector(0, 0); 

//int xPos = 0; 
int lunargraphState = -1; 
String lunargraphStateStrings[] = {
  "WAITING", "ERROR", "RESETTING", "CALIBRATING", "DRAWING"
}; 

int state = 0; 
final int STATE_RUNNING = 0; 
final int STATE_PAUSE_NEXT = 1; 
final int STATE_PAUSED = 2; 
final int STATE_PEN_CHANGE_NEXT = 3; 
final int STATE_PEN_CHANGE = 4; 

//boolean penChanging = false; 

String stateStrings[] = { 
  "RUNNING", "PAUSE_NEXT", "PAUSED", "PEN_CHANGE_NEXT", "PEN_CHANGE"
}; 

PVector homePosition; 

int lastHeartbeat = 0; 
int lastPenChange = 0; 
int penChangeFrequency = 120 * 60 * 1000; 

// reasonable defaults but nothing should happen until they're set by the LunarGraph Arduino
float pageWidth = 10000;  
float pageHeight = 10000;
float stepsPerMil = 20; 
float machineWidth = 14000; 
float pageTop = 3000; 
float pageSideMargin = 0; 

float dataWidth = 895.275 * 1.2; // we wanna see the landscape cycle round 1.2 times.  
//float dataHeight = 500; 
float landscapeWidth; 

ArrayList commands; 
ArrayList landscapePoints; 

ArrayList serialMessages; 
ArrayList webSocketMessages; 

PVector receivePosition; 
PVector sentPosition; 
PVector drawnPosition; 


String switchNames[] = { 
  "jogUpButtonA", 
  "jogDownButtonA", 
  "jogUpButtonB", 
  "jogDownButtonB", 
  "endStopMinButtonA", 
  "endStopMaxButtonA", 
  "endStopMinButtonB", 
  "endStopMaxButtonB", 
  "calibrationButtonA", 
  "calibrationButtonB", 
  "resetButton"
}; 

int jogUpButtonA = 0;
int jogDownButtonA = 1;
int jogUpButtonB = 2;
int jogDownButtonB = 3;
int endStopMinButtonA = 4;
int endStopMaxButtonA = 5;
int endStopMinButtonB = 6;
int endStopMaxButtonB = 7;
int calibrationButtonA =8 ;
int calibrationButtonB= 9;
int resetButtonSwitch = 10;

boolean buttonStates[] = new boolean[11]; 

boolean move = true; 
PFont consoleFont; 
PFont titleFont; 



void setup() { 
  //size(displayWidth, displayHeight);

  viewScale =(float)displayWidth/viewWidth;
  size(round(viewWidth*viewScale), round(viewHeight*viewScale), OPENGL);

  //  if (frame != null) {
  //    frame.setResizable(true);
  //  }

  consoleFont = loadFont("BitstreamVeraSansMono-Bold-12.vlw");
  titleFont = loadFont("FuturaLTPro-Bold-48.vlw");
  frameRate(60);
  commands = new ArrayList();
  receivePosition = new PVector(0, 0); 
  sentPosition = new PVector(0, 0); 
  drawnPosition = new PVector(0, 0); 
  landscapePoints = new ArrayList();  
  serialMessages = new ArrayList(); 
  webSocketMessages = new ArrayList(); 
  initLandscape(); 

  initSerial(); 
  initWebSocket();  
  //frame.setResizable(true);

  //frameRate(10); 

  smooth(); 
  // joining the serial port that is called tty :) 

  initButtons(); 

  background(0); 
  stroke(255);
  
  changePen(); 
}


void mousePressed() { 

  checkButtons(); 
  //socket.sendToAll("sendlandscape");
}
void draw() { 

  if (frameCount - mouseLastMoved>60) noCursor(); 

  background(0); 
  fill(255); 
  blendMode(ADD); 
  pageSideMargin = (machineWidth - pageWidth)/2;

  pushMatrix(); 

  if (fullSizePreview) { 
    float xoffset = map(mouseX, 0, width, 0, width - viewWidth); 
    float yoffset = map(mouseY, 0, height, 0, height - viewHeight); 
    renderOffset.set(round(xoffset), round(yoffset), 0); 
    translate(renderOffset.x, renderOffset.y);
  } 
  else { 
    scale(viewScale);
  }

  textFont(titleFont); 
  textAlign(CENTER, CENTER);
  if (!focused) { 
    text ("PRESS MOUSE TO START", viewWidth/2, 75);
  } 
  else if(state == STATE_PEN_CHANGE) { 
    text ("CHANGE PEN", viewWidth/2, 75);
  }  else  { 
    text ("LUNAR TRAILS", viewWidth/2, 75);
  }  

  textFont(buttonFont); 
  if ((lunargraphState>=0) && (lunargraphState<lunargraphStateStrings.length)) {
    if ((lunargraphStateStrings[lunargraphState] == "WAITING") || (lunargraphStateStrings[lunargraphState]=="DRAWING") || (frameCount%60>20)) {
      if (lunargraphStateStrings[lunargraphState] == "DRAWING") { 
        text("DRAWING CURRENT PLAYER : "+stateStrings[state], viewWidth/2, 145);
      } 
      else if (lunargraphStateStrings[lunargraphState] == "WAITING") {
        text("PLAY THE ARCADE GAME AND YOUR TRAIL WILL BE DRAWN", viewWidth/2, 145);
      } 
      else {
        text(lunargraphStateStrings[lunargraphState], viewWidth/2, 145);
      }
    }
  }
  textFont(consoleFont); 
  textAlign(LEFT, TOP);

  text("STATE:"+stateStrings[state], 60, 40);

  // draw data relative stuff
  stroke(255);
  pushMatrix(); 

  //translate(0,80); 
  scale(viewWidth/dataWidth * pageWidth/machineWidth); 
  translate(map(pageSideMargin, 0, pageWidth, 0, dataWidth), 165);  // not sure about the magic number there... :/ 

  for (float offset = 0; offset<=landscapeWidth; offset+=landscapeWidth) { 
    for (int i = 1; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i-1)); 
      PVector p2 = ((PVector)landscapePoints.get(i));
      p1 = p1.get(); 
      p2 = p2.get(); 
      p1.x+=offset; 
      p2.x+=offset; 
      if (p2.x<dataWidth) {
        line(p1.x, p1.y, p2.x, p2.y);
      } 
      else { 
        PVector v = p2.get(); 
        v.sub(p1); 
        v.mult((dataWidth-p1.x) / v.x); 
        line(p1.x, p1.y, p1.x + v.x, p1.y + v.y);  
        break;
      }
    }
  }
  noFill();
  ellipse(receivePosition.x, receivePosition.y, 6, 6); 
  textAlign(LEFT, CENTER);
  textFont(consoleFont);
  fill(125); 
  translate(receivePosition.x, receivePosition.y); 
  scale(1/ (viewWidth/dataWidth * pageWidth/machineWidth)); 

  text("PLAYER POSITION", 10, 0); 

  popMatrix(); 


  //now draw machine relative stuff
  pushMatrix(); 

  //translate(0,-100); 
  float scalefactor = (float)viewWidth/machineWidth;///1.2;
  translate((machineWidth - pageWidth)/ 2 * scalefactor, (pageTop * scalefactor) - 150); 

  noFill(); 
  stroke(50); 
  rect(0, 0, pageWidth*scalefactor, pageHeight*scalefactor); 

  //scale(scalefactor);  
  //println("scaling : "+((float)viewWidth/pageWidth/1.2)); 
  // strokeWeight(1/scalefactor);

  stroke(50); 
  strokeWeight(4); 
  line(-pageSideMargin*scalefactor, -pageTop*scalefactor, sentPosition.x*scalefactor, sentPosition.y*scalefactor); 
  line(sentPosition.x*scalefactor, sentPosition.y*scalefactor, (pageWidth + pageSideMargin)*scalefactor, -pageTop*scalefactor); 
  stroke(100);
  strokeWeight(2);
  fill(0);
  ellipse(sentPosition.x*scalefactor, sentPosition.y*scalefactor, 20, 20); 

  textAlign(LEFT, CENTER);
  textFont(consoleFont);
  fill(125); 
  stroke(10); 
  text("PEN POSITION", sentPosition.x*scalefactor+30, sentPosition.y*scalefactor); 

  //println(sentPosition.x*scalefactor +" "+sentPosition.y*scalefactor);
  // strokeWeight(1);

  stroke(10, 20, 120);
  for (int i = 0; i< commands.size(); i++) { 
    Command c = (Command) commands.get(i); 
    point(c.p1*scalefactor, c.p2*scalefactor);
  }

  popMatrix();


  renderConsoles();  
  renderButtons(); 

  //  float heartbeatcolour = millis() - lastHeartbeat)
  noStroke();
  fill(255, (1-float(millis() - lastHeartbeat)/10000.0f) * 255, (1-float(millis() - lastHeartbeat)/10000.0f) * 255);
  ellipse(65, 25, 10, 10);  
  textFont(consoleFont); 
  textAlign(LEFT, TOP);
  fill(255); 
  text("LUNARGRAPH HEALTH", 75, 20); 
  
  float penchangemillis = penChangeFrequency - (millis() - lastPenChange); 
 
  if(penchangemillis<=0) { 
    if(state == STATE_RUNNING) { 
      changePen(); 
    }  
    penchangemillis = 0; 
  }
  
   text("PEN CHANGE IN "+floor(penchangemillis/1000/60) + ":"+floor((penchangemillis/1000) % 60), 60,60); 

  
  processQueue();

  popMatrix();
}

void renderConsoles() { 

  textFont(consoleFont); 
  textAlign(LEFT, TOP); 
  while (serialMessages.size ()>70) serialMessages.remove(0); 
  int leading = 14; 

  int textX = 100; 
  int textY =  ((viewHeight- (serialMessages.size()) * leading)) - 50; 



  for (int i = 0; i<serialMessages.size(); i++) { 
    fill(100); 
    if (i==serialMessages.size()-1) fill(255); 

    String msg = (String)serialMessages.get(i); 
    if (msg!=null) text(msg, textX, textY); 
    textY+=leading;
  } 

  while (webSocketMessages.size ()>70) webSocketMessages.remove(0); 
  textX = viewWidth-250; 
  textY =  (viewHeight-(webSocketMessages.size() * leading)) - 50; 


  for (int i = 0; i<webSocketMessages.size(); i++) { 
    fill(100); 
    if (i==webSocketMessages.size()-1) fill(255); 
    String msg = (String)webSocketMessages.get(i); 
    if (msg!=null) text(msg, textX, textY); 
    textY+=leading;
  } 



  // draw end stops 
  drawSwitch(endStopMinButtonA, 40, 20);
  drawSwitch(calibrationButtonA, 40, 40);
  drawSwitch(endStopMaxButtonA, 40, 60);

  drawSwitch(endStopMinButtonB, viewWidth-60, 20);
  drawSwitch(calibrationButtonB, viewWidth-60, 40);
  drawSwitch(endStopMaxButtonB, viewWidth-60, 60);
}


void drawSwitch(int buttonNum, float xpos, float ypos) { 
  //noSmooth(); 
  stroke(255); 
  if (buttonStates[buttonNum]) fill(255); 
  else noFill(); 
  rect(xpos+0.5, ypos+0.5, 10, 10);
  //smooth();
}



/*
PVector convertDataToScreen(PVector p) { 
 
 PVector returnVector = p.get(); 
 returnVector.y-=100; 
 returnVector.mult(viewWidth/dataWidth);  
 return returnVector;
 }*/

PVector convertDataToLunarGraph(PVector p) { 

  PVector returnVector = p.get(); 
  returnVector.y+=100; 
  returnVector.mult(pageWidth/dataWidth);  
  return returnVector;
}

void moveToXYPos(float xpos, float ypos) { 

  commands.add(new Command(COMMAND_MOVE, xpos, ypos));
}
void lineToXYPos(float xpos, float ypos, boolean direct) { 

  commands.add(new Command(direct ? COMMAND_DRAW_DIRECT : COMMAND_DRAW, xpos, ypos));
}
void lineToXYPos(float xpos, float ypos) { 

  lineToXYPos(xpos, ypos, false);
}

void moveToXYPos(PVector pos) { 

  commands.add(new Command(COMMAND_MOVE, pos.x, pos.y));
}
void lineToXYPos(PVector pos, boolean direct) { 

  commands.add(new Command(direct ? COMMAND_DRAW_DIRECT : COMMAND_DRAW, pos.x, pos.y));
}

void lineToXYPos(PVector pos) { 

  lineToXYPos( pos, false);
}

void processQueue() { 

  if ((state == STATE_PAUSED) || (state == STATE_PEN_CHANGE)) return; 

  if ((numToSend>0) && (commands.size()>0)) { 

    Command cmd = (Command) commands.remove(0);
    //float xpos = map(cmd.p1, 0.0f, viewWidth, 0.0f, pageWidth); 
    //float ypos = map(cmd.p2, 0.0f, viewHeight, 0.0f, pageWidth);

    if (cmd.c == COMMAND_FINISH) { 
      if (state == STATE_PAUSE_NEXT) { 
        state = STATE_PAUSED;
      }
      else if (state == STATE_PEN_CHANGE_NEXT) { 
        cmd.c = COMMAND_MOVE; 
        cmd.p1 = pageWidth/2; 
        cmd.p2 = pageHeight*0.8; 
        state = STATE_PEN_CHANGE; 
      }
    } 
    
    if(cmd.c!=COMMAND_FINISH) { 

      float xpos = round(cmd.p1*100)/100.0f; 
      float ypos = round(cmd.p2*100)/100.0f;


      String msg = serialMessageCount+ ","+cmd.c+","+xpos+","+ypos+"\0"; 
      serialMessageCount++; 
      sentPosition.set(xpos, ypos, 0); 
      println("sentPosition : "+ sentPosition); 
      //println("sending "+msg); 
      //serialMessages.add(">"+msg); 
      sendSerial(msg); 

      numToSend =0;
    }
  }
}


boolean beginsWith(String source, String matchString) { 
  return ((source.length()>=matchString.length()) && (source.substring(0, matchString.length()).equals(matchString)));
}

String getStringAfterChar(String source, String chr) { 
  int index = source.indexOf(chr); 
  if (index == -1) return ""; 
  else return source.substring(index+1, source.length());
}


int mouseLastMoved = 0; 

void mouseMoved() { 

  mouseLastMoved = frameCount; 
  cursor();
}

void stop() {
  try { 
    if (socket!=null) {
      println("TRYING SHUT DOWN"); 
      socket.stop();
      println("SHUT DOWN DONE");
    }
  } 
  finally {
    println("SERVER SHUT DOWN ERROR");
  }
  println("DONE");
  if (firstContact) serial.stop();
}

