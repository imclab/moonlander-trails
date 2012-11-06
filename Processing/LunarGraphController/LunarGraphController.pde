

import processing.serial.*; 

import org.json.*;

import muthesius.net.*;
import org.webbitserver.*;

Serial serial; 
boolean firstContact = false; 
int[] serialInArray = new int[1000];    // Where we'll put what we receive

int numToSend = 0; 
int counter = 0; 
int xPos = 0; 
float lineCounter = 0; 

float angle = 0; 
float radius = 1; 

// reasonable defaults but nothing should happen until they're set 
float pageWidth = 10000;  
float pageHeight = 10000;
float stepsPerMil = 20; 

float dataWidth = 895.275; 
float dataHeight = 500; 

boolean started = false; 

ArrayList commands; 
ArrayList landscapePoints; 


PVector receivePosition; 
PVector sentPosition; 
PVector drawnPosition; 

boolean move = true; 

WebSocketP5 socket;


String message = ""; 

void setup() { 

  size(800, 500, OPENGL);
  commands = new ArrayList();
  receivePosition = new PVector(0,0); 
  sentPosition = new PVector(0,0); 
  drawnPosition = new PVector(0,0); 
  landscapePoints = new ArrayList();  
  socket = new WebSocketP5(this, 8084);
  frameRate(10); 

  println(beginsWith("ready:100", "ready")) ;
  println(getStringAfterChar("landscape:100,200", ":")) ; 


  // joining the serial port that is called tty :) 
  String ports[] = Serial.list(); 

  println(ports); 
  for (int i = 0; i< ports.length; i++) { 

    if (ports[i].indexOf("tty.usb")!=-1) { 
      serial = new Serial(this, ports[i], 115200); 
      println("joining port : " + ports[i] ); 
      break;
    }
  }
  background(0); 
  stroke(255);
}


void mousePressed() { 
  //serial.write(++counter+ ","+0+","+map((float)mouseX, 0, 1024,0,3939.0f)+","+map((float)mouseY, 0, 1024,0,3939.0f)+"\0"); 
  //sendXYPos(mouseX, mouseY); 
  started = true; 
  xPos = 0;
  background(0);

  socket.broadcast("sendlandscape");
  //drawLandscape();
}
void draw() { 

  /*
  if ((started) && (xPos<width)) { 
   
   float gap = (sin(lineCounter)+1.0f)*5.0f+1.0f; 
   println("gap = "+gap); 
   for (int i = 0; i<=100; i+=100) { 
   sendXYPos(xPos, i);
   }
   for (int i = 100; i>=0; i-=100) { 
   sendXYPos((xPos+(gap/2.0f)), i);
   }
   
   xPos+=gap;
   }
   lineCounter+=0.2; 
   */
  // 
  // if((started) && (radius<200)){
  //     
  //   sendXYPos(400 + cos(angle) * radius, 200 + sin(angle) * radius); 
  //   
  //   angle +=radians(1); 
  //   radius += 0.01;
  //   
  // }
  //

  background(0); 
  for (float offset = 0; offset<=dataWidth; offset+=dataWidth) { 
    for (int i = 1; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i-1)); 
      PVector p2 = ((PVector)landscapePoints.get(i));
      p1 = p1.get(); 
      p2 = p2.get(); 
      p1.x+=offset; 
      p2.x+=offset; 
      p1 = convertDataToScreen(p1); 
      p2 = convertDataToScreen(p2); 
      line(p1.x, p1.y, p2.x, p2.y);
    }
  }

  ellipse(receivePosition.x,receivePosition.y, 10, 10); 
  processQueue();
}

PVector convertDataToScreen(PVector p) { 

  PVector returnVector = p.get(); 
  returnVector.y-=100; 
  returnVector.mult(width/dataWidth/1.2);  
  return returnVector;
}

PVector convertDataToLunarGraph(PVector p) { 

  PVector returnVector = p.get(); 
  returnVector.y-=100; 
  returnVector.mult(pageWidth/dataWidth/1.2);  
  return returnVector;
}

void moveToXYPos(float xpos, float ypos) { 

  commands.add(new Command(0, xpos, ypos));
}
void lineToXYPos(float xpos, float ypos) { 

  commands.add(new Command(1, xpos, ypos));
}

void moveToXYPos(PVector pos) { 

  commands.add(new Command(0, pos.x, pos.y));
}
void lineToXYPos(PVector pos) { 

  commands.add(new Command(1, pos.x, pos.y));
}

void processQueue() { 

  if ((numToSend>0) && (commands.size()>0)) { 

    Command cmd = (Command) commands.remove(0);
    //float xpos = map(cmd.p1, 0.0f, width, 0.0f, pageWidth); 
    //float ypos = map(cmd.p2, 0.0f, height, 0.0f, pageWidth);
    float xpos = round(cmd.p1*100)/100.0f; 
    float ypos = round(cmd.p2*100)/100.0f;


    String msg = counter+ ","+cmd.c+","+xpos+","+ypos+"\0"; 
    counter++; 
    println("sending "+msg); 

    serial.write(msg); 

    numToSend =0;
  }
}


