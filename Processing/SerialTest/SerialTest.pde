

import processing.serial.*; 

Serial myPort; 
boolean firstContact = false; 
int[] serialInArray = new int[1000];    // Where we'll put what we receive

int numToSend = 0; 
int counter = 0; 



String message = ""; 

void setup() { 
  
  size(1024, 1024);
  noStroke(); 

  String ports[] = Serial.list(); 
  
  println(ports); 
  for(int i = 0; i< ports.length; i++) { 
    
    if(ports[i].indexOf("tty.usbserial")!=-1) { 
      myPort = new Serial(this, ports[i], 115200); 
      println("joining port : " + ports[i] ); 
      break; 
    }  
    
  }

  
}


void mousePressed() { 
  myPort.write(++counter+ ","+0+","+map((float)mouseX, 0, 1024,0,3939.0f)+","+map((float)mouseY, 0, 1024,0,3939.0f)+"\0"); 
  
  
}
void draw() { 
 
 if(numToSend>0) { 
   
   //myPort.write(
   
   
 }
 //if(frameCount%2==0) mousePressed(); 
  
  
}



void serialEvent(Serial myPort) { 
  
  int inByte = myPort.read(); 
  
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
    //myPort.write(++counter + ",1,"+random(0,1000)+","+random(0,1000)+"\0"); 
  
  } 
  
  message = "";  
  //println("------"); 
  
}
