
DynamicMotor motorA; 
DynamicMotor motorB; 

#ifdef USE_TEST_MACHINE 

float stepsPerRev = 800.0f; 
// mm : 
float diameter = 32.0f;
float circumference = diameter * PI; 
float stepsPerMil = stepsPerRev/circumference; 

// dimensions in steps 
float machineWidth = 495.0f * stepsPerMil;  
float pageTop = 115.0f * stepsPerMil; 
float sideMargin = 100.0f * stepsPerMil; 
float pageWidth = machineWidth - (sideMargin*2); 
float pageHeight = pageWidth; 

float drawSpeed = 1000; 

#else

float stepsPerRev = 2000.0f * 36.0f / 19.0f; 
// mm : 
float diameter = 32.0f + 0.6f;
float circumference = diameter * PI; 
float stepsPerMil = stepsPerRev/circumference; 

// dimensions in steps 
float machineWidth = 2675.0f * stepsPerMil;  
float pageTop = 300.0f * stepsPerMil; 
float sideMargin = 350.0f * stepsPerMil; 
float pageWidth = machineWidth - (sideMargin*2); 
float pageHeight = pageWidth/2; 

float drawSpeed = 500; 

#endif

// caibration point only for actual machine 

long calibrationLengthA = round(1600.0f * stepsPerMil); 
long calibrationLengthB = round(1390.0f * stepsPerMil); 



double xPos = pageWidth/2; 
double yPos = 0; 

long motorPosA = round (sqrt( sq(machineWidth/2) + sq(pageTop))); 
long motorPosB = round (sqrt( sq(machineWidth/2) + sq(pageTop)));



float startPosX = 0;
float startPosY = 0;  
float vectorX = 0; 
float vectorY = 0; 
float progress = 0; 
float duration = 0; 
unsigned long startTime; 


long setPosByCartesian(float x, float y){ 

  motorPosA = round(sqrt(sq(x+sideMargin) + sq(y+pageTop)));   
  motorPosB = round(sqrt(sq(machineWidth-(x+sideMargin)) + sq(y+pageTop)));       

}

void updateCartesianByLengths() { 

  xPos = (sq(machineWidth*0.01) - sq(motorPosB*0.01) + sq(motorPosA*0.01)) / (machineWidth*0.01*2); 
  yPos = sqrt(sq(motorPosA*0.01) - sq(xPos)); 
  xPos*=100; 
  yPos*=100; 
  xPos-=sideMargin; 
  yPos-=pageTop; 

  Serial.print("xPos:"); 
  Serial.print(xPos); 
  Serial.print(" yPos:" );
  Serial.print(yPos); 
  Serial.print(" lengthA:"); 
  Serial.print(motorPosA); 
  Serial.print(" lengthB:"); 
  Serial.print(motorPosB); 
  Serial.println(""); 

}



#ifdef USE_TEST_MACHINE

AF_Stepper stepperA = AF_Stepper(800,1); 
AF_Stepper stepperB = AF_Stepper(800,2); 



void forwardA() { 
  stepperA.onestep(FORWARD, INTERLEAVE); 
}

void backwardA() { 
  stepperA.onestep(BACKWARD, INTERLEAVE); 
}

void forwardB() { 
  stepperB.onestep(FORWARD, INTERLEAVE); 
}

void backwardB() { 
  stepperB.onestep(BACKWARD, INTERLEAVE); 
}



#else 


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


#endif

void initMotors() { 


#ifdef USE_TEST_MACHINE  
  forwardA(); 
  forwardB(); 
  motorA.initAFStepper(&stepperA,forwardA, backwardA); 
  motorB.initAFStepper(&stepperB,forwardB, backwardB); 


  // Assume that we're in the home position
  motorA.accelStepper.setCurrentPosition(motorPosA); 
  motorB.accelStepper.setCurrentPosition(motorPosB); 
  //  Serial.print("motor length = " ); 
  //  Serial.println(motorA.accelStepper.currentPosition()); 

  //
  //  delay(1000); 
  //
  //  setPosByCartesian(0,0);
  //
  //  motorA.accelStepper.moveTo( motorPosA); 
  //  motorB.accelStepper.moveTo( motorPosB); 
  //
  //  while((motorA.accelStepper.distanceToGo()>0) || (motorB.accelStepper.distanceToGo()>0)) {
  //
  //    motorA.accelStepper.run(); 
  //    motorB.accelStepper.run();  
  //
  //
  //  }
  //
  //  delay(1000); 
  //  setPosByCartesian(pageWidth,0); 
  //
  //  motorA.accelStepper.moveTo( motorPosA); 
  //  motorB.accelStepper.moveTo( motorPosB); 
  //
  //  while((motorA.accelStepper.distanceToGo()>0) || (motorB.accelStepper.distanceToGo()>0)) {
  //
  //    motorA.accelStepper.run(); 
  //    motorB.accelStepper.run();  
  //
  //
  //  }


#else 

  motorA.initGecko(A_STEP_PIN, A_DIR_PIN, A_ERR_RESET_PIN); 
  motorB.initGecko(B_STEP_PIN, B_DIR_PIN, B_ERR_RESET_PIN); 

  // reverse motorB so that it turns the same way to increase the length
  motorB.accelStepper.setPinsInverted(true, false); 
//  pinMode(A_ERR_RESET_PIN, OUTPUT); 
//  pinMode(B_ERR_RESET_PIN, OUTPUT); 
//
//  digitalWrite(A_ERR_RESET_PIN, HIGH); 
//  digitalWrite(B_ERR_RESET_PIN, HIGH); 

//  delay(2000); 


//  digitalWrite(A_ERR_RESET_PIN, LOW); 
//  digitalWrite(B_ERR_RESET_PIN, LOW); 
//
//  pinMode(A_ERR_RESET_PIN, INPUT); 
//  pinMode(B_ERR_RESET_PIN, INPUT); 


#endif
  //
  //
  //  motorA.setMaxSpeed(5000); 
  //  motorB.setMaxSpeed(5000); 
  //  motorA.setAcceleration(1000); 
  //  motorB.setAcceleration(1000); 
  //  motorA.move(1); 
  //  motorB.move(1); 
  //  motorA.runToPosition(); 
  //  motorB.runToPosition(); 




}




