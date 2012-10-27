class DynamicMotor { 
  
  public : 
  DynamicMotor() { 
    
    stepPin = steppin; 
    dirPin = dirpin; 
    resetPin = resetpin;


    currentSpeed = targetSpeed = 0; 
    acceleration = 0; 
    accelSpeed = 0.1; 
    
    
  }
  
  void initGecko(int steppin, int dirpin){
    
    accelStepper = AccelStepper(AccelStepper::DRIVER, A_STEP_PIN, A_DIR_PIN); 

    
  }
  
  void initAFStepper(int motorNum){ 
    afStepper = AF_Stepper(800, motorNum);
    
        
    void forward() { 
      afStepper.onestep(FORWARD, INTERLEAVE); 
    }
    void backward() { 
      afStepper.onestep(BACKWARD, INTERLEAVE); 
    }
    
    accelStepper = AccelStepper(forward, backward);

  }
  

  void update(TimerManager* timer) { 
    
    if(timer->do10msUpdate) { 
      
      // smoothstep smoothing technique on speed 
      if(targetSpeed!=currentSpeed) { 
        acceleration = (targetSpeed - currentSpeed) * accelSpeed;  
      
        currentSpeed+=acceleration;
      
        if(abs(targetSpeed-currentSpeed)<1) currentSpeed = targetSpeed;
        
        accelStepper.setSpeed(currentSpeed); 
      
    }
    
    accelStepper.runSpeed(); 
    
  }
  
  void setTargetSpeed(float targetspeed, float accelSpeed = -1) { 
    
    targetSpeed = targetspeed;  
    
  }
  void stop() { 
    
    targetSpeed = 0;  
    
  }
  
 
  
  float currentSpeed; 
  float targetSpeed; 
  float acceleration;
  float accelSpeed; 
  
  
  
  
  AccelStepper accelStepper; 
  AF_Stepper afStepper; 

  
  
};
