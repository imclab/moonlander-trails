
DynamicMotor motorA;
DynamicMotor motorB;


volatile float stepsPerRev = 2000.0f * 36.0f / 19.0f;
// mm :
volatile float diameter = 32.0f + 0.6f;
volatile float circumference = diameter * PI;
volatile float stepsPerMil = stepsPerRev / circumference;

// dimensions in steps
volatile float machineWidth = 2740.0f * stepsPerMil; // 2675.0f * stepsPerMil;
volatile float pageTop = 350.0f * stepsPerMil;
volatile float sideMargin = 450.0f * stepsPerMil;
volatile float pageWidth = machineWidth - (sideMargin * 2);
volatile float pageHeight = pageWidth * 0.70;

int resetOutPin;
int autoResetCount;

boolean motorError;
boolean motorsResetting;
unsigned long resetStartTime;
unsigned long lastResetTime;





// draw speed is the number of steps per something?
#ifdef EMULATION_MODE
volatile float drawSpeed = 280;
#else
volatile float drawSpeed = 280;// 280;
#endif

// caibration point only for actual machine

volatile long calibrationLengthA = round(1560.0f * stepsPerMil); //round(1565.0f * stepsPerMil);
volatile long calibrationLengthB = round(1530.0f * stepsPerMil); //round(1545.0f * stepsPerMil);

volatile double xPos = 0;
volatile double yPos = 0;

volatile long motorPosA = calibrationLengthA; //round (sqrt( sq(machineWidth/2) + sq(pageTop)));
volatile long motorPosB = calibrationLengthB; //round (sqrt( sq(machineWidth/2) + sq(pageTop)));


void resetMotors() {
  motorsResetting = true;
  resetStartTime = millis();
  lastResetTime = millis();
  pinMode(BOTH_RESET_PIN, OUTPUT);
  digitalWrite(BOTH_RESET_PIN, HIGH);
  Serial.println("MOTOR RESET");
}

void finishResetting() {

  motorA.finishResetting();
  motorB.finishResetting();
  motorError = false;
  motorsResetting = false;

  //pinMode(resetOutPin, INPUT);
  
  Serial.println("MOTOR RESET FINISHED");
}



void updateMotors(bool do33msUpdate) {
  motorA.update(do33msUpdate);
  motorB.update(do33msUpdate);



  if (do33msUpdate) {
    if (motorsResetting) {
      if(millis() - resetStartTime > 3000) {
         motorA.setSpeedDirect(0);
        motorB.setSpeedDirect(0); 
        finishResetting();
      } else if(millis() - resetStartTime > 2200) {
        motorA.setSpeedDirect(-100);
        motorB.setSpeedDirect(-100); 
      }
      else if (millis() - resetStartTime > 2000) {
        digitalWrite(BOTH_RESET_PIN, LOW); 
      }

    } else if (!motorError) {

      if (motorA.errorState || motorB.errorState) {
        motorError = true;
        // retry after five minutes?
        //if (millis() - lastResetTime > 5 * 60 * 1000 ) { // five minutes
        //  autoResetCount = 0;
        //}
        autoResetCount++;

        if (autoResetCount <= 3) {
          Serial.print("MOTOR ERROR - auto reset ");
          Serial.println(autoResetCount);
          resetMotors();
        } else {
          Serial.println("MOTOR ERROR");
        }
      }
    }
  }

  //motorError = (motorA.errorState || motorB.errorState);

}


long setPosByCartesian(float x, float y) {

  motorPosA = round(sqrt(sq(x + sideMargin) + sq(y + pageTop)));
  motorPosB = round(sqrt(sq(machineWidth - (x + sideMargin)) + sq(y + pageTop)));

}

void updateCartesianByLengths() {
  motorPosA = motorA.accelStepper.currentPosition();
  motorPosB = motorB.accelStepper.currentPosition();
  xPos = (sq(machineWidth * 0.01) - sq(motorPosB * 0.01) + sq(motorPosA * 0.01)) / (machineWidth * 0.01 * 2);
  //Serial.print("XPOS: ");
  //Serial.println(xPos);

  // to try to avoid NaN
  float value = sq(motorPosA * 0.01) - sq(xPos);
  if (value < 0) value = 0;
  yPos = sqrt(value);
  //Serial.print("YPOS: ");
  //Serial.println(value);
  xPos *= 100;
  yPos *= 100;
  xPos -= sideMargin;
  yPos -= pageTop;

  //  Serial.print("xPos:");
  //  Serial.print(xPos);
  //  Serial.print(" yPos:" );
  //  Serial.print(yPos);
  //  Serial.print(" lengthA:");
  //  Serial.print(motorPosA);
  //  Serial.print(" lengthB:");
  //  Serial.print(motorPosB);
  //  Serial.println("");

}



void forwardA() {
  motorA.accelStepper.stepForward();
}

void backwardA() {
  motorA.accelStepper.stepBackward();
}

void forwardB() {
  motorB.accelStepper.stepForward();
}

void backwardB() {
  motorB.accelStepper.stepBackward();
}


void initMotors() {



  motorA.initGecko(A_STEP_PIN, A_DIR_PIN, A_ERROR_PIN, A_BRAKE_PIN);
  motorB.initGecko(B_STEP_PIN, B_DIR_PIN, B_ERROR_PIN, B_BRAKE_PIN);

  motorError = true;
  motorsResetting = false;
  lastResetTime = millis();
  autoResetCount = 0;
  resetOutPin = BOTH_RESET_PIN;


  // reverse motorB so that it turns the same way to increase the length
  motorB.accelStepper.setPinsInverted(true, false);


  motorA.accelStepper.setCurrentPosition(motorPosA);
  motorB.accelStepper.setCurrentPosition(motorPosB);

  resetMotors();


  updateCartesianByLengths();

}




