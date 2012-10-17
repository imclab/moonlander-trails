




/*  Implementation of executeCommand for UNO-sized boards 
 without "store" features. Doesn't actually do anything except
 pass the command to the real executeCommand.  */
void impl_processCommand(String com)
{
  impl_executeCommand(com);
}

void impl_runBackgroundProcesses()
{
  // -------- PUT ALL SWITCH AND MOTOR TESTS IN HERE!
  // for emergency stop use : 
  // currentlyRunning = false

  //motorA.currentPosition(); 
  //motorB.currentPosition(); 
  
  // if error pin : 
  // set error mode
  // power up brake
  
  // if max/min pins 
  // stop motors
  // move back until not triggered
  


  checkNudgeButtons();    
  

}

void checkNudgeButtons() { 

  int jogSpeed = 2; 
  multiButton.update(); 

  if(!motorARunning){
    if(multiButton.isPressed(motorAUpButton)) { 
      
      motorA.move(-jogSpeed); 
    } 
    else if(multiButton.isPressed(motorADownButton)) { 
      motorA.move(jogSpeed); 
    }
    motorA.run(); 
  }


  if(!motorBRunning){
    if(multiButton.isPressed(motorBUpButton)) { 
      motorB.move(-jogSpeed); 
    } 
    else if(multiButton.isPressed(motorBDownButton)) { 
      motorB.move(jogSpeed); 
    }
    motorB.run();  
  }








}


void impl_loadMachineSpecFromEeprom()
{
}

void impl_executeCommand(String &com)
{
  if (exec_executeBasicCommand(com))
  {
    // that's nice, it worked
  }
  else
  {
    comms_unrecognisedCommand(com);
    comms_ready();
  }
}


void impl_engageMotors()
{
  motorA.runToNewPosition(motorA.currentPosition()+4);
  motorB.runToNewPosition(motorB.currentPosition()+4);
  motorA.runToNewPosition(motorA.currentPosition()-4);
  motorB.runToNewPosition(motorB.currentPosition()-4);
}

void impl_releaseMotors()
{
  penlift_penUp();
}


