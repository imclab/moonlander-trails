

import processing.serial.*; 

import muthesius.net.*;
import org.webbitserver.*;

Serial serial; 
boolean firstContact = false; 
int[] serialInArray = new int[1000];    // Where we'll put what we receive

int numToSend = 0; 
int counter = 0; 
int xPos = 0; 

float angle = 0; 
float radius = 1; 


float pageWidth = 73076; 

boolean started = false; 

ArrayList commands; 


WebSocketP5 socket;


String message = ""; 

void setup() { 
  
  size(800, 800, P2D);
  commands = new ArrayList(); 
  socket = new WebSocketP5(this,8080);
  frameRate(10); 

  // joining the serial port that is called tty :) 
  String ports[] = Serial.list(); 
  
  println(ports); 
  for(int i = 0; i< ports.length; i++) { 
    
    if(ports[i].indexOf("tty.usb")!=-1) { 
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
  xPos = width/4;
  background(0); 

}
void draw() { 
 /*
 if((started) && (xPos<width))  { 
   
   
   for(int i = 0; i<=300; i+=4) { 
     sendXYPos(xPos,i); 
   }
   for(int i = 300; i>=0; i-=4) { 
     sendXYPos(xPos+1,i); 
   }
      
   xPos+=2; 
   
 }*/
 
 
 if((started) && (radius<200)){
     
   sendXYPos(400 + cos(angle) * radius, 200 + sin(angle) * radius); 
   
   angle +=radians(1); 
   radius += 0.01;
   
 }








 processQueue(); 
  
}

void sendXYPos(float xpos, float ypos) { 
  
  commands.add(new Command(0,xpos, ypos)); 
  
}

void processQueue() { 
  
   if((numToSend>0) && (commands.size()>0)) { 
     
     Command cmd = (Command) commands.remove(0);
     float xpos = map(cmd.p1, 0.0f, width,0.0f,pageWidth); 
     float ypos = map(cmd.p2, 0.0f, height,0.0f,pageWidth);
     xpos = round(xpos*100)/100.0f; 
     ypos = round(ypos*100)/100.0f;
     
     
     String msg = counter+ ","+0+","+xpos+","+ypos+"\0"; 
     counter++; 
     println("sending "+msg); 
     
     serial.write(msg); 
  
     numToSend =0; 
     
     
   }
  
  
  
}


void serialEvent(Serial serial) { 
  
  int inByte = serial.read(); 
  
  if(!firstContact) {
    firstContact = true; 
    println("Connected!"); 
    
  }
  
  if((inByte == 0) || (inByte == 10)) { 
    processMessage(); 
  
  } else { 
    message = message + char(inByte);  
    //println(inByte); 
  }

}

void processMessage () { 
  
  println("->" +message); 
  
  //println(message.substring(6,message.length()-1));
  if((message.length()>6) &&( message.substring(0,6).equals("ready:"))){
   
    numToSend = int(message.substring(6, message.length()-1));  
   
    println("ready to send "+numToSend); 
    
    // format = <cmdnum>,<cmd>,<p1>,<p2> 
    //serial.write(++counter + ",1,"+random(0,1000)+","+random(0,1000)+"\0"); 
  
  } 
  
  message = "";  
  //println("------"); 
  
}


void stop(){
  socket.stop();
  serial.stop(); 
}
