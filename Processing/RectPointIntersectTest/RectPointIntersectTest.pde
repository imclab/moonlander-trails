
Rectangle r; 
PVector p1; 
PVector p2; 
int clickCount; 

void setup() { 
  
  
  size(800,600); 
  
  r = new Rectangle(200,100,400,400); 
  p1 = new PVector(random(width), random(height)); 
  p2 = new PVector(random(width), random(height)); 
  clickCount = 0; 
  
} 


void draw() { 
  
  background(0);
 stroke(255); 
noFill(); 
  r.render(); 
  
  line(p1.x, p1.y, p2.x, p2.y); 
  
  PVector intersect = getPointAtRectIntersection(r, p1, p2); 
  ellipseMode(CENTER); 
  ellipse(intersect.x, intersect.y, 5,5);   
  
}


void mousePressed() { 
 
 PVector p = (clickCount++ %2 == 0)? p1 : p2; 
 p.set(mouseX, mouseY); 
 
  
  
}


PVector getPointAtRectIntersection(Rectangle r, PVector p1, PVector p2) { 

  if (r.containsPoint(p1) && r.containsPoint(p2)) { 
    println("WARNING - both points are inside rectangle - no intersection");
  } else if (!r.containsPoint(p1) && !r.containsPoint(p2)) { 
    println("WARNING - neither point is within rectangle - no intersection");
  } 

  // need to make sure p1 is the one that is outside the rectangle. 
  if (r.containsPoint(p1)) { 
    PVector t = p1; 
    p1 = p2; 
    p2 = t;
  }
  PVector v = p2.get(); 
  v.sub(p1); 
  
  PVector intersect = p1.get(); 
  intersect.x = clamp(p1.x, r.x, r.getRight());
  intersect.y = clamp(p1.y, r.y, r.getBottom());  
  
  //ellipse(intersect.x, intersect.y, 2,2);
  
  if((intersect.x == r.x) || (intersect.x == r.getRight())) {
    // left or right side intersected
    v.mult(map(intersect.x, p1.x, p2.x, 0,1)); 
  } else if((intersect.y == r.y) || (intersect.y == r.getBottom())) {
    // top or bottom side intersected
    v.mult(map(intersect.y, p1.y, p2.y, 0,1)); 
  } 
  v.add(p1); 
  return v; 
   

}

float clamp(float v, float minV, float maxV) { 
  return max(minV, min(maxV, v)); 
} 

class Rectangle { 

  float x, y, w, h; 
  Rectangle(float x, float y, float w, float h) { 
    set(x, y, w, h);
  }

  void set(float x, float y, float w, float h) {

    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }

  float getRight() { 
    return x+w;
  }
  float getBottom() { 
    return y+h;
  }

  void render() { 

    rect(x, y, w, h);
  }

  boolean containsPoint(PVector p) { 
    return((p.x<getRight()) && (p.x>x) && (p.y<getBottom()) && (p.y>y));
  }
}

