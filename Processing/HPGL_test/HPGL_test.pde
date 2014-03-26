import fup.hpgl.*;
import processing.serial.*;

HPGL hpgl;
Serial serial;
float scaleToPlotter =1; 
float offsetToPlotter = 0; 
float plotWidth = -1; 
float plotHeight = 1200; 
int[] limits;
boolean TEST = false; 

ArrayList circles = new ArrayList(); 
Circle currentCircle; 

void setup() {

  size(800, 600);

  /*
  !!! change the serial port here !!!
   */
  println(Serial.list());

  if (TEST) return; 

  String[] interfaces = Serial.list(); 

  int serialNumber = -1; 

  for (int i =0; i<interfaces.length; i++) { 

    //  println(interfaces[i]); 

    if (interfaces[i].equals("/dev/tty.usbserial"))
      serialNumber = i;
  }

  if (serialNumber!=-1) {
    println("FOUND USB SERIAL at index "+serialNumber);

    serial = new Serial(this, interfaces[serialNumber]);
    hpgl = new HPGL(this, serial);
  } else { 
    println("NO USB SERIAL DEVICE DETECTED");
    exit();
  }

  //exit();
}

void draw() {

  // get the limits from the plotter
  if ((limits == null) && (hpgl != null)) { 
    limits = (hpgl.hardClipLimits());
    println(limits[0]);
    println(limits[1]);
    println(limits[2]);
    println(limits[3]);
    plotWidth = limits[2]; 
    plotHeight = limits[3]; 
    
    hpgl.selectPen(1); 

    updatePlotterScale();
  } else if (plotWidth<0) { 

    plotWidth = 16158; 
    plotHeight = 11040; 

    updatePlotterScale();
  }

  background(0); 

  stroke(255); 
  noFill(); 


  pushMatrix(); 
  strokeWeight(50);
  scale(1.0f/scaleToPlotter, 1.0f/scaleToPlotter); 
  rect(0, 0, plotWidth, plotHeight);

  rect(0, 0, 100, 100); 
  popMatrix(); 

  strokeWeight(1);



  if (currentCircle!=null) { 

    currentCircle.radius = dist(currentCircle.x, currentCircle.y, mouseX, mouseY) ;
  }

  for (int i = 0; i< circles.size(); i++) { 


    Circle circle =  (Circle) circles.get(i);   
    circle.render();
  }
}

void mousePressed() { 

  currentCircle = new Circle(mouseX, mouseY, 20); 
  circles.add(currentCircle);
}

void mouseReleased() { 

  if (!TEST) { 

    plotterDrawCircle(currentCircle); 
    //hpgl.plotAbsolute(halfWidth, halfHeight); 
    //hpgl.rawCommand("CI250", false);
  }

  currentCircle = null;
}


void plotterDrawCircle(Circle circle) { 

  int cx = round(circle.x * scaleToPlotter); 
  int cy = round(circle.y * scaleToPlotter); 
  int cr = round(circle.radius * scaleToPlotter); 

  hpgl.penUp();
  hpgl.plotAbsolute(cx, cy); 
  hpgl.penDown(); 
  hpgl.rawCommand("CI"+cr, false); 
  hpgl.penUp();
}

void updatePlotterScale() { 



  float plotAspectRatio = plotWidth/plotHeight; 
  float screenAspectRatio = (float)width/(float)height; 

  // if the screen aspect is wider than the plotter
  if (plotAspectRatio>screenAspectRatio) { 
    scaleToPlotter = plotWidth/(float)width;
  } else { 
    scaleToPlotter = plotHeight/(float)height;
  } 

  println(scaleToPlotter); 
  println(width); 
  println(height);
}



void stuff() { 

  //hpgl.selectPen(2);
  //hpgl.penDown();
  hpgl.plotAbsolute(0, 0);
  hpgl.plotAbsolute(limits[2], limits[3]);



  float radius = limits[3]/4; 
  int halfWidth = limits[2]/2; 
  int halfHeight = limits[3]/2; 
  int plotWidth = limits[2]; 
  int plotHeight = limits[3]; 
  //hpgl.plotAbsolute(halfWidth, halfHeight); 
  // hpgl.rawCommand("CI250", false); 

  float angle = 0;
  for (float i = 0; i<180; i++) { 
    angle+=122; 
    //hpgl.plotAbsolute(halfWidth + round(cos(radians(angle))*radius), halfHeight + round(sin(radians(angle))*radius));
  }

  //  for(float i = 0; i<plotHeight/2; i+=plotHeight/100)  {
  //   
  //      hpgl.plotAbsolute(round(halfWidth-plotHeight/4 + i),  round(halfHeight/4) );
  //      //hpgl.plotAbsolute(round(halfWidth-plotHeight/4), round(halfHeight - i) );
  //    
  //  }


  //hpgl.penUp();
  // hpgl.selectPen(0);
  serial.clear();
  serial.stop();
}

void stop() {
  // Do whatever you want here.
  serial.clear(); 
  serial.stop();
  super.stop();
}


class Circle { 

  float x, y, radius; 

  Circle(float x, float y, float radius) { 

    this.x = x; 
    this.y = y; 
    this.radius = radius;
  }

  void render() { 

    ellipse(x, y, radius*2, radius*2);
  }
}

