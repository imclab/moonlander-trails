
DynamicMotor motorA; 
DynamicMotor motorB; 


#ifdef USE_TEST_MACHINE
void forwardA() { 
  motorA.stepperForward(); 
}

void backwardA() { 
  motorA.stepperBackward(); 
}

void forwardB() { 
  motorB.stepperForward(); 
}

void backwardB() { 
  motorB.stepperBackward(); 
}



#else 


#endif

void initMotors() { 
  
  
#ifdef USE_TEST_MACHINE  

  motorA.initAFStepper(1,forwardA, backwardA); 
  motorB.initAFStepper(2,forwardB, backwardB); 

#else 

  motorA.initGecko(A_STEP_PIN, A_DIR_PIN); 
  motorB.initGecko(B_STEP_PIN, B_DIR_PIN); 
  

  motorB.accelStepper.setPinsInverted(true, false); 
  pinMode(A_ERR_RESET_PIN, OUTPUT); 
  pinMode(B_ERR_RESET_PIN, OUTPUT); 
  
  digitalWrite(A_ERR_RESET_PIN, HIGH); 
  digitalWrite(B_ERR_RESET_PIN, HIGH); 
  
  delay(2000); 
  
  
  digitalWrite(A_ERR_RESET_PIN, LOW); 
  digitalWrite(B_ERR_RESET_PIN, LOW); 
  
  pinMode(A_ERR_RESET_PIN, INPUT); 
  pinMode(B_ERR_RESET_PIN, INPUT); 
  
    
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


