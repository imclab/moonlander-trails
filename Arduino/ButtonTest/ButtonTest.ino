
int const A_END_STOP_MIN_PIN = 28; 
int const A_END_STOP_MAX_PIN = 32; 
int const B_END_STOP_MIN_PIN = 38; 
int const B_END_STOP_MAX_PIN = 42;

int const BOTH_RESET_PIN = 48;

int const A_CALIBRATION_PIN = 30;
int const B_CALIBRATION_PIN = 40;


#include "Button.h"

Button endStopMinButtonA = Button(A_END_STOP_MIN_PIN, true, HIGH); 
Button endStopMaxButtonA = Button(A_END_STOP_MAX_PIN, true, HIGH);//, false, HIGH); 
Button calibrationButtonA = Button(A_CALIBRATION_PIN, true, HIGH);//, false, HIGH);

Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN, true, HIGH);//, false, HIGH); 
Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN, true, HIGH);//, false); 
Button calibrationButtonB = Button(B_CALIBRATION_PIN, true, HIGH);//, false); 

// DON'T FORGET to add to NUM_BUTTONS if you add to the array
Button* buttons[] = { 
  &endStopMinButtonA, 
  &endStopMaxButtonA, 
  &endStopMinButtonB, 
  &endStopMaxButtonB, 
  &calibrationButtonA, 
  &calibrationButtonB
}; 
const int NUM_BUTTONS = 6; 


void setup() {
  // put your setup code here, to run once:
  pinMode(A_END_STOP_MIN_PIN, INPUT_PULLUP); 
  Serial.begin(115200); 

}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.println(digitalRead(A_END_STOP_MIN_PIN)); 
  
  updateButtons(); 
}



void updateButtons() {  
	
	boolean changed = true; 
  for(int i = 0; i< NUM_BUTTONS; i++) { 
    if( buttons[i]->update() ) changed = true;  
  }

  if(changed) { 
    // send button data...  
    Serial.print("buttons:"); 
    for(int i = 0; i< NUM_BUTTONS; i++) { 
      if(buttons[i]->isOn()) Serial.print("1");
      else Serial.print("0");
      
    }
    Serial.println(""); 
  }
}

