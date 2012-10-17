




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
  int jogSpeed = 2; 
  multiButton.update(); 
  
  if(!motorARunning){
   
    if(multiButton.isPressed(motorAUpButton)) { 
     
     motorA.move(-jogSpeed); 
     
      //Serial.println("motorA Up"); 
     
    } else if(multiButton.isPressed(motorADownButton)) { 
      
     motorA.move(jogSpeed); 
    
      
      //Serial.println("motorA Down");
      
    }
    motorA.run(); 
    
  }
  
  
  if(!motorBRunning){
   
    if(multiButton.isPressed(motorBUpButton)) { 
     
     motorB.move(-jogSpeed); 
   
      //Serial.println("motorB Up"); 
     
    } else if(multiButton.isPressed(motorBDownButton)) { 
      
     motorB.move(jogSpeed); 
   
      
    //  Serial.println("motorB Down");
      
    }
    
  
    motorB.run();  
  }
   

}

void impl_loadMachineSpecFromEeprom()
{}

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

