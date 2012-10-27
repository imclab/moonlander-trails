

#include <AccelStepper.h>
#include <AFMotor.h>

#include "constants.h"

#include "Motors.h"


//#include "Motor.h"
#include "Button.h"

#include "TimerManager.h"

TimerManager timerManager; 

unsigned int state = STATE_WAITING; 

float jogSpeedA = 0.0f; 
float jogSpeedB = 0.0f; 
float maxJogSpeed = 100000.0f; 

Button jogUpButtonA   = Button(A_JOG_UP_PIN); 
Button jogDownButtonA = Button(A_JOG_DOWN_PIN); 
Button jogUpButtonB   = Button(B_JOG_UP_PIN); 
Button jogDownButtonB = Button(B_JOG_DOWN_PIN); 
Button resetButton    = Button(RESET_BUTTON_PIN);

Button endStopMinButtonA = Button(A_END_STOP_MIN_PIN); 
Button endStopMaxButtonA = Button(A_END_STOP_MAX_PIN); 
Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN, false); 
Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN, false); 


// DON'T FORGET to add to NUM_BUTTONS if you add to the array
Button* buttons[] = { 
  &jogUpButtonA, 
  &jogDownButtonA, 
  &jogUpButtonB, 
  &jogDownButtonB, 
  &endStopMinButtonA, 
  &endStopMaxButtonA, 
  &endStopMinButtonB, 
  &endStopMaxButtonB, 
  &resetButton
}; 
const int NUM_BUTTONS = 9; 

void setup()  { 

  Serial.begin(9600); 

  initMotors(); 
  initEndStopInterrupts(); 


}

void loop() { 
  // mechanism for doing regular updates no more than 100 times a second. 
  timerManager.update();
  updateButtons(); 

  if(state!=STATE_RESET) checkEndStops(); 

  if(state == STATE_EMERGENCY_STOP) { 
    
    if(resetButton.isPressed()) { 
      changeState(STATE_RESET); 
    }
    
  } else if(state == STATE_RESET) { 
    
    clearEndStops(); 
 
  } else if(state == STATE_WAITING) { 
    updateJogButtons(); 
  }



  if(timerManager.do100msUpdate) { 
    //    
    //    Serial.println(state);
    //    Serial.print(" "); 
    //    Serial.println(digitalRead(B_END_STOP_MAX_PIN)); 

  }

}

void checkEndStops() { 

  if( (endStopMinButtonA.isPressed()) ||
      (endStopMaxButtonA.isPressed()) ||
      (endStopMinButtonB.isPressed()) ||
      (endStopMaxButtonB.isPressed()) ) {

    if(changeState(STATE_EMERGENCY_STOP)){  
  
      Serial.print(endStopMinButtonA.isPressed()) ;
      Serial.print(" "); 
      Serial.print(endStopMaxButtonA.isPressed()) ;
      Serial.print(" "); 
      Serial.print(endStopMinButtonB.isPressed()) ;
      Serial.print(" "); 
      Serial.println(endStopMaxButtonB.isPressed()) ;
    }
  }

}

void clearEndStops() { 
  
  
   boolean switchTriggered = false; 
    
    if(endStopMinButtonA.isPressed()) {
      
      motorA.setSpeed(500); 
      motorA.runSpeed(); 
      switchTriggered = true; 
    }
    if(endStopMaxButtonA.isPressed()) {
      
      motorA.setSpeed(-500); 
      motorA.runSpeed(); 
      
      switchTriggered = true; 
    }
    
    if(endStopMinButtonB.isPressed()) {
      
      motorB.setSpeed(500); 
      motorB.runSpeed(); 
      switchTriggered = true; 
    }
    if(endStopMaxButtonB.isPressed()) {
      
      motorB.setSpeed(-500); 
      motorB.runSpeed(); 
      
      switchTriggered = true; 
    }
    
    if(!switchTriggered) { 
      changeState(STATE_WAITING); 
    }
    
    
}

boolean changeState(int newState) { 
  if(state == newState) return false; 
  
  state = newState; 
  
  jogSpeedA = 0; 
  jogSpeedB = 0; 
  
  
  Serial.print("CHANGE STATE : ");   
   Serial.println(state);
    //    Serial.print(" "); 
    //    Serial.println(digitalRead(B_END_STOP_MAX_PIN)); 
    return true; 
}


void updateButtons() {  

  for(int i = 0; i< NUM_BUTTONS; i++) { 
    buttons[i]->update(); 
  }

}


void updateJogButtons() { 

  if(timerManager.do10msUpdate) { 
    if(jogUpButtonA.isPressed()) { 
      //Serial.println(map((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 100.0f, 0.0f, -maxJogSpeed)); 
      jogSpeedA = mapEaseInOut((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed);
    } 
    else if(jogDownButtonA.isPressed()) { 
      jogSpeedA = mapEaseInOut((float)jogDownButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed);
    } 
    else { 

      jogSpeedA *=0.9f; 
      if(abs(jogSpeedA)<20) jogSpeedA = 0; 

    }
    motorA.setSpeed(jogSpeedA); 



    if(jogUpButtonB.isPressed()) { 
      //Serial.println(map((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 100.0f, 0.0f, -maxJogSpeed)); 
      jogSpeedB = mapEaseInOut((float)jogUpButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed);
    } 
    else if(jogDownButtonB.isPressed()) { 
      jogSpeedB = mapEaseInOut((float)jogDownButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed);
    } 
    else { 

      jogSpeedB *=0.9f; 
      if(abs(jogSpeedB)<20) jogSpeedB = 0; 

    }
    motorB.setSpeed(jogSpeedB); 
  }


  if(timerManager.do100msUpdate) { 
    // trace stuff out here if necessary
  }
  motorA.runSpeed(); 
  motorB.runSpeed(); 
}

void initEndStopInterrupts() { 
  //  attachInterrupt(A_END_STOP_MIN_INTERRUPT, endStopMinTriggered, FALLING); 
  //  digitalWrite(A_END_STOP_MIN_PIN, HIGH); 
  //  attachInterrupt(A_END_STOP_MAX_INTERRUPT, endStopMinTriggered, FALLING); 
  //  digitalWrite(A_END_STOP_MAX_PIN, HIGH); 
  // 
  //  pinMode(B_END_STOP_MAX_PIN, INPUT); 
  //  digitalWrite(B_END_STOP_MAX_PIN, HIGH); 

  //attachInterrupt(B_END_STOP_MAX_INTERRUPT, endStopMinTriggered, FALLING); 


}

void endStopMinTriggered() { 

  state = STATE_EMERGENCY_STOP;  

}


