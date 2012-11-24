class Button { 
  
  public:
  
  Button(int pinnum, boolean usePullUp = true, boolean onstate = LOW){
    
    onState = onstate;
    pinNum = pinnum; 
    pinMode(pinNum, INPUT);
    
    onCount = 0; 
    offCount = 0; 
    
    if(usePullUp) 
      digitalWrite(pinNum, HIGH); 
      
    on = false; 
    firstTime = true; 
    
  };
  
  boolean update() { 
    
    boolean pinState = digitalRead(pinNum);
    int now = millis(); 
    boolean changed = false; 
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
  unsigned long timeChanged;
  unsigned long timeSinceChange; 
  unsigned int onCount; 
  unsigned int offCount; 

};
  
 
 
