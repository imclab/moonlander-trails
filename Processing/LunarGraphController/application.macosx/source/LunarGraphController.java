import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import processing.serial.*; 
import org.json.*; 
import muthesius.net.*; 
import org.webbitserver.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class LunarGraphController extends PApplet {


 

//import wsp5.*;






int viewWidth = 1920; 
int viewHeight = 1080; 
float viewScale =0.6f;


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
String stateStrings[] = { 
  "RUNNING", "PAUSE_NEXT", "PAUSED"
}; 

PVector homePosition = new PVector(); 


// reasonable defaults but nothing should happen until they're set by the LunarGraph Arduino
float pageWidth = 10000;  
float pageHeight = 10000;
float stepsPerMil = 20; 
float machineWidth = 14000; 
float pageTop = 3000; 
float pageSideMargin = 0; 

float dataWidth = 895.275f * 1.2f; // we wanna see the landscape cycle round 1.2 times.  
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

public void setup() { 
  //size(displayWidth, displayHeight);
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
}


public void mousePressed() { 

  checkButtons(); 
  //socket.sendToAll("sendlandscape");
}
public void draw() { 


  background(0); 

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
  else { 
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

  text(stateStrings[state], 100, 20);

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

  processQueue();

  popMatrix();
}

public void renderConsoles() { 

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


public void drawSwitch(int buttonNum, float xpos, float ypos) { 
  //noSmooth(); 
  stroke(255); 
  if (buttonStates[buttonNum]) fill(255); 
  else noFill(); 
  rect(xpos+0.5f, ypos+0.5f, 10, 10);
  //smooth();
}



/*
PVector convertDataToScreen(PVector p) { 
 
 PVector returnVector = p.get(); 
 returnVector.y-=100; 
 returnVector.mult(viewWidth/dataWidth);  
 return returnVector;
 }*/

public PVector convertDataToLunarGraph(PVector p) { 

  PVector returnVector = p.get(); 
  returnVector.y+=100; 
  returnVector.mult(pageWidth/dataWidth);  
  return returnVector;
}

public void moveToXYPos(float xpos, float ypos) { 

  commands.add(new Command(COMMAND_MOVE, xpos, ypos));
}
public void lineToXYPos(float xpos, float ypos, boolean direct) { 

  commands.add(new Command(direct ? COMMAND_DRAW_DIRECT : COMMAND_DRAW, xpos, ypos));
}
public void lineToXYPos(float xpos, float ypos) { 

  lineToXYPos(xpos, ypos, false);
}

public void moveToXYPos(PVector pos) { 

  commands.add(new Command(COMMAND_MOVE, pos.x, pos.y));
}
public void lineToXYPos(PVector pos, boolean direct) { 

  commands.add(new Command(direct ? COMMAND_DRAW_DIRECT : COMMAND_DRAW, pos.x, pos.y));
}

public void lineToXYPos(PVector pos) { 

  lineToXYPos( pos, false);
}

public void processQueue() { 

  if (state == STATE_PAUSED) return; 

  if ((numToSend>0) && (commands.size()>0)) { 

    Command cmd = (Command) commands.remove(0);
    //float xpos = map(cmd.p1, 0.0f, viewWidth, 0.0f, pageWidth); 
    //float ypos = map(cmd.p2, 0.0f, viewHeight, 0.0f, pageWidth);

    if (cmd.c == COMMAND_RESTART) { 
      if (state == STATE_PAUSE_NEXT) { 
        state = STATE_PAUSED;
      }
    } 
    else { 

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


public boolean beginsWith(String source, String matchString) { 
  return ((source.length()>=matchString.length()) && (source.substring(0, matchString.length()).equals(matchString)));
}

public String getStringAfterChar(String source, String chr) { 
  int index = source.indexOf(chr); 
  if (index == -1) return ""; 
  else return source.substring(index+1, source.length());
}




public void stop() {
  try { 
    if (socket!=null) 
      socket.stop();
  } 
 // catch(IOException e) {}  
  finally {
  }

  if (firstContact) serial.stop();
}

int numButtons = 5; 
Button buttons[] = new Button[numButtons]; 
Button pauseButton; 
Button clearButton; 
Button resetButton; 
Button penDropButton; 
Button landscapeButton; 

PFont buttonFont; 

public void initButtons() { 
  
  float spacing = 30; 
  float buttonWidth = 170; 
  
  buttons[0] = pauseButton = new Button("PAUSE (P)", 0, 100, buttonWidth, 50); 
  buttons[1] = clearButton = new Button("CLEAR (C)", 0, 100, buttonWidth, 50); 
  buttons[2] = resetButton = new Button("RESET (R)", 0, 100, buttonWidth, 50); 
  buttons[3] = penDropButton = new Button("PEN CHANGE (N)", 0, 100, buttonWidth, 50);
  buttons[4] = landscapeButton = new Button("DRAW LAND (L)", 0, 100, buttonWidth, 50);
 
  
 
  for(int i = 0; i<numButtons; i++)  { 
    buttons[i].x = ((viewWidth/2) - ((float)i-(((float)numButtons-1))/2) * (buttonWidth + spacing) ) - (buttons[i].w/2); 
     buttons[i].y = viewHeight-150; 
   
   
  } 
  
  
  buttonFont = loadFont("FuturaLTPro-Bold-20.vlw");
  
}


public void renderButtons() { 
  
  for(int i = 0; i<buttons.length; i++) { 
    
    buttons[i].render();  
    
  }
  
}

public void checkButtons() { 
   if(pauseButton.isMouseOver()) { 
     //togglePause();
   } else if(clearButton.isMouseOver()) { 
     //clearQueue();
   } else if(resetButton.isMouseOver()) { 
     //reset(); 
   } else if(penDropButton.isMouseOver()) { 
     //dropPen(); 
   } else if(landscapeButton.isMouseOver()) { 
     //sendLandscape(); 
   }  
  
}



class Button { 

  float x, y, w, h; 
  boolean over; 
  String label; 
  public Button(String _label, float _x, float _y, float _w, float _h) { 
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    label = _label; 
  } 

  public boolean isMouseOver() {
    float mousex = (float)mouseX/viewScale; 
    float mousey = (float)mouseY/viewScale; 
    
    if ((mousex>x) && (mousex<x+w) && (mousey>y) && (mousey<y+h)) {
      return true;
    } 
    else { 
      return false;
    }
    
  }
  
  public void render() { 
    stroke(255); 
//    strokeWeight(2); 
//    if(isMouseOver()) { 
//      fill(255); 
// 
//      rect(x, y,w, h);
//      fill(0); 
//    } else { 
//      
//      noFill(); 
//      rect(x, y,w, h);
//        fill(255); 
//    }
//    
    fill(255); 
    textAlign(CENTER, CENTER); 
    textFont(buttonFont); 
    text(label, x+(w/2), y+(h/2)); 
    
    
  }
  
}

final int COMMAND_MOVE = 0; 
final int COMMAND_DRAW = 1; 
final int COMMAND_DRAW_DIRECT = 2; 
final int COMMAND_RESTART = 3; 


class Command { 
  
//  
//  Command(){
//     Command(0,0,0);
//  }
//  
  Command (int _c, float _p1, float _p2) { 
    
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    
    //p3 = _p3; 
    //p4 = _p4;   
  }
  
  
  
  int c; 
  float p1, p2;
  
  
  
};

public void keyPressed() {
  if (key == 'r') { 
    sendSerial("reset");
  }
  if (key == 'f') { 
    //resize(displayWidth, displayHeight);  
    //frame.setSize(displayWidth, displayHeight);
    // frame.setUndecorated(true); 
    //frame.setLocation(0, 0);
    fullSizePreview = !fullSizePreview; 
    if (fullSizePreview) {
      //resize(displayWidth, displayHeight);  
      //frame.setSize(displayWidth, displayHeight);
      //frame.setLocation(0, 0);
      noSmooth();
    } 
    else {
      //resize(round(viewWidth*viewScale), round(viewHeight*viewScale));  
      //frame.setSize(round(viewWidth*viewScale), round(viewHeight*viewScale));
      smooth();
    }
  }
  if (key == 'l') { 
    drawLandscape();
  } 
  else if (key == 'p') { 
    if (state == STATE_PAUSED) {
      state = STATE_RUNNING;
    } 
    else if (state == STATE_PAUSE_NEXT) { 
      state = STATE_PAUSED;
    } 
    else { 
      state = STATE_PAUSE_NEXT;
    }
  } 
  else if (key == 's') { 
    closeSerial(); 
    initSerial();
  }
}


public void initLandscape() { 
  landscapePoints.add(new PVector(0.5f, 355.55f));
  landscapePoints.add(new PVector(5.45f, 355.55f));
  landscapePoints.add(new PVector(6.45f, 359.4f));
  landscapePoints.add(new PVector(11.15f, 359.4f));
  landscapePoints.add(new PVector(12.1f, 363.65f));
  landscapePoints.add(new PVector(14.6f, 363.65f));
  landscapePoints.add(new PVector(15.95f, 375.75f));
  landscapePoints.add(new PVector(19.25f, 388));
  landscapePoints.add(new PVector(19.25f, 391.9f));
  landscapePoints.add(new PVector(21.65f, 400));
  landscapePoints.add(new PVector(28.85f, 404.25f));
  landscapePoints.add(new PVector(30.7f, 412.4f));
  landscapePoints.add(new PVector(33.05f, 416.7f));
  landscapePoints.add(new PVector(37.9f, 420.5f));
  landscapePoints.add(new PVector(42.7f, 420.5f));
  landscapePoints.add(new PVector(47.4f, 416.65f));
  landscapePoints.add(new PVector(51.75f, 409.5f));
  landscapePoints.add(new PVector(56.55f, 404.25f));
  landscapePoints.add(new PVector(61.3f, 400));
  landscapePoints.add(new PVector(63.65f, 396.15f));
  landscapePoints.add(new PVector(68, 391.9f));
  landscapePoints.add(new PVector(70.3f, 388));
  landscapePoints.add(new PVector(75.1f, 386.1f));
  landscapePoints.add(new PVector(79.85f, 379.95f));
  landscapePoints.add(new PVector(84.7f, 378.95f));
  landscapePoints.add(new PVector(89.05f, 375.65f));
  landscapePoints.add(new PVector(93.75f, 375.65f));
  landscapePoints.add(new PVector(98.5f, 376.55f));
  landscapePoints.add(new PVector(103.2f, 379.95f));
  landscapePoints.add(new PVector(104.3f, 383.8f));
  landscapePoints.add(new PVector(107.55f, 388));
  landscapePoints.add(new PVector(108.95f, 391.9f));
  landscapePoints.add(new PVector(112.4f, 396.15f));
  landscapePoints.add(new PVector(113.3f, 400));
  landscapePoints.add(new PVector(117.1f, 404.25f));
  landscapePoints.add(new PVector(121.95f, 404.25f));
  landscapePoints.add(new PVector(125.3f, 396.3f));
  landscapePoints.add(new PVector(128.6f, 394.2f));
  landscapePoints.add(new PVector(132.45f, 396.15f));
  landscapePoints.add(new PVector(135.75f, 399.9f));
  landscapePoints.add(new PVector(138.15f, 408.15f));
  landscapePoints.add(new PVector(144.7f, 412.4f));
  landscapePoints.add(new PVector(146.3f, 424.8f));
  landscapePoints.add(new PVector(149.55f, 436.65f));
  landscapePoints.add(new PVector(149.55f, 441.05f));
  landscapePoints.add(new PVector(154.35f, 444.85f));
  landscapePoints.add(new PVector(163.45f, 444.85f));
  landscapePoints.add(new PVector(168.15f, 441.05f));
  landscapePoints.add(new PVector(172.95f, 436.75f));
  landscapePoints.add(new PVector(175.45f, 432.9f));
  landscapePoints.add(new PVector(179.7f, 428.6f));
  landscapePoints.add(new PVector(181.95f, 424.8f));
  landscapePoints.add(new PVector(186.7f, 422.5f));
  landscapePoints.add(new PVector(189.15f, 412.4f));
  landscapePoints.add(new PVector(191.55f, 404.35f));
  landscapePoints.add(new PVector(196.35f, 402.4f));
  landscapePoints.add(new PVector(200.7f, 398.1f));
  landscapePoints.add(new PVector(205.45f, 391.9f));
  landscapePoints.add(new PVector(210.15f, 383.8f));
  landscapePoints.add(new PVector(212.55f, 375.75f));
  landscapePoints.add(new PVector(216.85f, 371.8f));
  landscapePoints.add(new PVector(219.3f, 367.55f));
  landscapePoints.add(new PVector(220.65f, 363.65f));
  landscapePoints.add(new PVector(224, 359.4f));
  landscapePoints.add(new PVector(228.8f, 359.4f));
  landscapePoints.add(new PVector(233.55f, 355.55f));
  landscapePoints.add(new PVector(237.85f, 348.45f));
  landscapePoints.add(new PVector(242.65f, 343.2f));
  landscapePoints.add(new PVector(245, 335.15f));
  landscapePoints.add(new PVector(247.35f, 322.8f));
  landscapePoints.add(new PVector(247.3f, 314.5f));
  landscapePoints.add(new PVector(248.35f, 306.55f));
  landscapePoints.add(new PVector(252.2f, 296.5f));
  landscapePoints.add(new PVector(256.55f, 294.55f));
  landscapePoints.add(new PVector(257.95f, 290.4f));
  landscapePoints.add(new PVector(261.25f, 285.95f));
  landscapePoints.add(new PVector(265.95f, 285.95f));
  landscapePoints.add(new PVector(267, 290.25f));
  landscapePoints.add(new PVector(271.75f, 290.25f));
  landscapePoints.add(new PVector(273.25f, 294.55f));
  landscapePoints.add(new PVector(275.2f, 294.55f));
  landscapePoints.add(new PVector(278.95f, 296.5f));
  landscapePoints.add(new PVector(282.25f, 300.3f));
  landscapePoints.add(new PVector(284.7f, 308.45f));
  landscapePoints.add(new PVector(291.85f, 312.65f));
  landscapePoints.add(new PVector(298.55f, 330.8f));
  landscapePoints.add(new PVector(303.25f, 331.8f));
  landscapePoints.add(new PVector(308, 335.05f));
  landscapePoints.add(new PVector(309, 338.9f));
  landscapePoints.add(new PVector(312.35f, 343.2f));
  landscapePoints.add(new PVector(313.8f, 347.05f));
  landscapePoints.add(new PVector(317.05f, 351.4f));
  landscapePoints.add(new PVector(321.9f, 351.4f));
  landscapePoints.add(new PVector(322.85f, 363.8f));
  landscapePoints.add(new PVector(326.6f, 375.75f));
  landscapePoints.add(new PVector(326.6f, 379.95f));
  landscapePoints.add(new PVector(330.9f, 379.95f));
  landscapePoints.add(new PVector(332.4f, 383.8f));
  landscapePoints.add(new PVector(335.8f, 388));
  landscapePoints.add(new PVector(338.1f, 396.15f));
  landscapePoints.add(new PVector(340.45f, 400.1f));
  landscapePoints.add(new PVector(345.3f, 404.25f));
  landscapePoints.add(new PVector(346.25f, 416.65f));
  landscapePoints.add(new PVector(349.6f, 428.7f));
  landscapePoints.add(new PVector(349.6f, 432.85f));
  landscapePoints.add(new PVector(350.95f, 436.75f));
  landscapePoints.add(new PVector(354.3f, 441.05f));
  landscapePoints.add(new PVector(359, 441.05f));
  landscapePoints.add(new PVector(361.4f, 449.1f));
  landscapePoints.add(new PVector(363.95f, 453));
  landscapePoints.add(new PVector(368.2f, 457.2f));
  landscapePoints.add(new PVector(372.9f, 461));
  landscapePoints.add(new PVector(410.2f, 461));
  landscapePoints.add(new PVector(412.55f, 449.1f));
  landscapePoints.add(new PVector(417.4f, 441.05f));
  landscapePoints.add(new PVector(419.7f, 432.9f));
  landscapePoints.add(new PVector(422.05f, 432.9f));
  landscapePoints.add(new PVector(425.45f, 424.8f));
  landscapePoints.add(new PVector(428.8f, 422.35f));
  landscapePoints.add(new PVector(433.45f, 416.65f));
  landscapePoints.add(new PVector(438.25f, 415.15f));
  landscapePoints.add(new PVector(442.6f, 412.4f));
  landscapePoints.add(new PVector(447.4f, 412.4f));
  landscapePoints.add(new PVector(448.8f, 416.65f));
  landscapePoints.add(new PVector(454.55f, 430.55f));
  landscapePoints.add(new PVector(455.5f, 434.8f));
  landscapePoints.add(new PVector(459.25f, 438.6f));
  landscapePoints.add(new PVector(462.6f, 440.9f));
  landscapePoints.add(new PVector(466, 444.85f));
  landscapePoints.add(new PVector(468.35f, 452.9f));
  landscapePoints.add(new PVector(475.55f, 457.3f));
  landscapePoints.add(new PVector(484.7f, 457.3f));
  landscapePoints.add(new PVector(494.7f, 458.2f));
  landscapePoints.add(new PVector(503.75f, 461.1f));
  landscapePoints.add(new PVector(522.2f, 461.1f));
  landscapePoints.add(new PVector(524.75f, 453));
  landscapePoints.add(new PVector(527.1f, 441.05f));
  landscapePoints.add(new PVector(527.1f, 432.9f));
  landscapePoints.add(new PVector(531.9f, 432.9f));
  landscapePoints.add(new PVector(534.15f, 424.8f));
  landscapePoints.add(new PVector(538.6f, 420.5f));
  landscapePoints.add(new PVector(540.9f, 416.65f));
  landscapePoints.add(new PVector(542.35f, 412.5f));
  landscapePoints.add(new PVector(545.7f, 408));
  landscapePoints.add(new PVector(550.45f, 408));
  landscapePoints.add(new PVector(552.85f, 398.1f));
  landscapePoints.add(new PVector(554.75f, 389.95f));
  landscapePoints.add(new PVector(559.55f, 388));
  landscapePoints.add(new PVector(564.35f, 391.9f));
  landscapePoints.add(new PVector(573.35f, 391.9f));
  landscapePoints.add(new PVector(578.1f, 388));
  landscapePoints.add(new PVector(579.55f, 379.95f));
  landscapePoints.add(new PVector(582.9f, 369.4f));
  landscapePoints.add(new PVector(587.75f, 367.55f));
  landscapePoints.add(new PVector(588.65f, 363.8f));
  landscapePoints.add(new PVector(592.05f, 359.5f));
  landscapePoints.add(new PVector(596.85f, 355.55f));    

  float landscale = 1.5f; 
  // scale to match game : 
  for (int i = 0; i<landscapePoints.size(); i++) {
    PVector p = (PVector)landscapePoints.get(i);
    p.x *= landscale;
    p.y *= landscale;
    p.y -= 50;
  }
  
  landscapeWidth = 596.85f * landscale; 
}


Serial serial; 
boolean serialCreated = false; 
String serialName = ""; 
boolean firstContact = false; 
int numToSend = 0; 
int serialMessageCount = 0; 
String serialMessage = ""; 

public boolean initSerial() { 

  if (serial!=null) { 
    closeSerial();
  }

  String ports[] = Serial.list(); 

  for (int i = 0; i< ports.length; i++) { 

    if (ports[i].indexOf("tty.usb")!=-1) { 
      serial = new Serial(this, ports[i], 38400); 
      println("joining port : " + ports[i] ); 
      serialCreated = true; 

      break;
    }
  }

  if (serial==null) { 
    serialCreated = false; 
    println("no serial connection found"); 
    return false;
  } 
  else { 
    return true;
  }
}

public void closeSerial() { 
  if (serial!=null) { 
    serial.clear(); 
    serial.stop() ;
  }

  serial = null;
}

public void serialEvent(Serial serial) { 

  int inByte = serial.read(); 

  if (!firstContact) {
    firstContact = true; 
    println("Connected!");
  }

  if ((inByte == 0) || (inByte == 10)) { 
    processMessage();
  } 
  else if ((inByte>=32) && (inByte<=126)) { 
    serialMessage = serialMessage + PApplet.parseChar(inByte);  
    //println(inByte);
  }
}


public void sendSerial(String msg) { 
   serial.write(msg); 
   serialMessages.add("->"+msg);  
  
  
}
public void processMessage () { 

  //println("->" +serialMessage); 

  serialMessages.add(serialMessage); 

  //println(serialMessage.substring(6,serialMessage.length()-1));
  if (beginsWith(serialMessage, "ready")) {

    numToSend = PApplet.parseInt(getStringAfterChar(serialMessage, ":"));   

    println("ready to send "+numToSend); 

    // format = <cmdnum>,<cmd>,<p1>,<p2> 
    //serial.write(++counter + ",1,"+random(0,1000)+","+random(0,1000)+"\0");
  } 
  else if (beginsWith(serialMessage, "pagewidth")) { 
    pageWidth = PApplet.parseFloat(getStringAfterChar(serialMessage, ":"));   
    println("pageWidth set : "+pageWidth);
  } 
  else if (beginsWith(serialMessage, "pageheight")) { 
    pageHeight = PApplet.parseFloat(getStringAfterChar(serialMessage, ":"));   
    println("pageHeight set : "+pageHeight);
  } 
  else if (beginsWith(serialMessage, "stepspermil")) { 
    stepsPerMil = PApplet.parseFloat(getStringAfterChar(serialMessage, ":"));   
    println("stepsPerMil set : "+stepsPerMil);
    machineWidth = 3000 * stepsPerMil; 
    
  } 
  else if (beginsWith(serialMessage, "pagetop")) { 
    pageTop = PApplet.parseFloat(getStringAfterChar(serialMessage, ":"));   
    println("pageTop set : "+pageTop);
    
  } 
  else if (beginsWith(serialMessage, "CHANGE STATE")) { 
    String statemessage = (getStringAfterChar(serialMessage, ":"));
    lunargraphState = PApplet.parseInt(statemessage.split(",")[0]);
  } 
  else if (beginsWith(serialMessage, "buttons")) { 
    String buttonstatesstring = (getStringAfterChar(serialMessage, ":"));
    //lunargraphState = int(statemessage.split(",")[0]);
    for(int i = 0; i<buttonStates.length; i++) { 
      buttonStates[i] = buttonstatesstring.charAt(i)=='1' ? true : false;
    }
    
  }
  serialMessage = "";  
  //println("------");
}

/*

WsServer socket;
int port = 8087; 

boolean messageRestart = false;  // so we know where the home position is
boolean firstRestartReceived = false; // so we don't draw anyone half way through a game


boolean initWebSocket() { 
  println("starting WebSocket server on port "+port); 
  socket = new WsServer(this, port);
  return true;
}

void onWsMessage(WebSocket con, String msg) {
  //println(msg);

  //  if (beginsWith(msg, "landscapeend")) { 
  //    drawLandscape();
  //  } 
  //  else if (beginsWith(msg, "landscape")) { 
  //    PVector p = new PVector(0, 0); 
  //    String numbers[] = getStringAfterChar(msg, ":").split(","); 
  //
  //    int index = int(numbers[0]); 
  //
  //    p.x = float(numbers[1]); 
  //    p.y = float(numbers[2]); 
  //
  //    println(p);
  //    //p.mult(0.5f);
  //    if (landscapePoints.size()<=index) {
  //      landscapePoints.add(p);
  //    } 
  //    else {
  //      landscapePoints.set(index, p);
  //    } 
  //    //p.y-=100;
  //    //p.mult(0.8);
  //  } 
  //  else 
  if (beginsWith(msg, "{")) { 

    try {
      String readablemsg = ""; 

      JSONObject msgJson = new JSONObject(msg);
      String type = msgJson.getString("type");
      //println(type+" "+ (type == "update"));
      readablemsg+=type+" "; 
      if (type.equals("restart")) { 
        move = true;
        commands.add(new Command(COMMAND_RESTART, 0,0));
        messageRestart = true; 
        firstRestartReceived = true; 
      } 
      else if (type.equals("update")) { 
      
        if(firstRestartReceived) { 
          
         
          PVector p1 = new PVector(msgJson.getInt("x"), msgJson.getInt("y")); 

          p1.div(100);  // messages from the clients are multiplied by 100 to avoid floating points. 
          
          
          readablemsg+=": "+p1.x+", "+p1.y; 
          receivePosition = p1.get(); 
          p1 = convertDataToLunarGraph(p1); 
          
          if(messageRestart) homePosition = p1.get(); 
          
          if((p1.x<0) || (p1.x>pageWidth) || (p1.y<0) || (p1.y>pageHeight) ) {
            move = true; 
           
          } else if (move) {
            moveToXYPos(p1);
            move = false;
          } 
          else {  
            lineToXYPos(p1,true); // add true for non-smooth drawing. 
          }
        }
      }
      webSocketMessages.add(readablemsg);
    }
    catch(JSONException e) {
    }
  }
}

void drawLandscape() { 
  println("drawing landscape..."); 

//  float gap = pageWidth/20;
//  float lineheight = pageHeight/4; 
//  
//  for (float x = 0; x<pageWidth; x+=gap) { 
//    lineToXYPos(x, lineheight*0.1); 
//    lineToXYPos(x, lineheight); 
//    lineToXYPos(x+(gap/2), lineheight); 
//    lineToXYPos(x+(gap/2), lineheight*0.1); 
//    
//    
//    
//    
//  }

  // draw corners
  int cornerSize = round(3 * stepsPerMil); 
 
//  moveToXYPos(0, cornerSize);
//  lineToXYPos(0, 0);
//  lineToXYPos(cornerSize, 0);
//
//  moveToXYPos(pageWidth-cornerSize, 0);
//  lineToXYPos(pageWidth, 0);
//  lineToXYPos(pageWidth, cornerSize);
//  
//  moveToXYPos(0, pageHeight - cornerSize);
//  lineToXYPos(0, pageHeight);
//  lineToXYPos(cornerSize, pageHeight);
//
//  moveToXYPos(pageWidth-cornerSize, pageHeight);
//  lineToXYPos(pageWidth, pageHeight);
//  lineToXYPos(pageWidth, pageHeight - cornerSize);

  PVector lastPos = new PVector(); 
  
  for (float offset = 0; offset<=landscapeWidth; offset+=landscapeWidth) { 

    for (int i = 0; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i)).get();
      p1.x+=offset; 

      if (p1.x>dataWidth) break; 

      p1 = convertDataToLunarGraph(p1);  
      if ((i==0) && (offset==0)) { 
        moveToXYPos(p1);
      } 
      else { 
        lineToXYPos(p1);
        lineToXYPos(lastPos.x, lastPos.y); 
        lineToXYPos(p1.x, p1.y); 
        //lineToXYPos(p1); 
      }
      lastPos = p1.get(); 
    }
  }
}

void onWSOpen(WebSocket con) {
  println("WebSocket client joined");
  webSocketMessages.add("WebSocket client joined");
}

void onWSClose(WebSocket con) {
  println("WebSocket client left");
  webSocketMessages.add("WebSocket client left");
}

*/


WebSocketP5 socket;
int port = 8087; 

boolean messageRestart = false;  // so we know where the home position is
boolean firstRestartReceived = false; // so we don't draw anyone half way through a game


public boolean initWebSocket() { 
  println("starting WebSocket server on port "+port); 
  socket = new WebSocketP5(this, port);
  return true;
}

public void websocketOnMessage(WebSocketConnection con, String msg) {
  //println(msg);

  //  if (beginsWith(msg, "landscapeend")) { 
  //    drawLandscape();
  //  } 
  //  else if (beginsWith(msg, "landscape")) { 
  //    PVector p = new PVector(0, 0); 
  //    String numbers[] = getStringAfterChar(msg, ":").split(","); 
  //
  //    int index = int(numbers[0]); 
  //
  //    p.x = float(numbers[1]); 
  //    p.y = float(numbers[2]); 
  //
  //    println(p);
  //    //p.mult(0.5f);
  //    if (landscapePoints.size()<=index) {
  //      landscapePoints.add(p);
  //    } 
  //    else {
  //      landscapePoints.set(index, p);
  //    } 
  //    //p.y-=100;
  //    //p.mult(0.8);
  //  } 
  //  else 
  if (beginsWith(msg, "{")) { 

    try {
      String readablemsg = ""; 

      JSONObject msgJson = new JSONObject(msg);
      String type = msgJson.getString("type");
      //println(type+" "+ (type == "update"));
      readablemsg+=type+" "; 
      if (type.equals("restart")) { 
        move = true;
        commands.add(new Command(COMMAND_RESTART, 0,0));
        messageRestart = true; 
        firstRestartReceived = true; 
      } 
      else if (type.equals("update")) { 
      
        if(firstRestartReceived) { 
          
         
          PVector p1 = new PVector(msgJson.getInt("x"), msgJson.getInt("y")); 

          p1.div(100);  // messages from the clients are multiplied by 100 to avoid floating points. 
          
          
          readablemsg+=": "+p1.x+", "+p1.y; 
          receivePosition = p1.get(); 
          p1 = convertDataToLunarGraph(p1); 
          
          if(messageRestart) homePosition = p1.get(); 
          
          if((p1.x<0) || (p1.x>pageWidth) || (p1.y<0) || (p1.y>pageHeight) ) {
            move = true; 
           
          } else if (move) {
            moveToXYPos(p1);
            move = false;
          } 
          else {  
            lineToXYPos(p1,true); // add true for non-smooth drawing. 
          }
        }
      }
      webSocketMessages.add(readablemsg);
    }
    catch(JSONException e) {
    }
  }
}

public void drawLandscape() { 
  println("drawing landscape..."); 

//  float gap = pageWidth/20;
//  float lineheight = pageHeight/4; 
//  
//  for (float x = 0; x<pageWidth; x+=gap) { 
//    lineToXYPos(x, lineheight*0.1); 
//    lineToXYPos(x, lineheight); 
//    lineToXYPos(x+(gap/2), lineheight); 
//    lineToXYPos(x+(gap/2), lineheight*0.1); 
//    
//    
//    
//    
//  }

  // draw corners
  int cornerSize = round(3 * stepsPerMil); 
 
//  moveToXYPos(0, cornerSize);
//  lineToXYPos(0, 0);
//  lineToXYPos(cornerSize, 0);
//
//  moveToXYPos(pageWidth-cornerSize, 0);
//  lineToXYPos(pageWidth, 0);
//  lineToXYPos(pageWidth, cornerSize);
//  
//  moveToXYPos(0, pageHeight - cornerSize);
//  lineToXYPos(0, pageHeight);
//  lineToXYPos(cornerSize, pageHeight);
//
//  moveToXYPos(pageWidth-cornerSize, pageHeight);
//  lineToXYPos(pageWidth, pageHeight);
//  lineToXYPos(pageWidth, pageHeight - cornerSize);

  PVector lastPos = new PVector(); 
  
  for (float offset = 0; offset<=landscapeWidth; offset+=landscapeWidth) { 

    for (int i = 0; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i)).get();
      p1.x+=offset; 

      if (p1.x>dataWidth) break; 

      p1 = convertDataToLunarGraph(p1);  
      if ((i==0) && (offset==0)) { 
        moveToXYPos(p1);
      } 
      else { 
        lineToXYPos(p1);
        lineToXYPos(lastPos.x, lastPos.y); 
        lineToXYPos(p1.x, p1.y); 
        //lineToXYPos(p1); 
      }
      lastPos = p1.get(); 
    }
  }
}

public void websocketOnOpen(WebSocketConnection con) {
  println("WebSocket client joined");
  webSocketMessages.add("WebSocket client joined");
}

public void websocketOnClosed(WebSocketConnection con) {
  println("WebSocket client left");
  webSocketMessages.add("WebSocket client left");
}



  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "LunarGraphController" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}