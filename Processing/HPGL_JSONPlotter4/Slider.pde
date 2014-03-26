
class Slider { 

  float x, y, w, h;
  boolean dragging = false; 
  PVector mouseOffset = new PVector(); 
  PVector mouseStart = new PVector(); 

  Slider(float x, float y, float w, float h) {
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }

  boolean update(float scalar) { 
    if (dragging) { 
      x = mouseStart.x + ((mouseX-mouseStart.x)*scalar) + mouseOffset.x;
      return true;
    } else { 
      return false;
    }
  }

  void render() { 

    stroke(255); 
    fill(255, 0, 0); 
    rect(x, y, w, h);
  } 

  void mouseDown() { 
    if ((mouseX>x) &&(mouseX<x+w) && (mouseY>y) && (mouseY<y+h)) {
      dragging = true; 
      mouseOffset.set(x - mouseX, y - mouseY);
      mouseStart.set(mouseX, mouseY);
    }
  }

  void mouseUp() { 
    if (dragging) { 
      dragging = false;
    }
  }
}

