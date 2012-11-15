import processing.opengl.*;


import processing.serial.*; 
import org.json.*;
import wsp5.*;


int viewWidth = 1920; 
int viewHeight = 1080; 
float viewScale = 1;


boolean fullSizePreview = false; 
PVector renderOffset = new PVector(0,0); 

//int xPos = 0; 
int lunargraphState = -1; 
String stateStrings[] = {
  "WAITING", "ERROR", "RESETTING", "CALIBRATING", "DRAWING"
}; 


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

  size(round(viewWidth*viewScale), round(viewHeight*viewScale));

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
}


void mousePressed() { 

  checkButtons(); 
  //socket.sendToAll("sendlandscape");
}
void draw() { 


  background(0); 

  blendMode(ADD); 
 pageSideMargin = (machineWidth - pageWidth)/2;

  pushMatrix(); 
  
  if(fullSizePreview) { 
    float xoffset = map(mouseX, 0, width, 0, width - viewWidth); 
    float yoffset = map(mouseY, 0, height, 0, height - viewHeight); 
    renderOffset.set(round(xoffset), round(yoffset), 0); 
    translate(renderOffset.x, renderOffset.y); 
    
  } else { 
    scale(viewScale); 
  }
  
  textFont(titleFont); 
  textAlign(CENTER, CENTER);
  text ("LUNARGRAPH CONTROLLER", viewWidth/2, 75);  
   
  
  textFont(buttonFont); 
  if ((lunargraphState>=0) && (lunargraphState<stateStrings.length)) {
    if((stateStrings[lunargraphState] == "WAITING") || (stateStrings[lunargraphState]=="DRAWING") || (frameCount%60>20)) {
      text(stateStrings[lunargraphState], viewWidth/2, 135); 
    } 
  }

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
      if(p2.x<dataWidth) {
        line(p1.x, p1.y, p2.x, p2.y);
      } else { 
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
  popMatrix(); 


  //now draw machine relative stuff
  pushMatrix(); 

  //translate(0,-100); 
  float scalefactor = (float)viewWidth/machineWidth;///1.2;
  translate((machineWidth - pageWidth)/ 2 * scalefactor , (pageTop * scalefactor) - 150); 
  
  noFill(); 
  stroke(50); 
  rect(0,0,pageWidth*scalefactor, pageHeight*scalefactor); 
  
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
  
  //println(sentPosition.x*scalefactor +" "+sentPosition.y*scalefactor);
  // strokeWeight(1);

  stroke(10,20,120);
  for (int i = 0; i< commands.size(); i++) { 
    Command c = (Command) commands.get(i); 
    point(c.p1*scalefactor, c.p2*scalefactor);
  }

  popMatrix();


  renderConsoles();  
  renderButtons(); 

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

  commands.add(new Command(0, xpos, ypos));
}
void lineToXYPos(float xpos, float ypos, boolean direct) { 

  commands.add(new Command(direct ? 2 : 1, xpos, ypos));
}
void lineToXYPos(float xpos, float ypos) { 

  lineToXYPos(xpos, ypos, false); 
}

void moveToXYPos(PVector pos) { 

  commands.add(new Command(0, pos.x, pos.y));
}
void lineToXYPos(PVector pos, boolean direct) { 

  commands.add(new Command(direct ? 2 : 1, pos.x, pos.y));
}

void lineToXYPos(PVector pos) { 

  lineToXYPos( pos, false);
}

void processQueue() { 

  if ((numToSend>0) && (commands.size()>0)) { 

    Command cmd = (Command) commands.remove(0);
    //float xpos = map(cmd.p1, 0.0f, viewWidth, 0.0f, pageWidth); 
    //float ypos = map(cmd.p2, 0.0f, viewHeight, 0.0f, pageWidth);
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


boolean beginsWith(String source, String matchString) { 
  return ((source.length()>=matchString.length()) && (source.substring(0, matchString.length()).equals(matchString)));
}

String getStringAfterChar(String source, String chr) { 
  int index = source.indexOf(chr); 
  if (index == -1) return ""; 
  else return source.substring(index+1, source.length());
}




void stop() {
  try { 
    if (socket!=null) 
      socket.stop();
  } 
  catch (IOException e) {
  } 
  finally {
  }

  if (firstContact) serial.stop();
}

