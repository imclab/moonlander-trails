
DynamicMotor motorA; 
DynamicMotor motorB; 


float stepsPerRev = 2000.0f * 36.0f / 19.0f; 
// mm : 
float diameter = 32.0f + 0.6f;
float circumference = diameter * PI; 
float stepsPerMil = stepsPerRev/circumference; 

// dimensions in steps 
float machineWidth = 2675.0f * stepsPerMil;  
float pageTop = 350.0f * stepsPerMil; 
float sideMargin = 450.0f * stepsPerMil; 
float pageWidth = machineWidth - (sideMargin*2); 
float pageHeight = pageWidth*0.70; 

float drawSpeed = 280; 

// caibration point only for actual machine 

long calibrationLengthA = round(1565.0f * stepsPerMil); 
long calibrationLengthB = round(1545.0f * stepsPerMil); 

double xPos = pageWidth/2; 
double yPos = 0; 

long motorPosA = round (sqrt( sq(machineWidth/2) + sq(pageTop))); 
long motorPosB = round (sqrt( sq(machineWidth/2) + sq(pageTop)));






long setPosByCartesian(float x, float y){ 

  motorPosA = round(sqrt(sq(x+sideMargin) + sq(y+pageTop)));   
  motorPosB = round(sqrt(sq(machineWidth-(x+sideMargin)) + sq(y+pageTop)));       

}

void updateCartesianByLengths() { 
  motorPosA = motorA.accelStepper.currentPosition(); 
  motorPosB = motorB.accelStepper.currentPosition(); 
  xPos = (sq(machineWidth*0.01) - sq(motorPosB*0.01) + sq(motorPosA*0.01)) / (machineWidth*0.01*2); 
  yPos = sqrt(sq(motorPosA*0.01) - sq(xPos)); 
  xPos*=100; 
  yPos*=100; 
  xPos-=sideMargin; 
  yPos-=pageTop; 

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



  motorA.initGecko(A_STEP_PIN, A_DIR_PIN, A_ERROR_PIN, BOTH_RESET_PIN, A_BRAKE_PIN); 
  motorB.initGecko(B_STEP_PIN, B_DIR_PIN, B_ERROR_PIN, BOTH_RESET_PIN, B_BRAKE_PIN); 

  // reverse motorB so that it turns the same way to increase the length
  motorB.accelStepper.setPinsInverted(true, false); 



}




