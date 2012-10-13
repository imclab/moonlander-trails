#include <AccelStepper.h>



//AccelStepper motorA(AccelStepper::DRIVER, 2, 3); 
//AccelStepper motorB(AccelStepper::DRIVER, 2, 3); 


int PIN_XENABLE = 6; 
int PIN_XSTEP = 2; 
int PIN_XDIRECTION = 3; 

int PIN_YENABLE = 7; 
int PIN_YSTEP = 4; 
int PIN_YDIRECTION = 5; 


int delayTime = 1; 
int counter = 0; 
boolean stepHigh = true; 
boolean enableHigh = true; 
boolean dir = LOW; 

float speed = 600; 
float target = 6000; 

void setup() { 
  

  pinMode(PIN_XENABLE, OUTPUT);
  pinMode(PIN_XSTEP, OUTPUT);
  pinMode(PIN_XDIRECTION, OUTPUT);
  digitalWrite(PIN_XENABLE, LOW);
  digitalWrite(PIN_XSTEP, LOW);
  digitalWrite(PIN_XDIRECTION, LOW);
  
  pinMode(PIN_YENABLE, OUTPUT);
  pinMode(PIN_YSTEP, OUTPUT);
  pinMode(PIN_YDIRECTION, OUTPUT);
  digitalWrite(PIN_YENABLE, LOW);
  digitalWrite(PIN_YSTEP, LOW);
  digitalWrite(PIN_YDIRECTION, LOW);

  //Serial.begin(9600);
  
}

void loop() { 
  
  
  digitalWrite(PIN_XENABLE, HIGH); // HIGH IS  ENABLED  
  digitalWrite(PIN_YENABLE, HIGH); // HIGH IS  ENABLED 
 
  digitalWrite(PIN_XDIRECTION, dir); 
  digitalWrite(PIN_YDIRECTION, dir); 
  
  //make the step pulse
  digitalWrite(PIN_XSTEP,HIGH);  
  digitalWrite(PIN_YSTEP,HIGH);  
  delayMicroseconds(2);  // it should be 5 usecs but I found that 1 usec actually makes a 5 usec pulse. 
  digitalWrite(PIN_XSTEP,LOW); 
  digitalWrite(PIN_YSTEP,LOW); 
  
  // wait 500 usec (1/2 mil) between steps 
  delayMicroseconds(int(speed)); 
  
  speed += (float(target - speed)*0.001f);
  
  
  counter ++; 
  
  // after 1000 steps change direction
  if(counter>100000) {
     target = 2000; 
    //dir=!dir;  
    
  }
  
  
 
}
