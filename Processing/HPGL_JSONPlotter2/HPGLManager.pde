
import fup.hpgl.*;
import processing.serial.*;

class HPGLManager { 

  HPGL hpgl;
  Serial serial;
  float scaleToPlotter =1; 

  float offsetToPlotter = 0; 
  float plotWidth = -1; 
  float plotHeight = 1200; 
  float screenWidth = 800; 
  float screenHeight = 600; 
  int[] limits;
  PApplet pa; 

  boolean penIsDown; 
  PVector currentPosition = new PVector(-1, -1); 

  boolean initialised = false;
  ArrayList commands; 

  HPGLManager(PApplet pa) {

    this.pa = pa; 

    penIsDown = true; 

    plotWidth = 16158; 
    plotHeight = 11040; 

    updatePlotterScale();

    commands = new ArrayList();
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

  boolean update() {

    if (!initialised) return false; 

    if (commands.size()>0) { 

      Command c = (Command)commands.get(0); 
      commands.remove(0); 
      if (c.c == COMMAND_MOVE) { 
        penUp(); 
        hpgl.plotAbsolute(c.p1, c.p2);
      } else if (c.c == COMMAND_DRAW) { 
        penDown(); 
        hpgl.plotAbsolute(c.p1, c.p2);
      } else if (c.c == COMMAND_VELOCITY) {
        setVelocity(c.p1);
      } else if (c.c == COMMAND_FORCE) {
        hpgl.forceSelect(c.p1);
      }
      println("COMMANDS TO PROCESS : " + commands.size()); 
      return true;
    } else { 
      return false ;
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

    screenWidth = (float)plotWidth/scaleToPlotter; 
    screenHeight = (float)plotHeight/scaleToPlotter;

    println(scaleToPlotter); 
    println(screenWidth); 
    println(screenHeight);
  }

  void line(PVector p1, PVector p2) { 

    moveTo(p1); 
    lineTo(p2);
  }

  void line(float x1, float y1, float x2, float y2) { 
    line(new PVector(x1, y1), new PVector(x2, y2));
  }
  //if (!initialised) initHPGL();
  // clone before we fuck with them

  //
  //
  //    p1 = screenToPlotter(p1); 
  //    p2 = screenToPlotter(p2);
  //
  //    if (currentPosition.dist(p1)>0) { 
  //      //penUp(); 
  //      //hpgl.plotAbsolute
  //      moveTo((int)p1.x, (int)p1.y);
  //    }
  //    //penDown(); 
  //    //hpgl.plotAbsolute
  //    lineTo((int)p2.x, (int)p2.y);
  //  }
  //}

  //  void plot(PVector p) { 
  //
  //    //p = screenToPlotter(p); 
  //
  //    if (p.dist(currentPosition) == 0) return; 
  //
  //    hpgl.plotAbsolute((int)(p.x), (int)(p.y));
  //    currentPosition.set(p);
  //  }
  //  void plot(int x, int y) { 
  //    hpgl.plotAbsolute(x, y);
  //    
  //  }

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
    p.z = 0;
  }

  void close() { 
    if (!initialised) return;
    serial.clear(); 
    serial.stop();
  }


  /*
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
   */

  void moveTo(PVector p) { 

    println("moveTo "+p+" " + currentPosition.dist(p)); 

    p = screenToPlotter(p); 
    if (currentPosition.dist(p)>0) { 
      commands.add(new Command(COMMAND_MOVE, (int)p.x, (int)p.y));
      currentPosition.set(p);
    }
  }

  void moveTo(float x, float y) { 
    moveTo(new PVector(x, y));
  }
  void lineTo(float x, float y) { 
    lineTo(new PVector(x, y));
  }

  void lineTo(PVector p) { 
    p = screenToPlotter(p);

    println("lineTo "+p+" " + currentPosition.dist(p)); 

    if (currentPosition.dist(p)>0) { 
      commands.add(new Command(COMMAND_DRAW, p.x, p.y));
      currentPosition.set(p);
    }
  }
  void addForceCommand(int f) { 
    commands.add(new Command(COMMAND_FORCE, f, 0));
    
    
  }

  PVector screenToPlotter(PVector screenPos) { 

    PVector plotterPos = screenPos.get();  

    plotterPos.z = 0; 
    plotterPos.mult(scaleToPlotter); 

    roundVector(plotterPos);

    plotterPos.y = plotHeight - (plotterPos.y);

    return plotterPos;
  }
}

