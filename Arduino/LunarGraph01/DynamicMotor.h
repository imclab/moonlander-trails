
class DynamicMotor { 

public : 
  DynamicMotor() { 

    //stepPin = steppin; 
    //dirPin = dirpin; 
    //resetPin = resetpin;


    currentSpeed = targetSpeed = 0.0f; 
    acceleration = 0.0f; 
    accelSpeed = 0.5f; 



  }

  void initGecko(int steppin, int dirpin){

    accelStepper = AccelStepper(AccelStepper::DRIVER, steppin, dirpin); 
    accelStepper.setMaxSpeed(100000); 

  }

  void initAFStepper(AF_Stepper* stepper, void (*forward)(), void (*backward)()){ 
    afStepper = stepper;

    accelStepper = AccelStepper(forward, backward);

    forward(); 
    backward(); 
    accelStepper.setMaxSpeed(1000); 
    accelStepper.setAcceleration(2000); 

  }



  void update(boolean do33msUpdate) { 



    if(do33msUpdate) { 

      // smoothstep smoothing technique on speed 
      if(targetSpeed!=currentSpeed) { 
        acceleration = (targetSpeed - currentSpeed) * accelSpeed;  

        currentSpeed+=acceleration;

        if(abs(targetSpeed-currentSpeed)<1) currentSpeed = targetSpeed;


      }
      //Serial.println(accelStepper.speed()); 
    }
    accelStepper.setSpeed(currentSpeed); 
    accelStepper.runSpeed(); 


  }


  void setSpeed(float targetspeed, float accelSpeed = -1) { 

    targetSpeed = targetspeed;  

  }

  void setSpeedDirect(float targetspeed) { 

    currentSpeed = targetSpeed = targetspeed;  

  }
  void stop() { 

    targetSpeed = 0;  

  }
//
//
//  void stepperForward() { 
//
//    afStepper->onestep(FORWARD, INTERLEAVE); 
//  }
//
//  void stepperBackward() { 
//
//    afStepper->onestep(BACKWARD, INTERLEAVE); 
//
//  }



  float currentSpeed; 
  float targetSpeed; 
  float acceleration;
  float accelSpeed; 

  AccelStepper accelStepper; 
  AF_Stepper* afStepper; 
private:


};




