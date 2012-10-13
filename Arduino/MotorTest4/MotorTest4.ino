#include <AccelStepper.h>

int potPin = A0; 

int Motor1StepPin = 2;
int Motor1DirPin = 3;

int Motor2StepPin = 4;
int Motor2DirPin = 5;  

AccelStepper motorA(AccelStepper::DRIVER, Motor1StepPin, Motor1DirPin); 
//AccelStepper motorB(AccelStepper::DRIVER, 2, 3); 

void setup() {
  //Serial.begin(9600); 
  
    motorA.setMinPulseWidth(1);
    motorA.setMaxSpeed(40000.0);
    motorA.setAcceleration(5000.0);
    motorA.setSpeed(10000);
    motorA.moveTo(10000);
  
}



void loop() { 
  //int potValue  = analogRead(potPin);   
   if (motorA.distanceToGo() == 0)
	motorA.moveTo(-motorA.currentPosition());
    motorA.run();
   
  //Serial.println(potValue); 
  
  
}

