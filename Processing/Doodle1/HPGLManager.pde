
import fup.hpgl.*;
import processing.serial.*;

class HPGLManager { 

  HPGL hpgl;
  Serial serial;
  float scaleToPlotter =1; 

  float offsetToPlotter = 0; 
  float plotWidth = -1; 
  float plotHeight = 1200; 
  int[] limits;
  PApplet pa; 

  boolean penIsDown; 
  PVector currentPosition = new PVector(-1, -1); 

  boolean initialised = false;

  HPGLManager(PApplet pa) {

    this.pa = pa; 

    penIsDown = false; 

    plotWidth = 16158; 
    plotHeight = 11040; 

    updatePlotterScale();
  }

  boolean initHPGL() { 

    String[] interfaces = Serial.list(); 
    println(interfaces); 
    int serialNumber = -1; 

    for (int i =0; i<interfaces.length; i++) { 

      if (interfaces[i].indexOf("tty.usbserial")>-1) {
        serialNumber = i;
      }
    }

    if (serialNumber!=-1) {
      println("FOUND USB SERIAL at index "+serialNumber);

      serial = new Serial(pa, interfaces[serialNumber]);
      hpgl = new HPGL(pa, serial);


      limits = (hpgl.hardClipLimits());
      println(limits[0]);
      println(limits[1]);
      println(limits[2]);
      println(limits[3]);
      plotWidth = limits[2]; 
      plotHeight = limits[3]; 

      hpgl.selectPen(1); 

      updatePlotterScale();
      //setVelocity(127); 

      initialised = true; 

      return true;
    } else { 
      println("NO USB SERIAL DEVICE DETECTED");
      exit();
      return false;
    }
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

  void line(PVector p1, PVector p2) { 

    if (!initialised) initHPGL();
    // clone before we fuck with them



    p1 = p1.get(); 
    p2 = p2.get();

    p1.mult(scaleToPlotter); 
    p2.mult(scaleToPlotter); 

    roundVector(p1); 
    roundVector(p2);
    if (p2.dist(currentPosition) < p1.dist(currentPosition)) { 
      PVector temp = p2; 
      p2 = p1; 
      p1 = temp;
    }

    if (currentPosition.dist(p1)>0) { 
      penUp(); 
      hpgl.plotAbsolute((int)p1.x, (int)p1.y);
    }
    penDown(); 
    hpgl.plotAbsolute((int)p2.x, (int)p2.y);

    currentPosition.set(p2);
  }  

  void setVelocity(float v) { 
    if (!initialised) initHPGL();

    hpgl.rawCommand("VS"+v, false);
  }


  void penUp() {
    if (!penIsDown) return; 
    hpgl.penUp(); 
    penIsDown = false;
  }
  void penDown() {
    if (penIsDown) return; 
    hpgl.penDown(); 
    penIsDown = true;
  }

  void roundVector(PVector p) { 
    p.x = round(p.x); 
    p.y = round(p.y);
  }
  
  void close() { 
   serial.clear(); 
   serial.stop(); 
    
    
  }
}

