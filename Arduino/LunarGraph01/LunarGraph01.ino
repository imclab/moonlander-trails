#include <AFMotor.h>

#include <AccelStepper.h>


#include "constants.h"
#include "DynamicMotor.h"
#include "Motors.h"
#include "Button.h"
#include "Command.h"

#include "TimerManager.h"

TimerManager timerManager; 

unsigned int state = STATE_WAITING; 

unsigned int calibrationProgressA = 0; 
unsigned int calibrationProgressB = 0; 


const int numStoredCommands = 200; 
Command commands[numStoredCommands]; 
int numCommands = 0; 
int currentCommand = 0; 

float maxJogSpeed = 2000.0f; 

boolean calibrated = false; 

Button jogUpButtonA   = Button(A_JOG_UP_PIN); 
Button jogDownButtonA = Button(A_JOG_DOWN_PIN); 
Button jogUpButtonB   = Button(B_JOG_UP_PIN); 
Button jogDownButtonB = Button(B_JOG_DOWN_PIN); 
Button resetButton    = Button(RESET_BUTTON_PIN);

Button endStopMinButtonA = Button(A_END_STOP_MIN_PIN); 
Button endStopMaxButtonA = Button(A_END_STOP_MAX_PIN); 
Button calibrationButtonA = Button(A_CALIBRATION_PIN);

#ifdef USE_TEST_MACHINE

Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN); 
Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN); 
Button calibrationButtonB = Button(B_CALIBRATION_PIN); 

#else 

Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN, false); 
Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN, false); 
Button calibrationButtonB = Button(B_CALIBRATION_PIN, false); 

#endif


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
  &calibrationButtonA, 
  &calibrationButtonB,
  &resetButton
}; 
const int NUM_BUTTONS = 11; 

void setup()  { 

  Serial.begin(115200); 
  Serial.println(""); 
  Serial.print("pagewidth:"); 
  Serial.println(pageWidth); 
  Serial.print("pageheight:"); 
  Serial.println(pageHeight); 
  Serial.print("stepspermil:"); 
  Serial.println(stepsPerMil, 20); 

  initMotors(); 
  initEndStopInterrupts(); 


  float middleX = pageWidth/2; 
  float middleY = pageHeight/2; 


  // SOME TEST COMMANDS 
  //  float numlines = 20.0f; 
  //  
  //  for(int i = 1; i<=numlines; i++) { 
  //    
  //    float distanceX = middleX * i / numlines /2; 
  //    float distanceY = middleY * i/ numlines / 2; 
  //    addCommand(0, middleX - distance, middleY - distance); 
  //    addCommand(0, middle + distance, middle - distance); 
  //    addCommand(0, middle + distance, middle + distance); 
  //    addCommand(0, middle - distance - (middle/numlines), middle + distance); 
  //    
  //  }
  //  addCommand(0, middle , 0); 

  updateButtons(); 

  // auto calibrate on start
//  if((!calibrated) && (CALIBRATABLE)) { 
//    changeState(STATE_CALIBRATING); 
//  }


  sendReady(); 

}


void addCommand(int c, float p1, float p2) { 

  // check numCommands! 

  Command* cmd = &(commands[currentCommand+numCommands]); 
  cmd->c = c; 
  cmd->p1 = p1; 
  cmd->p2 = p2; 
  //currentCommand = (currentCommand+1)%numStoredCommands; 
  numCommands++; 

  Serial.print("ADDING COMMAND ");
  Serial.print(cmd->p1); 
  Serial.print(" " ); 
  Serial.println(cmd->p2); 


}

