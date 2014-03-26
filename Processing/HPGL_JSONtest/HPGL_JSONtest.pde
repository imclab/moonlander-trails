import fup.hpgl.*;
import processing.serial.*;

HPGL hpgl;
Serial serial;
float scaleToPlotter =1; 

float offsetToPlotter = 0; 
float plotWidth = -1; 
float plotHeight = 1200; 
int[] limits;
boolean TEST = true; 

ArrayList paths = new ArrayList(); 

PVector mousePressPoint = new PVector(); 
PVector dataOffset = new PVector(); 
float dataScale = 0.8; 
boolean dirty = true; 

JSONArray sessions;

int lastSessionParsed = -1; 

void setup() {

  size(1200, 800, OPENGL);

  /*
  !!! change the serial port here !!!
   */
  println(Serial.list());

  byte[] bytes = loadBytes("data.json"); 
  String[] datas = loadStrings("http://node.seb.ly:8002/2013-05-01.json"); 
  //String data = join(datas, ""); 
  //println(data); 

  JSONObject json = JSONObject.parse(datas[0]);
  //println(json);
  //println(json.getInt("foo"));
  sessions = json.getJSONArray("sessions");


  for (int i = 0; i<2 && i<sessions.size(); i++) { 
    parseSession(sessions, i);
  }

  println("paths length : "+paths.size()); 
  println("first path length : "+((ArrayList)paths.get(0)).size());
  ArrayList points = (ArrayList)paths.get(0); 
  for (int i = 0; i<points.size(); i++) { 
    println(i+" " +points.get(i));
  }

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

void parseSession(JSONArray sessions, int index) { 

  JSONObject session = sessions.getJSONObject(index); 

  JSONArray jsonpaths = session.getJSONArray("paths");  

  for (int j = 0; j<jsonpaths.size(); j++) { 

    JSONArray path = jsonpaths.getJSONArray(j); 

    //println(path.size());

    ArrayList points = new ArrayList(); 

    for (int k = 0; k<path.size(); k++) { 

      JSONObject point = path.getJSONObject(k);
      PVector pv = new PVector(point.getFloat("x")/100.0f, point.getFloat("y")/100.0f); 
      points.add(pv); 

      //println("   "+point.getInt("x")); //.size());
    }

    paths.add(points);
  }

  lastSessionParsed = index; 
  println(lastSessionParsed+" "+ sessions.size());
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


  if ((frameCount%1 ==0) && (lastSessionParsed+1< 20)) { //sessions.size())) { 
    parseSession(sessions, lastSessionParsed+1); 
    dirty = true;
  }


  if (mousePressed) { 
    PVector diff = new PVector(mouseX, mouseY);  
    diff.sub(mousePressPoint); 
    if (diff.mag()>0) { 
      dataOffset.add(diff); 
      mousePressPoint.set(mouseX, mouseY); 

      dirty = true;
    }
  }


  if (!dirty) {
    fill(255, 0, 0); 
    rect(0, 0, 10, 10); 
    return ;
  }

  background(0); 

  stroke(255); 
  noFill(); 


  pushMatrix(); 
  strokeWeight(1);
  scale(1.0f/scaleToPlotter, 1.0f/scaleToPlotter); 
  rect(0, 0, plotWidth, plotHeight);

  rect(0, 0, 100, 100); 
  popMatrix(); 

  strokeWeight(1);




  pushMatrix(); 
  translate(dataOffset.x, dataOffset.y);
  scale(dataScale, dataScale);
  stroke(140, 140, 150);
  blendMode(ADD);
  //scale(0.01, 0.01); 
  strokeWeight(1);
  for (int i = 0; i<paths.size(); i++) { 
    beginShape(); 

    ArrayList points = (ArrayList)paths.get(i); 

    for (int j = 0; j<points.size(); j++ ) { 
      PVector pv = (PVector)points.get(j);  
      vertex(pv.x, pv.y);
    }
    endShape();
  }
  popMatrix();


  dirty = false;
}

void mousePressed() { 
  mousePressPoint.set(mouseX, mouseY);
}

void mouseReleased() {
}

void keyPressed() { 
  println(key); 

  if (key == 'p') {
    println("PRINT"); 
    printPaths();
  } else if (key == '-') { 

    
    changeDataScale(0.98); 
     
    dirty = true;
  } else if (key == '=') { 

    changeDataScale(1.02); 
  }
}

//------------------------------------------------------

void changeDataScale(float scaleMultiplier) { 
  

    float visibleWidth =  plotWidth / scaleToPlotter / dataScale; 
   
    dataScale *=scaleMultiplier;  
    float newWidth =  plotWidth / scaleToPlotter / dataScale; 
 
   println("visibleWidth = "+visibleWidth);
   println("newWidth = "+newWidth);
   println("offset increased by : "+ ((newWidth-visibleWidth)/2f));
   dataOffset.x += ((newWidth-visibleWidth)/2f); 
  
  
    
    
    dirty = true;
  
  
  
  
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





void printPaths() { 
  // hpgl.rawCommand("VS40", false);
  //hpgl.accelerationSelect(4);
  hpgl.penUp(); 

  for (int i = 0; i<paths.size(); i++) { 


    ArrayList points = (ArrayList)paths.get(i); 


    for (int j = 0; j<points.size(); j++ ) { 

      PVector pv = ((PVector)points.get(j)).get();  

      //pv.mult(0.01); 
      pv.mult(dataScale); 
      pv.add(dataOffset); 

      pv.mult(scaleToPlotter); 
      hpgl.plotAbsolute(round(pv.x), round(plotHeight - pv.y)); 

      if (j==0) hpgl.penDown();
    }

    hpgl.penUp();
  }
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



