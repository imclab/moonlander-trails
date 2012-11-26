
class DynamicMotor { 

public : 
  DynamicMotor() { 

    //stepPin = steppin; 
    //dirPin = dirpin; 
    //resetPin = resetpin;

    currentSpeed = targetSpeed = 0.0f; 
    acceleration = 0.0f; 
    accelSpeed = 0.2f; 
    errorState = false; 
    resetting = false; 
    lastResetTime = millis(); 
    autoResetCount = 0; 

  }

  void initGecko(int steppin, int dirpin, int resetpin, int brakepin){

    accelStepper = AccelStepper(AccelStepper::DRIVER, steppin, dirpin); 
    accelStepper.setMaxSpeed(100000); 
    resetPin = resetpin; 
    brakePin = brakepin; 
    pinMode(brakePin, OUTPUT); 
    turnBrakeOn(); 

    reset(); 

  }

  void initAFStepper(AF_Stepper* stepper, void (*forward)(), void (*backward)()){ 
    afStepper = stepper;

    accelStepper = AccelStepper(forward, backward);

    forward(); 
    backward(); 
    accelStepper.setMaxSpeed(1000); 
    accelStepper.setAcceleration(2000); 

  }

  void turnBrakeOff() {
    digitalWrite(brakePin, HIGH);  
  } 
  void turnBrakeOn() { 
    digitalWrite(brakePin, LOW);   
  }



  void update(boolean do33msUpdate) { 

    if(resetting) { 

      if(millis()-resetStartTime>2000) { 

        finishResetting(); 

      }

    } 
    else if(!errorState) { 
      if(do33msUpdate) { 
        //        Serial.print(digitalRead(resetPin));
        //        Serial.print(" ");  
        //        Serial.print(errorState); 
        //        Serial.print(" ");  
        //        Serial.println(resetPinHighCount); 


        if(digitalRead(resetPin)==LOW) resetPinHighCount++; 
        else resetPinHighCount = 0; 

        if(resetPinHighCount>2) { 
          errorState = true;  
          resetPinHighCount  =0;  
          setSpeedDirect(0); 
          
          if(millis() - lastResetTime > 5*60*1000 ) { // five minutes
            autoResetCount = 0; 
          }
          autoResetCount++; 
          
          if(autoResetCount<=3) {
            Serial.print("MOTOR ERROR - auto reset "); 
            Serial.println(autoResetCount); 
            reset();
          } else { 
            Serial.println("MOTOR ERROR"); 
          }

        }

        // smoothstep smoothing technique on speed 
        if(targetSpeed!=currentSpeed) { 
          acceleration = (targetSpeed - currentSpeed) * accelSpeed;  

          currentSpeed+=acceleration;

          if(abs(targetSpeed-currentSpeed)<1) currentSpeed = targetSpeed;


        }
        //Serial.println(accelStepper.speed()); 
      }

      if(errorState) { 
        turnBrakeOn(); 
      } 
      else { 
        turnBrakeOff(); 
      }

      accelStepper.setSpeed(currentSpeed); 
      accelStepper.runSpeed(); 
    }


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


  void reset() { 
    resetting = true; 
    resetStartTime = millis();   
    lastResetTime = millis(); 
    pinMode(resetPin, OUTPUT); 
    digitalWrite(resetPin, HIGH); 
    Serial.println("MOTOR RESET"); 
  }

  void finishResetting() { 

    resetting = false; 
    errorState = false; 
    pinMode(resetPin, INPUT); 
    Serial.println("MOTOR RESET FINISHED"); 
    resetPinHighCount = 0; 


  }


  float currentSpeed; 
  float targetSpeed; 
  float acceleration;
  float accelSpeed; 
  int brakePin; 

  int resetPin; 
  boolean resetting; 
  unsigned long resetStartTime; 
  unsigned long lastResetTime; 
  int autoResetCount; 
  int resetPinHighCount; 
  boolean errorState; 


  AccelStepper accelStepper; 
  AF_Stepper* afStepper; 
private:


};







