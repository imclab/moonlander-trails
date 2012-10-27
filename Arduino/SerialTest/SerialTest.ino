String incoming; 
int incomingCharCount = 0; 

void setup() { 
  
  
  Serial.begin(9600); 
  
  Serial.println(F("Hello, this is LunarGraph")); 
  
  
  
}


void loop() { 
  
  checkIncoming(); 
  
  
}



void checkIncoming() { 
  
  if(Serial.available()>0) { 
    
    char c = Serial.read(); 
    if(incomingCharCount<1000) { 
      incoming[incomingCharCount] = c; 
      incomingCharCount++; 
      Serial.print(F("Received : ")); 
      Serial.println(c); 
      
      if(incomingCharCount==1000) { 
        Serial.println(incoming);  
        Serial.println("FINISHED"); 
      }
    
    }
    
  }
}
