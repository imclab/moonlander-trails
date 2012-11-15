
void updateCalibration() { 

  // if we haven't got both motors loose enough to unset the switches, 
  // move them both down until they are
  
  
  if((calibrationProgressA == 0) || (calibrationProgressB == 0)) {
    if((calibrationProgressA == 0) && (calibrationButtonA.isOn())) {
      motorA.setSpeed(3000); 
    } 
    else { 
      motorA.stop(); 
      calibrationProgressA = 1; 
     // Serial.println("CalA = 1"); 
    }

    if((calibrationProgressB == 0) && (calibrationButtonB.isOn())) {
      motorB.setSpeed(3000); 
    } 
    else { 
      motorB.stop(); 
      calibrationProgressB = 1;

     // Serial.println("CalB = 1"); 
    }
  }

  else {
    if(calibrationProgressA == 1) { 
      if(calibrationButtonA.isOn()) { 
        motorA.stop(); 
        calibrationProgressA = 2;   
      } 
      else { 
        motorA.setSpeed(-1400); 
      }
    }

    if(calibrationProgressB == 1) { 
      if(calibrationButtonB.isOn()) { 
        motorB.stop(); 
        calibrationProgressB = 2;   
      } 
      else { 
        motorB.setSpeed(-1400); 
      }
    }

    if(calibrationProgressA == 2) { 
      if(calibrationButtonA.isOn()) { 
        motorA.setSpeed(500);    
      } 
      else { 
        // CALIBRATION POINT IS HERE!

        motorPosA = calibrationLengthA;
        motorA.accelStepper.setCurrentPosition(motorPosA);

        Serial.print("MotorA calibration point : "); 
        Serial.println(motorA.accelStepper.currentPosition()); 
      


        motorA.stop(); 
        calibrationProgressA = 3; 
      }
    }

    if(calibrationProgressB == 2) { 
      if(calibrationButtonB.isOn()) { 
        motorB.setSpeed(500);  
      } 
      else { 
        // CALIBRATION POINT IS HERE!

        motorPosB = calibrationLengthB;
        motorB.accelStepper.setCurrentPosition(motorPosB);

        Serial.print("MotorB calibration point : "); 
        Serial.println(motorB.accelStepper.currentPosition()); 

        motorB.stop(); 
        calibrationProgressB = 3; 
        
      }
    }

  }



}



