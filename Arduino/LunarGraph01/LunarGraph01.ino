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

float maxJogSpeed = 3200.0f; 

boolean calibrated = false; 
boolean errorEndStopHit = false; 
boolean errorMotorDrive = false; 
boolean penIsUp = true; 
int penMoveDownTime = 500; 
int penMoveUpTime = 200; 

boolean justCalibrated = false; 

float startPosX = 0;
float startPosY = 0;  
float vectorX = 0; 
float vectorY = 0; 
float progress = 0; 
boolean easing = true;
float duration = 0; 
unsigned long startTime; 

unsigned long stateChangeTime; 

Button jogUpButtonA   = Button(A_JOG_UP_PIN); 
Button jogDownButtonA = Button(A_JOG_DOWN_PIN); 
Button jogUpButtonB   = Button(B_JOG_UP_PIN); 
Button jogDownButtonB = Button(B_JOG_DOWN_PIN); 
Button resetButton    = Button(RESET_BUTTON_PIN);
Button spareButton    = Button(SPARE_BUTTON_PIN);

Button endStopMinButtonA = Button(A_END_STOP_MIN_PIN, false, HIGH); 
Button endStopMaxButtonA = Button(A_END_STOP_MAX_PIN, false, HIGH); 
Button calibrationButtonA = Button(A_CALIBRATION_PIN, false, HIGH);

//#ifdef USE_TEST_MACHINE
//
//Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN); 
//Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN); 
//Button calibrationButtonB = Button(B_CALIBRATION_PIN); 
//
//#else 

Button endStopMinButtonB = Button(B_END_STOP_MIN_PIN, false, HIGH); 
Button endStopMaxButtonB = Button(B_END_STOP_MAX_PIN, false); 
Button calibrationButtonB = Button(B_CALIBRATION_PIN, false); 

//#endif


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
  &resetButton,
  &spareButton
}; 
const int NUM_BUTTONS = 12; 

void setup()  { 

  Serial.begin(38400); 
  Serial.println("RESTARTING -----------------------------"); 
  Serial.print("pagewidth:"); 
  Serial.println(pageWidth); 
  Serial.print("pageheight:"); 
  Serial.println(pageHeight); 
  Serial.print("stepspermil:"); 
  Serial.println(stepsPerMil, 20); 
  Serial.print("pagetop:"); 
  Serial.println(pageTop); 

  initMotors(); 

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

#ifndef USE_TEST_MACHINE
  changeState(STATE_RESETTING); 

#endif
  // auto calibrate on start
  //  if((!calibrated) && (CALIBRATABLE)) { 
  //    changeState(STATE_CALIBRATING); 
  //  }

  pinMode(PEN_DROP_PIN, OUTPUT); 
  digitalWrite(PEN_DROP_PIN, LOW); 
  penIsUp = true; 

  // WHAT IS THIS? 
  //pinMode(19, OUTPUT); 
  //digitalWrite(19,LOW); 

  sendReady(); 

}


void loop() { 
  // mechanism for doing regular updates no more than 100 times a second. 
  timerManager.update();
  checkIncoming(); 

  if(timerManager.do10msUpdate) {
    updateButtons(); 
    checkEndStops(); 
    checkMotorErrors(); 

    if((state!=STATE_RESETTING) &(errorEndStopHit || errorMotorDrive)) {
    //if((state!=STATE_RESETTING) &(errorMotorDrive)) {
      if(changeState(STATE_ERROR)) {  
        Serial.print("ERROR:"); 
        if(errorEndStopHit) { 
          Serial.print("endstop hit "); 
        } 
        if(errorMotorDrive) { 
          Serial.print("motor drive ");
          Serial.print(motorA.errorState);
          Serial.print(" " ); 
          Serial.print(motorB.errorState);
        }
        Serial.println(""); 
      }
    }


  }




  if(state == STATE_ERROR) { 

    if(resetButton.isOn()) { 
      changeState(STATE_RESETTING);
      if(motorA.errorState) motorA.reset(); 
      if(motorB.errorState) motorB.reset(); 
    }

  } 
  else if(state == STATE_RESETTING) { 

    int errorcount = 0; 
    // END STOP ERROR : 
    if(errorEndStopHit){

      if(!clearEndStops()) errorcount++;

    } 

    // MOTOR FAULT ERROR
    if(errorMotorDrive) { 
      errorcount++; 
    }

    if(errorcount==0) {
      if(CALIBRATABLE) changeState(STATE_CALIBRATING); 
      else changeState(STATE_WAITING);  

    }
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
    
    
    if(resetButton.isOn() & CALIBRATABLE) { 
      changeState(STATE_CALIBRATING); 
    }
    if(timerManager.do10msUpdate) {
      if(millis() - stateChangeTime > 5000) liftPenUp(); 
    
      updateJogButtons();
    } 
    if((numCommands>0) && (motorA.currentSpeed==0) && (motorB.currentSpeed==0)) { 
      updateCartesianByLengths(); 
      nextCommand();   

    }

  } 
  else if(state == STATE_DRAWING) { 

    if(updateDrawing()) {

      if(numCommands>0) nextCommand();   
      else changeState(STATE_WAITING); 

    }



  }

  updateMotors(); 

  if(timerManager.do100msUpdate) { 
    //    if(state == STATE_CALIBRATING) { 
    //      Serial.print(calibrationButtonA.isOn());
    //      Serial.print(" " ); 
    //      Serial.print(calibrationButtonB.isOn());
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
    //    Serial.println(jogUpButtonB.isOn()); 
    //    //Serial.println(digitalRead(B_JOG_UP_PIN));

    // Serial.println(jogUpButtonB.isOn()); 


  }
  
  //digitalWrite(PEN_DROP_PIN, digitalRead(SPARE_BUTTON_PIN)); 

}


