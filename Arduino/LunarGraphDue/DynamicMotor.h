
class DynamicMotor {

  public :
    DynamicMotor() {

      currentSpeed = targetSpeed = 0.0f;
      acceleration = 0.0f;
      accelSpeed = 0.2f;
      errorState = true;
      brakeSolenoidOn = false;
      brakeSolenoidOnTime = 0;
      //rewindCountdown = 0;
    }

    void initGecko(int steppin, int dirpin, int errpin, int brakepin) {

      accelStepper = AccelStepper(AccelStepper::DRIVER, steppin, dirpin);
      accelStepper.setMaxSpeed(100000);

      errorPin = errpin;
      brakePin = brakepin;
      pinMode(brakePin, OUTPUT);
      pinMode(errorPin, INPUT);

      brakeSolenoidOn = true; // reset so that releasing the brake solenoid works
      brakeSolenoidOnTime = 0;
      turnBrakeSolenoidOff();
      errorState = false;
      //errorPinLowCount = 5;

      //reset();

    }

    // TODO - make a solenoid object!

    void turnBrakeSolenoidOn() {
      //analogWrite(brakePin, 64);
      if (brakeSolenoidOn) return;
      brakeSolenoidOn = true;
      brakeSolenoidOnTime = millis();

    }
    void turnBrakeSolenoidOff() {
      if (!brakeSolenoidOn) return;
      analogWrite(brakePin, 0);
      brakeSolenoidOn = false;
    }



    void update(boolean do33msUpdate) {



      if (checkErrorPin() == LOW)  errorPinLowCount++;
      else errorPinLowCount = 0;



      if ((!errorState) && (errorPinLowCount > 2)) {
        // if it's been low for 2 "frames" then we need to go into an error state
        Serial.println("Dynamic Motor - going into error");
        errorState = true;
        errorPinLowCount  = 0;
        setSpeedDirect(0);


      }
      if (errorState)
        turnBrakeSolenoidOff();
      else
        turnBrakeSolenoidOn();




      if (do33msUpdate) {

        if (!errorState) {

          //        Serial.print(digitalRead(resetPin));
          //        Serial.print(" ");
          //        Serial.print(errorState);
          //        Serial.print(" ");
          //        Serial.println(errorPinLowCount);

          // error pin is high when it's happy, low when it's not happy


          /*Serial.print("pin : " );
          Serial.print(errorPin);
          Serial.print(" pin read : ");
          Serial.print(digitalRead(errorPin));
          Serial.print(" reset count : ");
          Serial.print(errorPinLowCount);
          Serial.print(" state : ");
          Serial.println(errorState); */



          // smoothstep smoothing technique on speed
          if (targetSpeed != currentSpeed) {
            acceleration = (targetSpeed - currentSpeed) * accelSpeed;

            currentSpeed += acceleration;

            if (abs(targetSpeed - currentSpeed) < 1) currentSpeed = targetSpeed;


          }
          //Serial.println(accelStepper.speed());
        }






        // update solenoid
        if (brakeSolenoidOn) {

          unsigned long timeSinceOn = millis() - brakeSolenoidOnTime;
          float minPower = 0.3f;
          float maxPower = 0.6f;
          if (timeSinceOn < 2000) {
            analogWrite(brakePin, (maxPower * 255.0f));
            //Serial.println( maxPower * 255.0f);
          } else if (timeSinceOn < 4000) {
            analogWrite(brakePin, mapFloat(timeSinceOn, 2000, 4000, maxPower, minPower) * 255.0f);
            //Serial.println( mapFloat(timeSinceOn, 2000, 4000, maxPower, minPower) * 255.0f);
          } else {
            analogWrite(brakePin, minPower * 255.0f);
          }
          // full strength for 500 mils, then ease in-out to low strength after 2 seconds
          //float strength = constrain(mapEaseInOut(timeSinceOn, 2000, 4000, maxPower, minPower), minPower, maxPower);
          //analogWrite(brakePin, strength * 255.0f);



        }
        // assumes rewind countdown only happens after an error.
        
      }


      accelStepper.setSpeed(currentSpeed);
      accelStepper.runSpeed();
    }



    bool checkErrorPin() {
      return digitalRead(errorPin);

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

    /*
        void reset() {
          //resetting = true;
          //resetStartTime = millis();
          //lastResetTime = millis();
          //pinMode(resetOutPin, OUTPUT);
          //pinMode(errorPin, INPUT);

          //digitalWrite(resetOutPin, HIGH);
          //Serial.println("MOTOR RESET");
        }
    */
    void finishResetting() {


      //restartCountdown = 10;
     // rewindCountdown = 30; // 15 frames - half a second - of rewinding
      setSpeedDirect(-100);
      errorState = false;
      //pinMode(resetOutPin, INPUT);
      //digitalWrite(resetOutPin, LOW);
      //Serial.println("MOTOR RESET FINISHED");
      errorPinLowCount = 0;


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

    float mapFloat(float v, float min1, float max1, float min2, float max2) {
      if (min1 == max1) return v;
      return ((v - min1) / (max1 - min1) * (max2 - min2)) + min2;

    }

    int errorPinLowCount;
    float currentSpeed;
    float targetSpeed;
    float acceleration;
    float accelSpeed;
    int brakePin;
    //int rewindCountdown; // while >0, rewind the motors a little

    int errorPin;


    boolean errorState;

    //int restartCountdown;


    AccelStepper accelStepper;

  private:

    unsigned long brakeSolenoidOnTime;
    bool brakeSolenoidOn;

};