void serialEvent(Serial serial) { 

  int inByte = serial.read(); 

  if (!firstContact) {
    firstContact = true; 
    println("Connected!");
  }

  if ((inByte == 0) || (inByte == 10)) { 
    processMessage();
  } 
  else if ((inByte>=32) && (inByte<=126)) { 
    message = message + char(inByte);  
    //println(inByte);
  }
}

void processMessage () { 

  println("->" +message); 

  //println(message.substring(6,message.length()-1));
  if (beginsWith(message, "ready")) {

    numToSend = int(getStringAfterChar(message, ":"));   

    println("ready to send "+numToSend); 

    // format = <cmdnum>,<cmd>,<p1>,<p2> 
    //serial.write(++counter + ",1,"+random(0,1000)+","+random(0,1000)+"\0");
  } 
  else if (beginsWith(message, "pagewidth")) { 
    pageWidth = float(getStringAfterChar(message, ":"));   
    println("pageWidth set : "+pageWidth);
  } 
  else if (beginsWith(message, "pageheight")) { 
    pageHeight = float(getStringAfterChar(message, ":"));   
    println("pageHeight set : "+pageHeight);
  } 
  else if (beginsWith(message, "stepspermil")) { 
    stepsPerMil = float(getStringAfterChar(message, ":"));   
    println("stepsPerMil set : "+stepsPerMil);
  } 
  message = "";  
  //println("------");
}

boolean beginsWith(String source, String matchString) { 
  return ((source.length()>=matchString.length()) && (source.substring(0, matchString.length()).equals(matchString)));
}

String getStringAfterChar(String source, String chr) { 
  int index = source.indexOf(chr); 
  if (index == -1) return ""; 
  else return source.substring(index+1, source.length());
}



void websocketOnMessage(WebSocketConnection con, String msg) {
  println(msg);

  if (beginsWith(msg, "landscapeend")) { 
    drawLandscape();
  } 
  else if (beginsWith(msg, "landscape")) { 
    PVector p = new PVector(0, 0); 
    String numbers[] = getStringAfterChar(msg, ":").split(","); 

    int index = int(numbers[0]); 

    p.x = float(numbers[1]); 
    p.y = float(numbers[2]); 

    println(p);
    //p.mult(0.5f);
    if (landscapePoints.size()<=index) {
      landscapePoints.add(p);
    } 
    else {
      landscapePoints.set(index, p);
    } 
    //p.y-=100;
    //p.mult(0.8);
  } 
  else if (beginsWith(msg, "{")) { 

    try {
      JSONObject msgJson = new JSONObject(msg);
      String type = msgJson.getString("type");
      println(type+" "+ (type == "update"));
      if (type.equals("restart")) { 
        move = true;
      } 
      else if (type.equals("update")) { 

        PVector p1 = new PVector(msgJson.getInt("x"), msgJson.getInt("y")); 
        p1.div(100); 
      receivePosition = convertDataToScreen(p1); 
        p1 = convertDataToLunarGraph(p1);  
        if (move) {
          moveToXYPos(p1);
          move = false;
        } 
        else {  
          lineToXYPos(p1);
        }
      }
    }
    catch(JSONException e) {
    }
  }
}

void drawLandscape() { 
  println("drawing landscape..."); 
  moveToXYPos(0, 500);
  lineToXYPos(0, 0);
  lineToXYPos(500, 0);
  
    moveToXYPos(pageWidth-500, 0);
  lineToXYPos(pageWidth, 0);
  lineToXYPos(pageWidth, 500);
  //   
  //  boolean move = true; 
  //  for(float xpos = 0; xpos<pageWidth; xpos+=pageWidth/100) { 
  //      moveToXYPos(xpos, 0);
  //      lineToXYPos(xpos, 2000);
  //  }
  //  
  //  
  //  for(float xpos = pageWidth; xpos>0; xpos-=(pageWidth/100)) { 
  //      moveToXYPos(xpos, 0);
  //      lineToXYPos(xpos, 2000);
  //  }


  for (float offset = 0; offset<=dataWidth; offset+=dataWidth) { 

    for (int i = 0; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i)).get();
      p1.x+=offset; 
      
      if(p1.x>dataWidth*1.2) break; 
      
      p1 = convertDataToLunarGraph(p1);  
      if ((i==0) && (offset==0)) { 
        moveToXYPos(p1);
      } 
      else { 
        PVector p0 = (PVector)landscapePoints.get(i-1); 
//        PVector v = PVector.sub(p1,p0); 
//        for(float j = 0; j<1; j+=0.1) { 
          lineToXYPos(p1);
          //lineToXYPos(p0);
          //lineToXYPos(p1);
        //}
      }
    }
  }
}

void websocketOnOpen(WebSocketConnection con) {
  println("A client joined");
}

void websocketOnClosed(WebSocketConnection con) {
  println("A client left");
}

void stop() {
  socket.stop();
  if(firstContact) serial.stop();
}

