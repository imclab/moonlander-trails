/**
*  Polargraph Server. - CORE
*  Written by Sandy Noble
*  Released under GNU License version 3.
*  http://www.polargraph.co.uk
*  http://code.google.com/p/polargraph/

Penlift.

This is one of the core files for the polargraph server program.  
This file contains the servo calls that raise or lower the pen from
the page.

*/
void penlift_penUp()
{
  if (!isPenUp)
  {
    digitalWrite(PEN_LIFT_SOLENOID_PIN, HIGH); 
    isPenUp = true; 
    // maybe wait a bit here? 
  }
}


void penlift_penDown()
{
  if (isPenUp)
  {
    digitalWrite(PEN_LIFT_SOLENOID_PIN, LOW); 
    isPenUp = false; 
    // maybe wait a bit here? 
  }
}



