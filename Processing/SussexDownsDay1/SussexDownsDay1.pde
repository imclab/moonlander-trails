
float xPosition = 0;
float xSpeed = 4;
float yPosition = 0; 
float ySpeed = 4; 

float radius = 2; 

void setup() { 

  size(600, 400);
background(0, 0, 0);
}

void draw() { 

  
  if(mousePressed) { 
    fill(200,0,255); 
  } else {
    fill(255); 
  }
  //background(0, 0, 0);
  //draw a circle at the mouse position
  ellipse(xPosition, yPosition, radius*2, radius*2);
  
  radius = radius +0.1;
  xPosition = xPosition + xSpeed; 
  yPosition = yPosition + ySpeed; 
  
  if(xPosition+radius>width) {
    xSpeed = -4;  
  } else if(xPosition<radius) { 
    xSpeed = 4; 
  }
  
  if(yPosition+radius>height) {
    ySpeed = -4;  
  } else if(yPosition<radius) { 
    ySpeed = 4; 
  }
  
  if(radius > 30) { 
    radius =1; 
  }
  
}

