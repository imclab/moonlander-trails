#include <AccelStepper.h>

int potPin = A0; 

int const A_STEP_PIN    =   13; 
int const A_DIR_PIN     =   12; 
int const B_STEP_PIN    =   14; 
int const B_DIR_PIN     =   15; 

int const A_ERR_RESET_PIN = 10; 
int const B_ERR_RESET_PIN = 16;


AccelStepper motorA(AccelStepper::DRIVER, A_STEP_PIN, A_DIR_PIN); 
AccelStepper motorB(AccelStepper::DRIVER, B_STEP_PIN, B_DIR_PIN); 
//AccelStepper motorB(AccelStepper::DRIVER, 2, 3); 




void setup() {
  //Serial.begin(9600); 

    motorA.setMinPulseWidth(1);
    motorA.setMaxSpeed(100000.0);
    motorA.setAcceleration(100000.0);
    motorA.setSpeed(1000);
    motorA.moveTo(2000);
    
    motorB.setMinPulseWidth(1);
    motorB.setMaxSpeed(100000.0);
    motorB.setAcceleration(100000.0);
    motorB.setSpeed(1000);
    motorB.moveTo(2000);
    reset(); 
  
}



void loop() { 
  //int potValue  = analogRead(potPin);   
   //if (motorA.distanceToGo() == 0)
	
    motorA.runToPosition();
    motorA.moveTo(-motorA.currentPosition());

    motorB.runToPosition(); 
    motorB.moveTo(-motorB.currentPosition());
    
  //Serial.println(potValue); 
  
  
}


void reset() { 
  
  pinMode(A_ERR_RESET_PIN, OUTPUT); 
  pinMode(B_ERR_RESET_PIN, OUTPUT); 
  
  digitalWrite(A_ERR_RESET_PIN, HIGH); 
  digitalWrite(B_ERR_RESET_PIN, HIGH); 
  
  delay(2000); 
  
  
  digitalWrite(A_ERR_RESET_PIN, LOW); 
  digitalWrite(B_ERR_RESET_PIN, LOW); 
  
  pinMode(A_ERR_RESET_PIN, INPUT); 
  pinMode(B_ERR_RESET_PIN, INPUT); 
  
  
}
