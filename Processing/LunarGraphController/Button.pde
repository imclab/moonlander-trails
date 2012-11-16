int numButtons = 5; 
Button buttons[] = new Button[numButtons]; 
Button pauseButton; 
Button clearButton; 
Button resetButton; 
Button penDropButton; 
Button landscapeButton; 

PFont buttonFont; 

void initButtons() { 
  
  float spacing = 30; 
  float buttonWidth = 170; 
  
  buttons[0] = pauseButton = new Button("PAUSE (P)", 0, 100, buttonWidth, 50); 
  buttons[1] = clearButton = new Button("CLEAR (C)", 0, 100, buttonWidth, 50); 
  buttons[2] = resetButton = new Button("RESET (R)", 0, 100, buttonWidth, 50); 
  buttons[3] = penDropButton = new Button("PEN CHANGE (N)", 0, 100, buttonWidth, 50);
  buttons[4] = landscapeButton = new Button("DRAW LAND (L)", 0, 100, buttonWidth, 50);
 
  
 
  for(int i = 0; i<numButtons; i++)  { 
    buttons[i].x = ((viewWidth/2) - ((float)i-(((float)numButtons-1))/2) * (buttonWidth + spacing) ) - (buttons[i].w/2); 
     buttons[i].y = viewHeight-150; 
   
   
  } 
  
  
  buttonFont = loadFont("FuturaLTPro-Bold-20.vlw");
  
}


void renderButtons() { 
  
  for(int i = 0; i<buttons.length; i++) { 
    
    buttons[i].render();  
    
  }
  
}

void checkButtons() { 
   if(pauseButton.isMouseOver()) { 
     //togglePause();
   } else if(clearButton.isMouseOver()) { 
     //clearQueue();
   } else if(resetButton.isMouseOver()) { 
     //reset(); 
   } else if(penDropButton.isMouseOver()) { 
     //dropPen(); 
   } else if(landscapeButton.isMouseOver()) { 
     //sendLandscape(); 
   }  
  
}



class Button { 

  float x, y, w, h; 
  boolean over; 
  String label; 
  public Button(String _label, float _x, float _y, float _w, float _h) { 
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    label = _label; 
  } 

  boolean isMouseOver() {
    float mousex = (float)mouseX/viewScale; 
    float mousey = (float)mouseY/viewScale; 
    
    if ((mousex>x) && (mousex<x+w) && (mousey>y) && (mousey<y+h)) {
      return true;
    } 
    else { 
      return false;
    }
    
  }
  
  void render() { 
    stroke(255); 
//    strokeWeight(2); 
//    if(isMouseOver()) { 
//      fill(255); 
// 
//      rect(x, y,w, h);
//      fill(0); 
//    } else { 
//      
//      noFill(); 
//      rect(x, y,w, h);
//        fill(255); 
//    }
//    
    fill(255); 
    textAlign(CENTER, CENTER); 
    textFont(buttonFont); 
    text(label, x+(w/2), y+(h/2)); 
    
    
  }
  
}

