class Button { 
  
  public:
  
  Button(int pinnum, boolean usePullUp = true){
    
    pinNum = pinnum; 
    pinMode(pinNum, INPUT);
    
    if(usePullUp) 
      digitalWrite(pinNum, HIGH); 
    
  };
  
  void update() { 
    
    boolean pinState = digitalRead(pinNum);
    int now = millis(); 
    
    // should probably add some debouncing
    
    if((pinState == LOW) && (!pressed) ) { 
        
        pressed = true; 
        timeChanged = now; 
        timeSinceChange = 0;   
        
    } else if((pinState == HIGH) && (pressed)) { 
      
        pressed = false; 
        timeChanged = now; 
        timeSinceChange = 0;  
      
    } else { 
      timeSinceChange = now - timeChanged; 
    }
    
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
  unsigned long timeChanged;
  unsigned long timeSinceChange; 

};
  
 
 
