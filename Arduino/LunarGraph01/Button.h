class Button { 
  
  public:
  
  Button(int pinnum, boolean usePullUp = true){
    
    pinNum = pinnum; 
    pinMode(pinNum, INPUT);
    
    lowCount = 0; 
    highCount = 0; 
    
    if(usePullUp) 
      digitalWrite(pinNum, HIGH); 
      
    pressed = false; 
    firstTime = true; 
    
  };
  
  void update() { 
    
    boolean pinState = digitalRead(pinNum);
    int now = millis(); 
    
    // should probably add some debouncing
    
    if((pinState == LOW) && (!pressed) ) { 
        
      if((lowCount>5)||(firstTime)) { 
        pressed = true;  
        timeChanged = now; 
        timeSinceChange = 0;   
        lowCount = 0; 
      } else { 
        lowCount ++ ; 
      }
        
    } else if((pinState == HIGH) && (pressed)) { 
      
      if((highCount>5)||(firstTime)) { 
        pressed = false; 
        timeChanged = now; 
        timeSinceChange = 0;  
        highCount = 0; 
      } else { 
        highCount ++; 
      }
      
    } else { 
      timeSinceChange = now - timeChanged; 
    }
    firstTime = false; 
  }
  
  boolean isPressed() { 
    return pressed; 
  }
  
  int getTimeSinceChange() { 
    return timeSinceChange; 
  }

  private :
  int pinNum; 
  boolean pressed; 
  boolean firstTime; 
  unsigned long timeChanged;
  unsigned long timeSinceChange; 
  unsigned int lowCount; 
  unsigned int highCount; 

};
  
 
 
