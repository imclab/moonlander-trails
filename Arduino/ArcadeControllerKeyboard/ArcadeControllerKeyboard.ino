

int thrustPin = A0; 


float topValue = 0; 
float bottomValue = 1024; 
float currentReading; 
float smoothReading; 

int currentKey = 0; 
int counter =0; 

void setup() { 
  
  Serial.begin(9600); 
  Keyboard.begin(); 
  Mouse.end();
  
}

void loop() { 
 currentReading = analogRead(thrustPin);
 
 if(topValue<currentReading) topValue = currentReading; 
 if(bottomValue>currentReading) bottomValue = currentReading; 
 
 smoothReading += ((currentReading-smoothReading)*0.1f);
 
 int newKey = round(map(smoothReading, bottomValue, topValue, -1, 11));
 if(newKey<0) newKey = 0; 
 if(newKey>9) newKey = 9; 
 
 
 
 if(newKey!=currentKey) {
   
   currentKey = newKey; 
   Keyboard.releaseAll(); 
   Keyboard.press(48+currentKey); 
   Serial.println(newKey);  
   counter = 0; 
 } else if (counter>5) {
    Keyboard.releaseAll(); 
   
 }
 
 counter++; 
 
 //Mouse.move(0,analogRead(thrustPin));
 delay(10);  
  
}