boolean updateDrawing() { 

  if(startTime>micros()) return false; 
  boolean finished = false; 
  progress = (float)(micros()- startTime) / (float)duration; 

  if(progress>=1) {

    //if(numCommands==0) {
    //changeState(STATE_WAITING); 
    //  liftPenUp(); 
    //}
    xPos = startPosX + vectorX; 
    yPos = startPosY + vectorY;  
    //drawLine(xPos, yPos, (xPos>0)? 0 : pageWidth, 0); 
    finished = true; 

  } 
  else { 
    float t; 
    if(easing) 
      t = easeInOut(progress); 
    else 
      t = progress; 
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

void updateMotors() { 
  motorA.update(timerManager.do33msUpdate); 
  motorB.update(timerManager.do33msUpdate); 
}


void lineTo(float x, float y) { 
  // pendown
  if(justCalibrated || (!penIsUp)) {
     moveStraight(x, y, 0,1, true); 
  } 
  else { 
    pushPenDown(); 
    moveStraight(x, y, penMoveDownTime, 1, true); 
  } 


}
void lineToDirect(float x, float y) { 
  // pendown
  if(justCalibrated || (!penIsUp)) {
    moveStraight(x, y, 0, 1, false); 
  } else { 
    
    pushPenDown(); 
    moveStraight(x, y, penMoveDownTime, 1, false); 
  } 
    

  


}

void moveTo(float x, float y) { 
  //penup
  if(liftPenUp()) {  
    moveStraight(x, y, penMoveUpTime, 0.5, true); 
  } 
  else { 

    moveStraight(x, y, 0, 0.5, true); 
  }

}

void moveStraight(float x2, float y2, int delayMils, float speedMult, boolean useEaseInOut) {
  
  justCalibrated = true; 
  
  updateCartesianByLengths();

  if(x2<0) x2 = 0; 
  else if(x2>pageWidth) x2 = pageWidth; 
  if(y2<0) y2 = 0; 
  else if(y2>pageHeight) y2 = pageHeight; 

  startPosX = xPos; 
  startPosY = yPos; 
  vectorX = x2-xPos; 
  vectorY = y2-yPos; 


  easing = useEaseInOut;

  if (easing) duration = max(sqrt(sq(vectorX) + sq(vectorY)), 100.0f*stepsPerMil)  * drawSpeed * speedMult; // in micros
  else  duration = max(sqrt(sq(vectorX) + sq(vectorY)), 10.0f*stepsPerMil)  * drawSpeed * speedMult; // in micros

  progress  = 0; 
  
   unsigned long delayMicros =  (unsigned long)(delayMils)*1000; 

  startTime = micros() +  delayMicros;// + delayMicros; 

  //  Serial.print("Now:"); 
  //  Serial.print(micros());
  //  Serial.print(" delay:");  
  //  Serial.println(delayMicros); 
  changeState(STATE_DRAWING); 

}


boolean liftPenUp() { 
  if(!penIsUp) { 
    digitalWrite(PEN_DROP_PIN, LOW); 
    penIsUp = true; 
    return true; 
  } 
  else { 
    return false; 
  }
} 


boolean pushPenDown() { 
  if(penIsUp) {
    digitalWrite(PEN_DROP_PIN, HIGH); 
    penIsUp = false; 
    return true; 
  } 
  else { 
    return false; 
  }
}

void checkEndStops() { 

  if( (endStopMinButtonA.isOn()) ||
    (endStopMaxButtonA.isOn()) ||
    (endStopMinButtonB.isOn()) ||
    (endStopMaxButtonB.isOn()) ) {

    errorEndStopHit = true; 

    //    if(changeState(STATE_ERROR)){  
    //
    //      Serial.print(endStopMinButtonA.isOn()) ;
    //      Serial.print(" "); 
    //      Serial.print(endStopMaxButtonA.isOn()) ;
    //      Serial.print(" "); 
    //      Serial.print(endStopMinButtonB.isOn()) ;
    //      Serial.print(" "); 
    //      Serial.println(endStopMaxButtonB.isOn()) ;
    //    }
  } 
  else { 
    errorEndStopHit = false;  

  }

}

void checkMotorErrors() { 

  if((motorA.errorState) || (motorB.errorState)) {
    errorMotorDrive = true; 
    //changeState(STATE_ERROR); 
  } 
  else {
    errorMotorDrive = false; 
  }


}

boolean clearEndStops() { 


  boolean endstopsclear = true; 

  if(endStopMinButtonA.isOn()) {

    motorA.setSpeed(500); 
    endstopsclear = false; 
  } 
  else if(endStopMaxButtonA.isOn()) {

    motorA.setSpeed(-500); 
    endstopsclear = false; 
  } 
  else { 
    motorA.stop();  

  }

  if(endStopMinButtonB.isOn()) {

    motorB.setSpeed(500); 
    endstopsclear = false; 
  } 
  else if(endStopMaxButtonB.isOn()) {

    motorB.setSpeed(-500); 
    endstopsclear = false; 
  } 
  else { 
    motorB.stop();  

  }

  if (endstopsclear) { 
    errorEndStopHit = false; 
  } 
  else { 
    errorEndStopHit = true; 
  }
  return endstopsclear; 


}

boolean changeState(int newState) { 
  if(state == newState) return false; 
  
  state = newState; 
  motorA.stop(); 
  motorB.stop(); 

  if((state!=STATE_WAITING) && (state!=STATE_DRAWING)) { 
    
    liftPenUp(); 
    
    
  }

  if(state == STATE_CALIBRATING) { 
    
    if(calibrationButtonA.isOn()) { 
      calibrationProgressA = 0; 
    } 
    else { 
      calibrationProgressA = 1; 
    }

    if(calibrationButtonB.isOn()) { 
      calibrationProgressB = 0; 
    } 
    else { 
      calibrationProgressB = 1; 
    }
    
    justCalibrated = true; 
    
  }  

  Serial.print("CHANGE STATE:");   
  Serial.print(state); 
  Serial.print(","); 
  Serial.println(stateStrings[state]);
  
  stateChangeTime = millis(); 
  
  return true; 
}


void updateButtons() {  
  boolean changed = false; 
  for(int i = 0; i< NUM_BUTTONS; i++) { 
    if( buttons[i]->update() ) changed = true;  
  }

  if(changed) { 
    // send button data...  
    Serial.print("buttons:"); 
    for(int i = 0; i< NUM_BUTTONS; i++) { 
      Serial.print(buttons[i]->isOn()); 
    }
    Serial.println(""); 
  }
}


void updateJogButtons() { 


  if(jogUpButtonA.isOn()) { 
    motorA.setSpeedDirect(mapEaseInOut((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed)); 
  } 
  else if(jogDownButtonA.isOn()) { 
    motorA.setSpeedDirect(mapEaseInOut((float)jogDownButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed)); 
  } 
  else { 
    motorA.stop(); 
  }


  if(jogUpButtonB.isOn()) { 
    motorB.setSpeedDirect(mapEaseInOut((float)jogUpButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed)); 
  } 
  else if(jogDownButtonB.isOn()) { 
    motorB.setSpeedDirect(mapEaseInOut((float)jogDownButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed)); 
  } 
  else { 
    motorB.stop(); 
  }



  if(timerManager.do100msUpdate) { 
    // trace stuff out here if necessary
  }

}









