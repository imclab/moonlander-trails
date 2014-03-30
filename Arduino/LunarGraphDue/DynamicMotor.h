
class DynamicMotor { 

public : 
  DynamicMotor() { 

    currentSpeed = targetSpeed = 0.0f; 
    acceleration = 0.0f; 
    accelSpeed = 0.2f; 
    errorState = false; 
    resetting = false; 
    lastResetTime = millis(); 
    autoResetCount = 0; 

  }

  void initGecko(int steppin, int dirpin, int errpin, int resetpin, int brakepin){

    accelStepper = AccelStepper(AccelStepper::DRIVER, steppin, dirpin); 
    accelStepper.setMaxSpeed(100000); 
    resetOutPin = resetpin; 
    errorPin = errpin; 
    brakePin = brakepin; 
    pinMode(brakePin, OUTPUT); 
    
    turnBrakeOn(); 

    reset(); 

  }
  
  // TODO - make a solenoid object! 

  void turnBrakeOff() {
    analogWrite(brakePin, 100);  
  } 
  void turnBrakeOn() { 
    analogWrite(brakePin, 0);   
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
        //        Serial.println(resetPinErrorCount); 

      // error pin is high when it's happy, low when it's not happy
      
        if(digitalRead(errorPin)==LOW) resetPinErrorCount++; 
        else resetPinErrorCount = 0; 

        if(resetPinErrorCount>2) { 
          // if it's been low for 2 "frames" then we need to go into an error state
          errorState = true;  
          resetPinErrorCount  =0;  
          setSpeedDirect(0); 
          
          // retry after five minutes? 
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


  void reset() { 
    resetting = true; 
    resetStartTime = millis();   
    lastResetTime = millis(); 
    pinMode(resetOutPin, OUTPUT); 
    pinMode(errorPin, INPUT); 
    
    digitalWrite(resetOutPin, HIGH); 
    Serial.println("MOTOR RESET"); 
  }

  void finishResetting() { 

    resetting = false; 
    errorState = false; 
    //pinMode(resetOutPin, INPUT); 
    digitalWrite(resetOutPin, LOW); 
    Serial.println("MOTOR RESET FINISHED"); 
    resetPinErrorCount = 0; 


  }


  float currentSpeed; 
  float targetSpeed; 
  float acceleration;
  float accelSpeed; 
  int brakePin; 

  int resetOutPin; 
  int errorPin;
  boolean resetting; 
  unsigned long resetStartTime; 
  unsigned long lastResetTime; 
  int autoResetCount; 
  int resetPinErrorCount; 
  boolean errorState; 


  AccelStepper accelStepper; 
//  AF_Stepper* afStepper; 
private:


};







