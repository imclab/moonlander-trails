

ArrayList circleShapes = new ArrayList(); 
float noiseOffset = 0; 
HPGLManager hpgl;

void setup() { 

  size(1200, 800);

  hpgl = new HPGLManager(this);

  for (float x = width/6; x<width/6*5; x+=30) { 
    for (float y = height/6; y<height/6*5; y+=30) {
      float size = dist(width/2, height/2, x, y); 
      // sin wave
      //circleShapes.add(new Shape(x+random(-2,2), y+random(-2,2),  map(sin((x+y) /100.0f), -1, 1, 2, 14)));
      size = map(size,0,width/4, 15,0); 
      if(size>0)
        circleShapes.add(new Shape(x+random(-2,2), y+random(-2,2),  size));
    }
  }
}



void draw() { 
  background(200, 200, 220);

  noFill(); 
  smooth(); 
  stroke(0);
  strokeWeight(0.5);
  rect(0,0,hpgl.screenWidth, hpgl.screenHeight);
  
  if (keyPressed) scale(3, 3);

  for (int i =0 ; i<circleShapes.size(); i++) { 

    Shape circleShape = (Shape)circleShapes.get(i);

    circleShape.render();
  }
}


void keyPressed() { 
  if (key == 'p') {

    for (int i = 0; i<circleShapes.size(); i++) { 

      Shape circleShape = (Shape)circleShapes.get(i);

      circleShape.renderToHPGL(hpgl);
    }
  }
}


class Shape { 

  PVector[] points;   

  Shape(float xpos, float ypos, float size) { 

    
    float circumference = 2f * PI * size; 
    int numpoints = round(circumference); 
    float noiseChangeSpeed = 0.1; // bigger is faster
    float noiseSize = 4f;
    float overlap = random(2.1, 2.3);  

    float startAngle = 0;//random(PI*2); 
    points = new PVector[numpoints];  

    for (int i = 0; i<numpoints; i++) { 
      float variant = (noise(noiseOffset)-0.5)*noiseSize;
      noiseOffset+=noiseChangeSpeed;
      float angle = (PI*overlap/numpoints)*i + startAngle;
      points[i] = new PVector( cos(angle) * (size+variant) + xpos, sin(angle) * (size+variant) + ypos);
    }
  }

  void render() { 

    float offsetAngle = radians(70); 
    PVector offset = new PVector(20, 0);
    offset.rotate(offsetAngle);
    PVector offsetNormal = offset.get(); 
    offsetNormal.rotate(PI/2); 


    beginShape(); 
    for (int i = 0; i<points.length; i++) { 
      vertex(points[i].x, points[i].y);
    }
    endShape();

    /*
    for (int i = 0; i<points.length; i++) { 
     PVector p1 = points[i]; 
     PVector p2 = points[(i+1)%points.length];
     PVector segment = p2.get(); 
     segment.sub(p1); 
     //println();
     if (offsetNormal.dot(segment)>0) {
     line(p1.x, p1.y, p1.x+offset.x, p1.y+offset.y);
     line(p1.x+offset.x, p1.y+offset.y, p2.x+offset.x, p2.y+offset.y);
     }
     }
     */
  }

  void renderToHPGL(HPGLManager hpgl) { 

    for (int i = 0; i<points.length; i++) { 
      PVector p1 = points[i]; 
      PVector p2 = points[(i+1)%points.length];
     // hpgl.setVelocity(127); 
      hpgl.line(p1, p2);
    }
  }
}

void exit() { 
  
  
  hpgl.close(); 
  
}
