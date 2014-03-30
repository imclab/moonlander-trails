// Test to see if IR Receiver does anything on a 3.3 volt input

int inputAnalog = A0; 
int inputDigital = 50; 
int currentAnalog = 0; 
int currentDigital = HIGH; 

void setup() { 
  Serial.begin(9600); 
  digitalWrite(A0,LOW);
  pinMode(inputAnalog, INPUT); 
  pinMode(inputDigital, INPUT); 
  
}


void loop() { 
  
//  int newReading = analogRead(inputAnalog); 
//  if(newReading!=currentAnalog) { 
//    
//    if(abs(newReading-currentAnalog)>10) {
//      Serial.println(newReading); 
//      currentAnalog = newReading;  
//    }
//    
//  }
  
  int newDigital = digitalRead(inputDigital); 
  if(newDigital!=currentDigital) { 
    
    //if(abs(newDigital-currentDigital)>10) 
    Serial.println(newDigital); 
    currentDigital = newDigital;  
    
    
  }
  
  
  
}
