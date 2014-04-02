
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

    void initGecko(int steppin, int dirpin, int errpin, int resetpin, int brakepin) {

      accelStepper = AccelStepper(AccelStepper::DRIVER, steppin, dirpin);
      accelStepper.setMaxSpeed(100000);
      resetOutPin = resetpin;
      errorPin = errpin;
      brakePin = brakepin;
      pinMode(brakePin, OUTPUT);
      pinMode(errorPin, INPUT);

      turnBrakeSolenoidOff();

      reset();

    }

    // TODO - make a solenoid object!

    void turnBrakeSolenoidOn() {
      //analogWrite(brakePin, 64);
      if(brakeSolenoidOn) return; 
      brakeSolenoidOn = true;
      brakeSolenoidOnTime = millis();

    }
    void turnBrakeSolenoidOff() {
      if(!brakeSolenoidOn) return; 
      analogWrite(brakePin, 0);
      brakeSolenoidOn = false;
    }



    void update(boolean do33msUpdate) {

      if (resetting) {

        if (millis() - resetStartTime > 2000) {

          finishResetting();

        }

      }
      else if (!errorState) {
        if (do33msUpdate) {
          //        Serial.print(digitalRead(resetPin));
          //        Serial.print(" ");
          //        Serial.print(errorState);
          //        Serial.print(" ");
          //        Serial.println(resetPinErrorCount);

          // error pin is high when it's happy, low when it's not happy

          if (digitalRead(errorPin) == LOW) resetPinErrorCount++;
          else resetPinErrorCount = 0;

          /*Serial.print("pin : " );
          Serial.print(errorPin);
          Serial.print(" pin read : ");
          Serial.print(digitalRead(errorPin));
          Serial.print(" reset count : ");
          Serial.print(resetPinErrorCount);
          Serial.print(" state : ");
          Serial.println(errorState); */

          if (resetPinErrorCount > 2) {
            // if it's been low for 2 "frames" then we need to go into an error state
            errorState = true;
            resetPinErrorCount  = 0;
            setSpeedDirect(0);

            // retry after five minutes?
            if (millis() - lastResetTime > 5 * 60 * 1000 ) { // five minutes
              autoResetCount = 0;
            }
            autoResetCount++;

            if (autoResetCount <= 3) {
              Serial.print("MOTOR ERROR - auto reset ");
              Serial.println(autoResetCount);
              reset();
            } else {
              Serial.println("MOTOR ERROR");
            }

          }

          // smoothstep smoothing technique on speed
          if (targetSpeed != currentSpeed) {
            acceleration = (targetSpeed - currentSpeed) * accelSpeed;

            currentSpeed += acceleration;

            if (abs(targetSpeed - currentSpeed) < 1) currentSpeed = targetSpeed;


          }
          //Serial.println(accelStepper.speed());
        }

        if (errorState) {
          turnBrakeSolenoidOff();
        }
        else {
          turnBrakeSolenoidOn();
        }


        accelStepper.setSpeed(currentSpeed);
        accelStepper.runSpeed();
      }

      // update solenoid
      if (do33msUpdate && brakeSolenoidOn) {

        unsigned long timeSinceOn = millis() - brakeSolenoidOnTime;
        float minPower = 0.2f; 
        float maxPower = 0.5f; 
        if(timeSinceOn<2000) {
          analogWrite(brakePin, maxPower * 255.0f);
          //Serial.println( maxPower * 255.0f); 
        } else if(timeSinceOn<4000) {
          analogWrite(brakePin, mapEaseInOut(timeSinceOn, 2000, 4000, maxPower, minPower) * 255.0f);
          //Serial.println( mapEaseInOut(timeSinceOn, 2000, 4000, maxPower, minPower) * 255.0f); 
        }
        // full strength for 500 mils, then ease in-out to low strength after 2 seconds
        //float strength = constrain(mapEaseInOut(timeSinceOn, 2000, 4000, maxPower, minPower), minPower, maxPower);
        //analogWrite(brakePin, strength * 255.0f);



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
    float mapEaseInOut(float value, float min1, float max1, float min2, float max2) {

      if (value < min1) return min2;
      else if (value > max1) return max2;

      // get value between 0 and 1
      float t = (value - min1) / (max1 - min1);

      // ease it in and out
      t = constrain(t, 0.0f, 1.0f);
      t = easeInOut(t);//, 0.0f, 1.0f, 1.0f);
      // and map it on to the output

      float r = (t * (max2 - min2)) + min2 ;


      return r;

    }
    float easeInOut(float t) {
      if ((t *= 2)  < 1) return ((0.5f) * (t * t));
      return -0.5f * (((--t) * (t - 2)) - 1);
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

  private:

    unsigned long brakeSolenoidOnTime;
    bool brakeSolenoidOn;

};