void loop() { 
  // mechanism for doing regular updates no more than 100 times a second. 
  timerManager.update();
  checkIncoming(); 

  if(timerManager.do10msUpdate) updateButtons(); 

  if(state!=STATE_CLEARING_ENDSTOPS) {
    checkEndStops(); 
  }
  
  if(state == STATE_EMERGENCY_STOP) { 

    if(resetButton.isPressed()) { 
      changeState(STATE_CLEARING_ENDSTOPS); 
    }

  } 
  else if(state == STATE_CLEARING_ENDSTOPS) { 

    if(clearEndStops()) { 
      changeState(STATE_CALIBRATING); 
    }; 

  } 
  else if(state == STATE_CALIBRATING) { 

    updateCalibration(); 

    if((calibrationProgressA ==3) && ( calibrationProgressB ==3)) { 
      calibrated = true; 
     
      updateCartesianByLengths(); 
      changeState(STATE_WAITING);   

      Serial.print("A length");      
      Serial.print(motorPosA); 
      Serial.print(" B length :"); 
      Serial.print(motorPosB); 
      Serial.println(""); 

        
    }

  } 
  else if(state == STATE_WAITING) { 

    if(resetButton.isPressed()) { 
      changeState(STATE_CALIBRATING); 
    }
    if(timerManager.do10msUpdate) updateJogButtons(); 
    if((numCommands>0) && (motorA.currentSpeed==0) && (motorB.currentSpeed==0)) { 
      nextCommand();   

    }

  } 
  else if(state == STATE_DRAWING) { 

    updateDrawing(); 


  }

  updateMotors(); 

  if(timerManager.do100msUpdate) { 
    //    if(state == STATE_CALIBRATING) { 
    //      Serial.print(calibrationButtonA.isPressed());
    //      Serial.print(" " ); 
    //      Serial.print(calibrationButtonB.isPressed());
    //         
    //      Serial.print(" cal : "); 
    //      Serial.print(calibrationProgressA); 
    //      Serial.print(" "); 
    //      Serial.println(calibrationProgressB); 
    //    }


    //    
    //    Serial.println(state);
    //    Serial.print(" "); 
    //    Serial.println(digitalRead(B_END_STOP_MAX_PIN)); 

    //    Serial.print(motorB.currentSpeed); 
    //    Serial.print(" "); 
    //    Serial.print(motorB.accelStepper.speed()); 
    //    Serial.print(" "); 
    //    Serial.println(jogUpButtonB.isPressed()); 
    //    //Serial.println(digitalRead(B_JOG_UP_PIN));

    // Serial.println(jogUpButtonB.isPressed()); 


  }

}


boolean updateDrawing() { 

  boolean finished = false; 
  progress = (float)(micros()- startTime) / (float)duration; 

  if(progress>=1) {
    changeState(STATE_WAITING); 
    xPos = startPosX + vectorX; 
    yPos = startPosY + vectorY;  
    //drawLine(xPos, yPos, (xPos>0)? 0 : pageWidth, 0); 
    finished = true; 

  } 
  else { 
    float t = easeInOut(progress); 
    xPos = startPosX + (vectorX * t); 
    yPos = startPosY + (vectorY * t); 
  }

  setPosByCartesian(xPos, yPos); 

  while((motorA.accelStepper.currentPosition()!=motorPosA) || (motorB.accelStepper.currentPosition()!=motorPosB)) { 
    if(motorA.accelStepper.currentPosition()<motorPosA) { 
      forwardA(); 
      //motorA.accelStepper.setCurrentPosition(motorA.accelStepper.currentPosition()+1); 
    } 
    else if(motorA.accelStepper.currentPosition()>motorPosA) {
      backwardA();  
      //motorA.accelStepper.setCurrentPosition(motorA.accelStepper.currentPosition()-1); 
    }
    if(motorB.accelStepper.currentPosition()<motorPosB) { 
      forwardB();
      //motorB.accelStepper.setCurrentPosition(motorB.accelStepper.currentPosition()+1);  
    } 
    else if(motorB.accelStepper.currentPosition()>motorPosB) {
      backwardB();  
      //motorB.accelStepper.setCurrentPosition(motorB.accelStepper.currentPosition()-1);
    }    
  }

  return finished; 
  //Serial.println(progress); 

}



