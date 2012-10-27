

class TimerManager { 

public:

  TimerManager() { 

    now = 0; 

    lastUpdate100ms = 0; 
    lastUpdate10ms = 0; 
    lastUpdate1ms = 0; 

    do100msUpdate = false; 
    do10msUpdate = false; 
    do1msUpdate = false; 


  };

  void update() { 
    now = micros(); 

    if((now - lastUpdate100ms > 100000) || (now<lastUpdate100ms)){
      do100msUpdate = true; 
      lastUpdate100ms = now; 
    } 
    else {
      do100msUpdate = false; 
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
  unsigned long lastUpdate10ms; 
  unsigned long lastUpdate1ms; 

  boolean do100msUpdate; 
  boolean do10msUpdate; 
  boolean do1msUpdate; 







};

