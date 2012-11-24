#include <AnalogueMultiButton.h>


AnalogueMultiButton multiButton; 

int motor1UpButton; 
int motor1DownButton; 
int motor2UpButton; 
int motor2DownButton; 


void setup() { 
  
 Serial.begin(57600); 
    multiButton.init(A0);
  
   motor1UpButton   = multiButton.addButton(600,800);  
   motor1DownButton = multiButton.addButton(800,880);  
   motor2UpButton   = multiButton.addButton(880,1000);  
   motor2DownButton = multiButton.addButton(1000,1023);  
  
   
  
}


void loop() { 
 
  multiButton.update(); 
  

}

