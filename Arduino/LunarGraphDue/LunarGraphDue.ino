// NOTE - I've hacked TC_FREQUENCY in 
// https://github.com/arduino/Arduino/blob/ide-1.5.x/hardware/arduino/sam/variants/arduino_due_x/variant.h#L182 to make
// the solenoids less ringy. Changed to 15000
//#define EMULATION_MODE // USE WITH CAUTION!!!!!!!

#include <AccelStepper.h>


#include "constants.h"
#include "DynamicMotor.h"
#include "Motors.h"f
#include "Button.h"
#include "Command.h"

#include "TimerManager.h"

TimerManager timerManager;

volatile unsigned int state = STATE_WAITING;

unsigned int calibrationProgressA = 0;
unsigned int calibrationProgressB = 0;

const int numStoredCommands = 200;
Command commands[numStoredCommands];
// the number of commands in the buffer
int numCommands = 0;
// the latest command number
int currentCommand = 0;


float maxJogSpeed = 3200.0f;

boolean calibrated = false;
boolean errorEndStopHit = false;
boolean errorMotorDrive = false;
boolean penIsUp = true;
unsigned long penDownStartTime = 0;

// time (in mils?) to wait before assuming the pen is down.
int penMoveDownTime = 300;
int penMoveUpTime = 300;

boolean justCalibrated = false;

volatile float startPosX = 0;
volatile float startPosY = 0;
volatile float vectorX = 0;
volatile float vectorY = 0;
volatile float progress = 0;
volatile boolean easing = true;
volatile float duration = 0;
volatile unsigned long startTime;

unsigned long lastHeartbeatSent = 0;
float lastXSent = 0;
float lastYSent = 0;

unsigned long stateChangeTime;

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

boolean leftUpPressed = false;
boolean leftDownPressed = false;
boolean rightUpPressed = false;
boolean rightDownPressed = false;
boolean resetPressed = false;
boolean togglePenPressed = false;



volatile unsigned long ticks; // 10ths of a mil

//TC1 ch 0
void TC3_Handler()
{
  TC_GetStatus(TC1, 0);
  ticks ++;
  //digitalWrite(13, l = !l);
  //if(state == STATE_DRAWING) updateDrawing();
}

void startTimer(Tc *tc, uint32_t channel, IRQn_Type irq, uint32_t frequency) {
  pmc_set_writeprotect(false);
  pmc_enable_periph_clk((uint32_t)irq);
  TC_Configure(tc, channel, TC_CMR_WAVE | TC_CMR_WAVSEL_UP_RC | TC_CMR_TCCLKS_TIMER_CLOCK4);
  uint32_t rc = VARIANT_MCK / 128 / frequency; //128 because we selected TIMER_CLOCK4 above
  TC_SetRA(tc, channel, rc / 2); //50% high, 50% low
  TC_SetRC(tc, channel, rc);
  TC_Start(tc, channel);
  tc->TC_CHANNEL[channel].TC_IER = TC_IER_CPCS;
  tc->TC_CHANNEL[channel].TC_IDR = ~TC_IER_CPCS;
  NVIC_EnableIRQ(irq);
}


//-------------------------------------------------SET UP -----------------------------------------

void setup()  {

  pinMode(13, OUTPUT);
  startTimer(TC1, 0, TC3_IRQn, 10000); //TC1 channel 0, the IRQ for that channel and the desired frequency



  Serial.begin(115200);
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
  initIR();

  float middleX = pageWidth / 2;
  float middleY = pageHeight / 2;


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
  //if((!calibrated) && (CALIBRATABLE)) {
  //  changeState(STATE_CALIBRATING);
  //}

  pinMode(PEN_DROP_PIN, OUTPUT);
  digitalWrite(PEN_DROP_PIN, LOW);
  penIsUp = true;

  // WHAT IS THIS?
  //pinMode(19, OUTPUT);
  //digitalWrite(19,LOW);
  Serial.print("motors : "); 
  Serial.print(motorPosA); 
  Serial.print(" " ); 
  Serial.println(motorPosB); 
  sendReady();
 
}

