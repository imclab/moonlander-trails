
float pos = 100; 
float currentSpeed = 0; 
float targetSpeed = 0; 
float acceleration = 0; 

void setup() { 
  size(800,600); 
  smooth(); 
  frameRate(100); 
}


void draw() { 
  background(0);
  if(mousePressed) { 
    if(mouseX>400) 
      targetSpeed = 10; 
    else 
      targetSpeed = -10; 
    
    
  } else { 
    targetSpeed = 0; 
  }
  
  acceleration = (targetSpeed - currentSpeed) *0.05;  
  currentSpeed +=acceleration; 
  
  
  pos+=currentSpeed; 
  
  ellipse(pos, 400,20,20); 
  
  
}