boolean nextCommand() { 
  if(numCommands==0) {
    sendReady();
    return false; 
  }

  Serial.print("NEXT COMMAND "); 
  Serial.print(numCommands); 
  Serial.print(" " ); 

  Command * c = &(commands[currentCommand]); 


  Serial.print(currentCommand); 

  Serial.print(" "); 
  Serial.print(c->p1); 
  Serial.print(" "); 
  Serial.print(c->p2); 
  Serial.println(" " ); 


  currentCommand = (currentCommand+1)%numStoredCommands; 

  numCommands--; 


  moveTo(c->p1, c->p2); 

  sendReady();

  return true; 


}


void updateMotors() { 
  motorA.update(timerManager.do33msUpdate); 
  motorB.update(timerManager.do33msUpdate); 
}


void lineTo(float x, float y) { 
  // pendown
  moveStraight(x, y); 


}
void moveTo(float x, float y) { 
  //penup
  moveStraight(x, y); 


}

void moveStraight(float x2, float y2) {

  updateCartesianByLengths();

  if(x2<0) x2 = 0; 
  else if(x2>pageWidth) x2 = pageWidth; 
  if(y2<0) y2 = 0; 
  else if(y2>pageHeight) y2 = pageHeight; 

  startPosX = xPos; 
  startPosY = yPos; 
  vectorX = x2-xPos; 
  vectorY = y2-yPos; 

  duration = max(sqrt(sq(vectorX) + sq(vectorY)), 50.0f*stepsPerMil)  * drawSpeed; // in micros

  progress  = 0; 
  startTime = micros(); 

  changeState(STATE_DRAWING); 


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

boolean clearEndStops() { 


  boolean endStopsClear = true; 

  if(endStopMinButtonA.isPressed()) {

    motorA.setSpeed(500); 
    endStopsClear = false; 
  } 
  else if(endStopMaxButtonA.isPressed()) {

    motorA.setSpeed(-500); 
    endStopsClear = false; 
  } 
  else { 
    motorA.stop();  

  }

  if(endStopMinButtonB.isPressed()) {

    motorB.setSpeed(500); 
    endStopsClear = false; 
  } 
  else if(endStopMaxButtonB.isPressed()) {

    motorB.setSpeed(-500); 
    endStopsClear = false; 
  } 
  else { 
    motorB.stop();  

  }

  return endStopsClear; 


}

boolean changeState(int newState) { 
  if(state == newState) return false; 

  state = newState; 
  motorA.stop(); 
  motorB.stop(); 


  if(state == STATE_CALIBRATING) { 

    if(calibrationButtonA.isPressed()) { 
      calibrationProgressA = 0; 
    } 
    else { 
      calibrationProgressA = 1; 
    }

    if(calibrationButtonB.isPressed()) { 
      calibrationProgressB = 0; 
    } 
    else { 
      calibrationProgressB = 1; 
    }



  }  

  Serial.print("CHANGE STATE : ");   
  Serial.println(stateStrings[state]);

  Serial.print(calibrationProgressA); 
  Serial.print(" "); 
  Serial.println(calibrationProgressB); 

  return true; 
}


void updateButtons() {  

  for(int i = 0; i< NUM_BUTTONS; i++) { 
    buttons[i]->update(); 
  }

}


void updateJogButtons() { 


  if(jogUpButtonA.isPressed()) { 

    motorA.setSpeedDirect(mapEaseInOut((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed)); 

  } 
  else if(jogDownButtonA.isPressed()) { 
    motorA.setSpeedDirect(mapEaseInOut((float)jogDownButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed)); 
  } 
  else { 

    motorA.stop(); 

  }


  if(jogUpButtonB.isPressed()) { 
    motorB.setSpeedDirect(mapEaseInOut((float)jogUpButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed)); 
  } 
  else if(jogDownButtonB.isPressed()) { 
    motorB.setSpeedDirect(mapEaseInOut((float)jogDownButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed)); 
  } 
  else { 
    motorB.stop(); 
  }



  if(timerManager.do100msUpdate) { 
    // trace stuff out here if necessary
  }

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








