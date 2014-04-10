

class TimerManager { 

public:

  TimerManager() { 

    now = 0; 

    lastUpdate100ms = 0;
    lastUpdate33ms = 0;  
    lastUpdate10ms = 0; 
    lastUpdate1ms = 0; 

    do100msUpdate = false; 
    do10msUpdate = false; 
    do33msUpdate = false; 
    do1msUpdate = false; 


  };

  void update() { 
 	now = micros(); 

	// note that micros resets every 70 minutes. So we have to check that 
	// if we have clocked that we still get updates. That's what the second part of all the 
        // if statements do. 

// could possibly avoid the conditionals by using : (unsigned long)(currentMillis - previousMillis) >= interval) 
	
    if((now - lastUpdate100ms > 100000) || (now<lastUpdate100ms)){
      do100msUpdate = true; 
      lastUpdate100ms = now; 
    } 
    else {
      do100msUpdate = false; 
    } 
    
    if((now - lastUpdate33ms > 33000) || (now<lastUpdate33ms)){
      do33msUpdate = true; 
      lastUpdate33ms = now; 
    } 
    else {
      do33msUpdate = false; 
    } 

    if((now - lastUpdate10ms > 10000) || (now<lastUpdate10ms)){
      do10msUpdate = true; 
      lastUpdate10ms = now; 
    } 
    else {
      do10msUpdate = false; 
    } 

    if((now - lastUpdate1ms > 1000) || (now<lastUpdate1ms)){
      do1msUpdate = true; 
      lastUpdate1ms = now; 
    }  
    else {
      do1msUpdate = false; 
    }


  };

  unsigned long now; 

  unsigned long lastUpdate100ms; 
  unsigned long lastUpdate33ms; 
  unsigned long lastUpdate10ms; 
  unsigned long lastUpdate1ms; 

  boolean do100msUpdate; 
  boolean do33msUpdate; 
  boolean do10msUpdate; 
  boolean do1msUpdate; 







};

