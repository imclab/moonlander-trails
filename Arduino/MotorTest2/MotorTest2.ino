


  ////////////////////////////////              
  //TWO WIRE STEP/DIR DRIVER BOARD CODE      
  int Motor1StepPin = 2;
  int Motor1DirPin = 3;

  int Motor2StepPin = 4;
  int Motor2DirPin = 5;  
  
  //The number of steps required for your stepper to make one revolution. (Don't forget to take into 
  //account the settings on your driver board. i.e. Microstepping, half stepping etc.)
  float steps = 96;  
    //Set the travel speed for your stepper motors here. (In Rev/Min)
    //Note: There is a limit to how fast or slow this code is able to spin the stepper motors.
    //You can try experimenting with the "delayMicroseconds" code if you need different speeds.
  int altSpeed=60;
  int azSpeed=60; 
  
  //////////////////////////////// 

  float Motor1Delay, Motor2Delay, doSteps;

void setup()
{ 
    Serial.begin(9600);
  ////////////////////////////////              
  //TWO WIRE STEP/DIR DRIVER BOARD CODE  
  pinMode(Motor1StepPin, OUTPUT);
  pinMode(Motor1DirPin, OUTPUT);
  pinMode(Motor2StepPin, OUTPUT);
  pinMode(Motor2DirPin, OUTPUT);
  Motor1Delay = ( 1000000 * ( 60 / (steps * altSpeed) ) ) / 2;
  Motor2Delay  = ( 1000000 * ( 60 / (steps * azSpeed) ) ) / 2;
  ////////////////////////////////  

        pinMode(6, OUTPUT);
//      pinMode(7, OUTPUT);      
//      pinMode(13, OUTPUT);
    

         
}

void loop()
{
  
  delay(1000); 
  digitalWrite(6, HIGH);
  delay(100); 
  
  moveToPosition(1, 0, -steps * 1);  
  moveToPosition(1, 0, steps * 1);   
  moveToPosition(1, -steps * 1, 0); 
  moveToPosition(1, steps * 1, 0); 

  digitalWrite(6, LOW);  

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This code moves the stepper motors
void moveToPosition(int limitSearch,  long altsteps, long azsteps){
    
    Serial.println("altsteps");
    Serial.println(altsteps);
    Serial.println("azsteps");
    Serial.println(azsteps);                 
        
  ////////////////////////////////              
  //TWO WIRE STEP/DIR DRIVER BOARD CODE   
  if (abs(azsteps)==azsteps){digitalWrite(Motor2DirPin, HIGH);}else{digitalWrite(Motor2DirPin, LOW);}  
  if (abs(altsteps)==altsteps){digitalWrite(Motor1DirPin, HIGH);}else{digitalWrite(Motor1DirPin, LOW);}

//  for (doSteps=1; doSteps <= abs(azsteps); doSteps++){
//     digitalWrite(Motor2StepPin, HIGH);
//     delayMicroseconds(int(Motor2Delay));
//     digitalWrite(Motor2StepPin, LOW); 
//     delayMicroseconds(int(Motor2Delay));
//  }
     
  for (doSteps=1; doSteps <= abs(altsteps); doSteps++){
     digitalWrite(Motor1StepPin, LOW);
     delayMicroseconds(5);
     digitalWrite(Motor1StepPin, HIGH); 
     delayMicroseconds(int(Motor1Delay));
  }
    
}
