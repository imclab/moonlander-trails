

#ifdef USE_TEST_MACHINE

const int stepType = INTERLEAVE;

int motorStepsPerRev = 800;
float mmPerRev = 95;

AF_Stepper afMotorA(motorStepsPerRev, 1);
AF_Stepper afMotorB(motorStepsPerRev, 2);

void forwarda() { 
  afMotorA.onestep(FORWARD, stepType); 
}
void backwarda() { 
  afMotorA.onestep(BACKWARD, stepType); 
}
AccelStepper motorA(forwarda, backwarda);

void forwardb() { 
  afMotorB.onestep(FORWARD, stepType); 
}
void backwardb() { 
  afMotorB.onestep(BACKWARD, stepType); 
}
AccelStepper motorB(forwardb, backwardb);

#else 

AccelStepper motorA(AccelStepper::DRIVER, A_STEP_PIN, A_DIR_PIN); 
AccelStepper motorB(AccelStepper::DRIVER, B_STEP_PIN, B_DIR_PIN); 


#endif

void initMotors() { 
  
  
#ifndef USE_TEST_MACHINE  
  
  motorB.setPinsInverted(true, false); 
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


  motorA.setMaxSpeed(5000); 
  motorB.setMaxSpeed(5000); 
  motorA.setAcceleration(1000); 
  motorB.setAcceleration(1000); 
  motorA.move(1); 
  motorB.move(1); 
  motorA.runToPosition(); 
  motorB.runToPosition(); 
}