//-------------------------------------------------LOOP -----------------------------------------

void loop() {

  // mechanism for doing regular updates no more than 100 times a second.
  timerManager.update();

  // i suspect this could  be taking a bit of time... the bit that parses the data
  checkIncoming();
  //checkIR();
  if (checkIR())  {
    // if checkIR returns true then it means that a button has come on or off.
    if (togglePenPressed) {

      if (!penIsUp) liftPenUp();
      else pushPenDown();

    }
  }



  if (timerManager.do10msUpdate) {
    updateButtons();
    checkEndStops();
    checkMotorErrors();

    if (!penIsUp) {
      int timeSincePenDown = millis() - penDownStartTime;
      // full strength for 500 mils, then ease in-out to low strength after 2 seconds
      float strength;

      float minPower = 0.4;
      float maxPower = 0.9;
      // ramp up to full strength for the penMoveDownTime/2, then ease in-out to low strength after 2 seconds
      if (timeSincePenDown < penMoveDownTime) {
        strength = mapFloat((float)timeSincePenDown, 0.0f, (float)penMoveDownTime, 0.0, maxPower);
        //Serial.println(strength);
        analogWrite(PEN_DROP_PIN, int(strength * 255.0f));
      } else if (timeSincePenDown<4000){
        strength = constrain(mapEaseInOut(timeSincePenDown, 2000, 4000, maxPower, minPower), minPower, maxPower);
        analogWrite(PEN_DROP_PIN, int(strength * 255.0f));
        //Serial.println(strength);
      }
            
    }

    if ((state != STATE_RESETTING) & (errorEndStopHit || errorMotorDrive)) {
      //if((state!=STATE_RESETTING) &(errorMotorDrive)) {
      if (changeState(STATE_ERROR)) {
        Serial.print("ERROR:");
        if (errorEndStopHit) {
          Serial.print("endstop hit ");
        }
        if (errorMotorDrive) {
          Serial.print("motor drive ");
          Serial.print(motorA.errorState);
          Serial.print(" " );
          Serial.print(motorB.errorState);
        }
        Serial.println("");
      }
    }


  }




  if (state == STATE_ERROR) {

    if (resetPressed) {
      changeState(STATE_RESETTING);
      if (motorError) {
        resetMotors(); 
        autoResetCount = 0; 
      }
     // if  motorB.reset();
    }

  }
  else if (state == STATE_RESETTING) {

    int errorcount = 0;
    // END STOP ERROR :
    if (errorEndStopHit) {

      if (!clearEndStops()) errorcount++;

    }

    // MOTOR FAULT ERROR
    if (errorMotorDrive) {
      errorcount++;
    }

    if (errorcount == 0) {
      if (CALIBRATABLE) changeState(STATE_CALIBRATING);
      else changeState(STATE_WAITING);
      //changeState(STATE_WAITING);

    }
  }
  else if (state == STATE_CALIBRATING) {

    updateCalibration();

    if ((calibrationProgressA == 3) && ( calibrationProgressB == 3)) {
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
  else if (state == STATE_WAITING) {

    // TODO - IMPLEMENT RESET BUTTON IN IR CONTROL
    if (resetPressed & CALIBRATABLE) {
      changeState(STATE_CALIBRATING);
    }
    if (timerManager.do10msUpdate) {
      // TODO - stop pen lifting!
      //if (millis() - stateChangeTime > 5000) liftPenUp();

      updateJogButtons();
    }
    if ((numCommands > 0) && (motorA.currentSpeed == 0) && (motorB.currentSpeed == 0)) {
      updateCartesianByLengths();
      nextCommand();

    }

  }
  else if (state == STATE_DRAWING) {

    if (updateDrawing()) {

      if (numCommands > 0) nextCommand();
      else {
        changeState(STATE_WAITING);
        sendReady();
      }
    }

    /*
    if (progress >= 1) {

      if (numCommands > 0) nextCommand();
      else {
        changeState(STATE_WAITING);
        sendReady();
      }

    }*/


  }

  updateMotors(timerManager.do33msUpdate);

  //updateCartesianByLengths();
  // TODO : FIGURE OUT HOW TO STOP THIS UPDATING IF NOTHING IS HAPPENING!

  if (timerManager.do10msUpdate) {

    if (millis() - lastHeartbeatSent > 5000) {

      lastHeartbeatSent = millis();
      sendReady();


    }



    //updateCartesianByLengths();

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


  // This is the function that handles the drawing of a line.

  unsigned long microsecs = ticks * 100;
  //if (startTime > micros()) return false;
  if (startTime > microsecs) return false;
  boolean finished = false;
  // progress = (float)(micros() - startTime) / (float)duration;
  progress = (float)(microsecs - startTime) / (float)duration;

  if (progress < 0) progress = 0;

  if (progress >= 1) {

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
    if (easing)
      t = easeInOut(progress);
    else
      t = progress;
    xPos = startPosX + (vectorX * t);
    yPos = startPosY + (vectorY * t);
  }

  setPosByCartesian(xPos, yPos);




  while ((motorA.accelStepper.currentPosition() != motorPosA) || (motorB.accelStepper.currentPosition() != motorPosB)) {
    if (motorA.accelStepper.currentPosition() < motorPosA) {
      forwardA();
    }
    else if (motorA.accelStepper.currentPosition() > motorPosA) {
      backwardA();
    }
    if (motorB.accelStepper.currentPosition() < motorPosB) {
      forwardB();
    }
    else if (motorB.accelStepper.currentPosition() > motorPosB) {
      backwardB();
    }
  }

  return finished;
  //Serial.println(progress);

}


void lineTo(float x, float y) {
  // pendown
  if (justCalibrated || (!penIsUp)) {
    moveStraight(x, y, 0, 1, true);
    justCalibrated = false;
  }
  else {
    pushPenDown();
    moveStraight(x, y, penMoveDownTime, 1, true);
  }


}
void lineToDirect(float x, float y) {
  // pendown
  if (justCalibrated) {
    justCalibrated = false;
    moveStraight(x, y, 0, 1, true);
  } else if (!penIsUp) {
    moveStraight(x, y, 0, 1, false);
  } else {

    pushPenDown();
    moveStraight(x, y, penMoveDownTime, 1, false);
  }





}

void moveTo(float x, float y) {
  //penup
  if (liftPenUp()) {
    moveStraight(x, y, penMoveUpTime, 0.5, true);
  }
  else {

    moveStraight(x, y, 0, 0.5, true);
  }

}

void moveStraight(float x2, float y2, int delayMils, float speedMult, boolean useEaseInOut) {

  justCalibrated = false;

  updateCartesianByLengths();

  if (x2 < 0) x2 = 0;
  else if (x2 > pageWidth) x2 = pageWidth;
  if (y2 < 0) y2 = 0;
  else if (y2 > pageHeight) y2 = pageHeight;

  startPosX = xPos;
  startPosY = yPos;
  vectorX = x2 - xPos;
  vectorY = y2 - yPos;


  easing = useEaseInOut;

  if (easing) duration = max(sqrt(sq(vectorX) + sq(vectorY)), 50.0f * stepsPerMil)  * drawSpeed * speedMult; // in micros
  else  duration = max(sqrt(sq(vectorX) + sq(vectorY)), 10.0f * stepsPerMil)  * drawSpeed * speedMult; // in micros

  progress  = 0;

  unsigned long delayMicros =  (unsigned long)(delayMils) * 1000;

  unsigned long now = ticks * 100; // micros();
  startTime = now +  delayMicros;// + delayMicros;

  // if we're going over the maximum value storable in a ulong, best start over
  if (startTime < now) {
    startTime = 0;
    Serial.println("CLOCK RESETTING -----------------------");
  }

  //  Serial.print("Now:");
  //  Serial.print(micros());
  //  Serial.print(" delay:");
  //  Serial.println(delayMicros);
  changeState(STATE_DRAWING);

}


boolean liftPenUp() {
  if (!penIsUp) {
    analogWrite(PEN_DROP_PIN, 0);
    penIsUp = true;
    return true;
  }
  else {
    return false;
  }
}


boolean pushPenDown() {
  if (penIsUp) {
    //analogWrite(PEN_DROP_PIN, 80);
    penDownStartTime = millis();
    penIsUp = false;
    return true;
  }
  else {
    return false;
  }
}

void checkEndStops() {

#ifdef EMULATION_MODE
  return;
#endif
  if ( (endStopMinButtonA.isOn()) ||
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

  if (motorError) { // (motorA.errorState) || (motorB.errorState)) {
    errorMotorDrive = true;
    //changeState(STATE_ERROR);
  }
  else {
    errorMotorDrive = false;
  }

#ifdef EMULATION_MODE
  errorMotorDrive = false;
#endif

}

boolean clearEndStops() {


  boolean endstopsclear = true;

  if (endStopMinButtonA.isOn()) {

    motorA.setSpeed(500);
    endstopsclear = false;
  }
  else if (endStopMaxButtonA.isOn()) {

    motorA.setSpeed(-500);
    endstopsclear = false;
  }
  else {
    motorA.stop();

  }

  if (endStopMinButtonB.isOn()) {

    motorB.setSpeed(500);
    endstopsclear = false;
  }
  else if (endStopMaxButtonB.isOn()) {

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
  if (state == newState) return false;

  state = newState;
  motorA.stop();
  motorB.stop();

  if ((state != STATE_WAITING) && (state != STATE_DRAWING)) {

    liftPenUp();


  }

  if (state == STATE_CALIBRATING) {

    if (calibrationButtonA.isOn()) {
      calibrationProgressA = 0;
    }
    else {
      calibrationProgressA = 1;
    }

    if (calibrationButtonB.isOn()) {
      calibrationProgressB = 0;
    }
    else {
      calibrationProgressB = 1;
    }

    // justCalibrated = true;

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
  for (int i = 0; i < NUM_BUTTONS; i++) {
    if ( buttons[i]->update() ) changed = true;
  }

  if (changed) {
    // send button data...
    Serial.print("buttons:");
    for (int i = 0; i < NUM_BUTTONS; i++) {
      if (buttons[i]->isOn()) Serial.print("1");
      else Serial.print("0");

    }
    Serial.println("");
  }
}


void updateJogButtons() {

  // TODO - IMPLEMENT JOG BUTTONS IN IR
  //
  //  if(jogUpButtonA.isOn()) {
  //    motorA.setSpeedDirect(mapEaseInOut((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed));
  //  }
  //  else if(jogDownButtonA.isOn()) {
  //    motorA.setSpeedDirect(mapEaseInOut((float)jogDownButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed));
  //  }
  //  else {
  //    motorA.stop();
  //  }
  //
  //
  //  if(jogUpButtonB.isOn()) {
  //    motorB.setSpeedDirect(mapEaseInOut((float)jogUpButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed));
  //  }
  //  else if(jogDownButtonB.isOn()) {
  //    motorB.setSpeedDirect(mapEaseInOut((float)jogDownButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed));
  //  }
  //  else {
  //    motorB.stop();
  //  }


  if (leftUpPressed) {
    motorA.setSpeedDirect(-maxJogSpeed); //mapEaseInOut((float)jogUpButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed));
  }
  else if (leftDownPressed) {
    motorA.setSpeedDirect(maxJogSpeed); // mapEaseInOut((float)jogDownButtonA.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed));
  }
  else {
    motorA.stop();
  }


  if (rightUpPressed) {
    motorB.setSpeedDirect(-maxJogSpeed);//mapEaseInOut((float)jogUpButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, -maxJogSpeed));
  }
  else if (rightDownPressed) {
    motorB.setSpeedDirect(maxJogSpeed); //mapEaseInOut((float)jogDownButtonB.getTimeSinceChange(), 0.0f, 2000.0f, 0.0f, maxJogSpeed));
  }
  else {
    motorB.stop();
  }

  if (timerManager.do100msUpdate) {
    // trace stuff out here if necessary
  }

}









