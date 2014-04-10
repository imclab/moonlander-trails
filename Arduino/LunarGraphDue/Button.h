class Button { 
  
  public:
  
  Button(int pinnum, boolean usepullup = true, boolean onstate = LOW){
    
    onState = onstate;
    pinNum = pinnum; 
   // if(usePullUp) {
    //  pinMode(pinNum, INPUT_PULLUP);
    //} else { 
    //  pinMode(pinNum, INPUT);
    //}
    usePullUp = usepullup; 
    onCount = 0; 
    offCount = 0; 
    
    // old school pull up resistor method
    //if(usePullUp) 
    //  digitalWrite(pinNum, HIGH); 
      
    on = false; 
    firstTime = true; 
    
  };
  
  boolean update() { 
    
    boolean pinState = digitalRead(pinNum);
	//TODO - what happens when millis clocks? 
    int now = millis(); 
    
    if(firstTime) { 
      if(usePullUp) {
        pinMode(pinNum, INPUT_PULLUP);
      } else { 
        pinMode(pinNum, INPUT);
      }
    }
    
    boolean changed = firstTime; 
    // should probably add some debouncing
    
    if((pinState == onState) && (!on) ) { 
        
      if((onCount>5)||(firstTime)) { 
        on = true;  
        timeChanged = now; 
        timeSinceChange = 0;   
        onCount = 0; 
        changed = true; 
      } else { 
        onCount ++ ; 
      }
        
    } else if((pinState != onState) && (on)) { 
      
      if((offCount>5)||(firstTime)) { 
        on = false; 
        timeChanged = now; 
        timeSinceChange = 0;  
        offCount = 0; 
        changed = true; 
      } else { 
        offCount ++; 
      }
      
    } else { 
      timeSinceChange = now - timeChanged; 
    }
    firstTime = false; 
    return changed; 
  }
  
  boolean isOn() { 
    return on; 
  }
  
  int getTimeSinceChange() { 
    return timeSinceChange; 
  }

  private :
  int pinNum; 
  boolean on; 
  boolean firstTime; 
  boolean onState; 
  boolean usePullUp; 
  unsigned long timeChanged;
  unsigned long timeSinceChange; 
  unsigned int onCount; 
  unsigned int offCount; 

};
  
 
 
