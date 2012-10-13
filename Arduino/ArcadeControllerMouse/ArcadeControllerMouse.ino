

int thrustPin = A0; 
float currentReading; 
float smoothReading; 

int currentMouseY; 

void setup() { 
  
  Serial.begin(9600); 
  
  
}

void loop() { 
 currentReading = analogRead(thrustPin);
 smoothReading += ((currentReading-smoothReading)*0.1f);
 Serial.println(smoothReading);  
 
 int newMouseY = round(smoothReading); 
 if(newMouseY!=currentMouseY) { 
    Mouse.move(0, newMouseY - currentMouseY); 
    currentMouseY = newMouseY; 
    
   
   
 }
 
  
 //Mouse.move(0,analogRead(thrustPin));
 delay(6);  
  
}
