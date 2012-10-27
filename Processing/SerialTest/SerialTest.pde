

import processing.serial.*; 

Serial myPort; 
boolean firstContact = false; 
int[] serialInArray = new int[1000];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
int sendCount = 0; 

void setup() { 
  
  size(256, 256);
  noStroke(); 

  println(Serial.list()); 

  String portName = Serial.list()[4]; 
  myPort = new Serial(this, portName, 9600); 
  
  
  
  
  
}

void draw() { 
 
  if(sendCount<1000) { 
    
    
    
    myPort.write(sendCount); 
    sendCount++;  
  }
  
  
}


void serialEvent(Serial myPort) { 
  
  char inByte = char(myPort.read()); 
  if(!firstContact) {
    firstContact = true; 
    println("Connected!"); 
    
  }
  print(inByte);
  //serialInArray[serialCount] = inByte; 
  serialCount++; 
  
  
  
}
