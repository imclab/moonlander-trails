import fup.hpgl.*;
import processing.serial.*;
import java.util.Date;

//float scaleToPlotter =1; 
//float offsetToPlotter = 0; 

HPGLManager hpglManager; 

//Date startTime = new Date();  // MM/DD/YY

PathData pathData;// = new PathData("04/05/2013"); 
ArrayList pathDataObjects = new ArrayList(); 
JSONArray fileList;
int currentFileIndex; 
ArrayList visibleLandscapePoints = new ArrayList();
ArrayList landscapePoints = new ArrayList();
ArrayList landscapePointsFiner = new ArrayList(); // splitting up long sections of land
float landscapeWidth; 

PVector mousePressPoint = new PVector(); 
boolean mouseDown = false; 
//int numPaths = 0;
//int numPoints = 0;  
//int minPathLength = 160; 
DefaultPath defaultPath = new DefaultPath(); 
boolean[] keys = new boolean[526];
int keysPressedCount = 0; 

//[ 566.28174, 630.62866, 0.0 ]
//0.4936349
//[ 462.28296, 524.6227, 0.0 ]
//0.54431176
//[ 448.16687, 480.14264, 0.0 ]
//[ 402.9394, 486.93234, 0.0 ]
//0.57729715
//[ 373.53738, 518.19574, 0.0 ]
//0.577
//[ 387.3648, 433.07825, 0.0 ]
//[ 376.73737, 414.13974, 0.0 ]
//0.58854
//[ 376.0, 469.51025, 0.0 ]
//0.588
//[ 302.9861, 331.34818, 0.0 ]
//0.6881093
//[ 290.9134, 284.67398, 0.0 ]
//0.71579516
//[ 297.9832, 296.1731, 0.0 ]
//0.716
//PVector dataOffset = new PVector(247, 221); 
//float dataScale = 0.74; 
PVector dataOffset = new PVector(298, 306); 
float dataScale = 0.716; 


boolean dirty = true; 

int numPaths; 
int numPoints;  

Slider sliderLeft;
Slider sliderRight;

long startMils = 0;//pathData.startTime.getTime(); 
long endMils = 10000;//startMils + (1000 * 60 * 60 * 24); 
long minTime ;
long maxTime;

float leftMargin; 
float rightMargin; 
float topMargin; 
float bottomMargin; 

Rectangle visibleRect; 
Rectangle scaledVisibleRect; 

void setup() {
  hpglManager = new HPGLManager(this); 

  size(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800, P3D);
  hpglManager.updatePlotterScale();
  // LOAD DATA

  for (int i = 0; i<200; i++) { 
    getEditionCodeForNumber(i);
  }

  //http://node.seb.ly:8002/fileList.json

  String[] data = loadFile("fileList.json", false); 

  JSONObject json = JSONObject.parse(data[0]);

  fileList = json.getJSONArray("files"); 
  currentFileIndex = fileList.size()-1; 
  //pathDataObjects.ensureCapacity(fileList.size()); 

  for (int i = 0; i<=currentFileIndex; i++) { 

    pathData = new PathData(fileList.getString(i));
    pathDataObjects.add(pathData);
  }



  //pathDataObjects.add(currentFileIndex, pathData); 
  //println("number of pathDataObjects: "+pathDataObjects.size()); 


  sliderLeft = new Slider(0, 0, 5, 30); 
  sliderRight = new Slider(width-5, 0, 5, 30);

  leftMargin = 160; 
  rightMargin = width - 160; 
  topMargin = 190; 
  bottomMargin = height - 110;

  visibleRect = new Rectangle(leftMargin, topMargin, rightMargin-leftMargin, bottomMargin-topMargin); 
  scaledVisibleRect = new Rectangle(0, 0, 1, 1); 
  initLandscape();
}


void draw() {

  //  if ((frameCount%1 ==0) && (lastSessionParsed+1< sessions.size())) { 
  //    parseSession(sessions, lastSessionParsed+1); 
  //    dirty = true;
  //  }
  dirty = dirty||pathData.update(); 

  startMils = pathData.startTime.getTime(); 
  endMils = startMils + (1000 * 60 * 60 * 24); 

checkKeys(); 

  boolean shiftDown = false; 

  if ((keyPressed) && (key == CODED) && (keyCode == SHIFT)) { 

    shiftDown = true;
  } 

  if (mouseDown) { 
    PVector diff = new PVector(mouseX, mouseY);  
    diff.sub(mousePressPoint); 
    if (diff.mag()>0) { 
      diff.div(dataScale); 
      dataOffset.add(diff); 
      mousePressPoint.set(mouseX, mouseY); 

      println(dataOffset); 
      println(dataScale); 

      dirty = true;
    }
  }
  dirty = dirty | sliderLeft.update(shiftDown ? 0.2 : 1); 
  dirty = dirty | sliderRight.update(shiftDown ? 0.2 : 1);


  if (sliderRight.x>width-5) sliderRight.x = width-5; 
  if (sliderLeft.x<0) sliderLeft.x = 0; 
  if (sliderRight.x<sliderLeft.x+5) sliderRight.x = sliderLeft.x+5;   

  float onedaymils = (float)(endMils - startMils);
  minTime = round(map((float)sliderLeft.x, 0.0f, (float)width, 0, onedaymils)); 
  maxTime = round(map((float)sliderRight.x, -5.0f, (float)width-5, 0, onedaymils)); 
  minTime +=startMils; 
  maxTime +=startMils; 

  noStroke();

  if (!dirty) {
    fill(255, 0, 0); 
    rect(0, 0, 10, 10); 

    hpglManager.update(); 

    return ;
  }


  numPaths = 0;
  numPoints = 0;  
  // probably only should do this when things change scale / offset but whatever :)   
  scaledVisibleRect.set((visibleRect.x / dataScale) - dataOffset.x, (visibleRect.y /dataScale) - dataOffset.y, visibleRect.w/dataScale, visibleRect.h/dataScale);
  updateLandscapePoints(); 

  background(0); 

  hpglManager.update(); 

  renderPaths(); 

  pathData.renderTopBar(); 

  sliderLeft.render(); 
  sliderRight.render(); 
  stroke(50, 50, 50);
  drawCross(leftMargin, topMargin); 
  drawCross(rightMargin, topMargin); 
  drawCross(rightMargin, bottomMargin); 
  drawCross(leftMargin, bottomMargin); 
  noFill();

  stroke(10);
  strokeWeight(0.5);

  renderText(false);
  dirty = false;
}


void renderPaths() { 

  stroke(255); 
  noFill(); 
  blendMode(ADD);
  strokeWeight(1);
  stroke(100);



  renderTimes(false); 

  strokeWeight(1);
  pushMatrix(); 
  scale(dataScale, dataScale);
  translate(dataOffset.x, dataOffset.y);
  stroke(150, 150, 160);

  smooth();
  strokeWeight(1);

  for (int i = 0; i<pathData.times.size(); i++) { 

    long pathTime = (Long)(pathData.times.get(i)); 

    if ((pathTime<minTime) || (pathTime>maxTime)) continue; 


    ArrayList points = (ArrayList)pathData.paths.get(i); 

    //if (points.size()<minPathLength) continue; 
    if (isPathAborted(points)) continue; 

    numPaths++; 

    PVector lastPoint = new PVector(); 
    boolean penUp = true;

    for (int j = 0; j<points.size(); j++ ) { 
      PVector pv = (PVector)points.get(j);  

      if (scaledVisibleRect.containsPoint(pv)) { 
        if (penUp) { 
          penUp = false; 
          beginShape();
          if (j>0) { 
            PVector thresholdPoint = getPointAtRectIntersection(scaledVisibleRect, lastPoint, pv); 
            vertex(thresholdPoint.x, thresholdPoint.y);
          }
        }
        vertex(pv.x, pv.y);
        numPoints++;
      } else if (!penUp) {
        PVector thresholdPoint = getPointAtRectIntersection(scaledVisibleRect, lastPoint, pv);
        vertex(thresholdPoint.x, thresholdPoint.y);
        endShape();  
        penUp = true;
      }

      lastPoint = pv;
    }

    if (!penUp) endShape();
  }
  blendMode(REPLACE);
  stroke(255, 0, 0); 

  beginShape();
  for (int i = 0; i<defaultPath.defaultPoints.size(); i++) { 
    PVector v = (PVector)defaultPath.defaultPoints.get(i); 
    vertex(v.x, v.y);
  } 
  endShape(); 
  stroke(255);



  PVector lastPoint = new PVector(); 
  boolean penUp = true;

  for (int j = 0; j<visibleLandscapePoints.size(); j++ ) { 
    PVector pv = (PVector)visibleLandscapePoints.get(j);  

    if (scaledVisibleRect.containsPoint(pv)) { 
      if (penUp) { 
        penUp = false; 
        beginShape();
        if (j>0) { 
          PVector thresholdPoint = getPointAtRectIntersection(scaledVisibleRect, lastPoint, pv); 
          vertex(thresholdPoint.x, thresholdPoint.y);
        }
      }
      vertex(pv.x, pv.y);
      numPoints++;
    } else if (!penUp) {
      PVector thresholdPoint = getPointAtRectIntersection(scaledVisibleRect, lastPoint, pv);
      vertex(thresholdPoint.x, thresholdPoint.y);
      endShape();  
      penUp = true;
    }

    lastPoint = pv;
  }

  if (!penUp) endShape();

  popMatrix();
}

void renderText(boolean sendToPlotter) { 

  float writingSize = 0.9; 
  stroke(255); 
  strokeWeight(0.5);
  int playMins = floor((numPoints * 100.0f) / (60000.0f)); 
  String title = "LUNAR TRAILS - DATA FROM " + getDateAndTimeString(minTime, maxTime) + " X:"+dataOffset.x+" Y:"+dataOffset.y+" SCALE:"+dataScale; 
  title += " PATHS:"+numPaths+" POINTS:"+numPoints+" HAND-DRAWN BY ROBOT ON "+getDateString(new Date()); 

  plotText(title, leftMargin+10, bottomMargin+10, writingSize, sendToPlotter);
  String sig = "SEB.LY";
  plotText(sig, rightMargin - (sig.length()*6*writingSize) - 10, bottomMargin +10, writingSize, sendToPlotter);
}


void renderTimes(boolean sendToPlotter) { 

  int secs = 1000; 
  int mins = 60000; 
  int hours = 3600000;
  int minsPerHour = 60; 
  int numMins = round((maxTime - minTime) / mins); 
  int numMils = (int)(maxTime - minTime); 

  int labelDivisionMils;// = 3600000;
  int subDivisionMils;// = 10 * 60000;
  int tickMils; // = 60000 ; // every min

  int[] divisionDelineations = { 
    100, 
    250, 
    500, 
    1 * secs, 
    2 * secs, 
    5 * secs, 
    10 * secs, 
    20 * secs, 
    30 * secs, 
    1 * mins, 
    2 * mins, 
    5 * mins, 
    10 * mins, 
    20 * mins, 
    30 * mins, 
    1 * hours, 
    2 * hours, 
    3 * hours, 
    4 * hours, 
    6 * hours, 
    12 * hours, 
    24 * hours, 
    48 * hours
  };
  int index = 0;          
  while (numMils / (labelDivisionMils = divisionDelineations[index]) > 10) {     
    index++;
  }

  index = 0;          
  while (numMils / (subDivisionMils = divisionDelineations[index]) > 30) {     
    index++;
  }

  index = 0;          
  while (numMils / (tickMils = divisionDelineations[index]) > 350) {     
    index++;
  }
//  println("tickMils : " + tickMils + " " + (index-1)); 

  long minMils = minTime - ( minTime % tickMils); 
  long maxMils = maxTime - ( maxTime % tickMils) + tickMils; 

 // println(minTime + " " +minMils + "  " + maxTime + " " + maxMils); 
  float ypos = topMargin - 20; 
  strokeWeight(2);
  for (long t = minMils; t< maxMils; t+=tickMils) { 
    float xpos = map(t-minMils, 0, maxMils-minMils, leftMargin, rightMargin); 
    if (t % labelDivisionMils == 0) {
      if (sendToPlotter) hpglManager.plotLine(xpos, ypos-1, xpos, ypos-6); else line(xpos, ypos-1, xpos, ypos-6);

      float writingSize =  sendToPlotter ? 0.7 : 0.8; 

      //if (sendToPlotter) hpglManager.addPenCommand(2); 
      plotText(getHourAndMinuteString(t), xpos - (6*2*writingSize), ypos - 10, writingSize, sendToPlotter);
      //if (sendToPlotter) hpglManager.addPenCommand(1);
    } else if (t % subDivisionMils == 0) {

      if (sendToPlotter) hpglManager.plotLine(xpos, ypos-1, xpos, ypos-5); else line(xpos, ypos-1, xpos, ypos-5);
    } else if (t % tickMils == 0) { 

      if (sendToPlotter) hpglManager.plotLine(xpos, ypos-1, xpos, ypos-2); else line(xpos, ypos-1, xpos, ypos-2);
    } else { 
      println("WARNING - should never be called");
    }
  }


  if (sendToPlotter) {
    hpglManager.addPenCommand(1); 
    warmUpPen(5);
  }
  int numSlots = int((maxMils-minMils)/tickMils)+1; 

  int[] positionCounts = new int[numSlots]; 

  for (int i = 0; i<pathData.paths.size(); i++) { 

    long sessiontime = (Long)pathData.times.get(i); 

    if ((sessiontime<minTime) || (sessiontime>maxTime)) continue; 

    int numpoints = ((ArrayList)pathData.paths.get(i)).size();
    int timeSlot = floor((sessiontime -minMils) / tickMils); 

    //float xpos = map(sessiontime -minTime, 0, maxTime-minTime, leftMargin, rightMargin); 
    float xpos = map(timeSlot, 0, numSlots, leftMargin, rightMargin); 
    float lineHeight = positionCounts[timeSlot] *3;
    positionCounts[timeSlot]++; 

    //    if (sendToPlotter) hpglManager.line(xpos, ypos+1, xpos, ypos+1+lineHeight); 
    //    else 
    //line(xpos, ypos+1, xpos, ypos+lineHeight);
    if (sendToPlotter) hpglManager.plotRect(xpos-0.5, ypos+1+lineHeight, 1, 1); else rect(xpos-0.5, ypos+1+lineHeight, 1, 1);
  }
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
  float intersectionPoint = 1; 
  if ((intersect.x == r.x) || (intersect.x == r.getRight())) {
    // left or right side intersected
    float newIntersectionPoint = map(intersect.x, p1.x, p2.x, 0, 1);
    if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
  } 
  if ((intersect.y == r.y) || (intersect.y == r.getBottom())) {
    // top or bottom side intersected
    float newIntersectionPoint = map(intersect.y, p1.y, p2.y, 0, 1);
    if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
  } 
  v.mult(intersectionPoint);
  v.add(p1); 
  return v;
}

float clamp(float v, float minV, float maxV) { 
  return max(minV, min(maxV, v));
} 
void drawCross(float x, float y) { 
  float size = 10; 
  line(x, y-size, x, y+size); 
  line(x-size, y, x+size, y);
}

PVector getPositionAtX(PVector p1, PVector p2, float x) { 
  PVector v = p2.get(); 
  v.sub(p1); 
  v.mult(map(x, p1.x, p2.x, 0, 1)); 
  v.add(p1); 
  return v;
}


void mousePressed() { 
  if (!focused) return; 


  if (mouseY>50) {
    mousePressPoint.set(mouseX, mouseY);
    mouseDown = true;
  } else { 
    sliderLeft.mouseDown();
    sliderRight.mouseDown();
  }
}

void mouseReleased() {
  mouseDown = false;
  sliderLeft.mouseUp();
  sliderRight.mouseUp();
}


boolean isPathAborted(ArrayList points) { 

  PVector endpoint = ((PVector)points.get(points.size()-1)).get(); 
  endpoint.x = endpoint.x%landscapeWidth;

  while (endpoint.x<0) { 
    endpoint.x+=landscapeWidth;
  }


  for (int i = 0; i<landscapePointsFiner.size(); i++) { 
    //PVector p = (PVector)landscapePointsFiner.get(i); 
    //ellipse(p.x, p.y, 5,5);
    if (endpoint.dist((PVector)landscapePointsFiner.get(i))<20) return false;
  }
  return true;
}
/*
boolean isPathAborted(ArrayList points) { 
 // landscapePoints landscapeWidth
 
 PVector endpoint = (PVector)points.get(points.size()-1); 
 PVector leftPoint = endpoint.get(); 
 leftPoint.x -= 2.5; // half the width of the lander
 PVector rightPoint = endpoint.get(); 
 rightPoint.x += 2.5; // half the width of the lander
 
 return ((getAltitudeAtPoint(leftPoint) > 20) && (getAltitudeAtPoint(rightPoint) > 20)); 
 
 }
 
 float getAltitudeAtPoint(PVector p) { 
 
 float posx = p.x%landscapeWidth;
 
 while (posx<0) { 
 posx+=landscapeWidth;
 }
 float altitude = -1; 
 float ratio = 0; 
 PVector leftLandPoint = (PVector)landscapePoints.get(0); 
 PVector rightLandPoint = new PVector();
 for (int i=0; i<landscapePoints.size(); i++ ) { 
 // SHOULD PROBABLY TEST FOR OVER THE LANDSCAPE JOIN
 
 rightLandPoint = (PVector)landscapePoints.get(i); 
 // if the ship overlaps this line
 if ((posx<rightLandPoint.x) && (posx>leftLandPoint.x)) {
 ratio = map(posx, leftLandPoint.x, rightLandPoint.x, 0,1); 
 altitude = map(ratio, 0, 1, leftLandPoint.y, rightLandPoint.y) - p.y; 
 break; 
 }
 leftLandPoint = rightLandPoint;
 }
 println(altitude);
 PVector collisionPoint = rightLandPoint.get(); 
 collisionPoint.sub(leftLandPoint); 
 collisionPoint.mult(ratio); 
 collisionPoint.add(leftLandPoint); 
 
 if(altitude>20) ellipse(p.x, collisionPoint.y, 10,10); 
 return altitude;
 
 }
 */
//------------------------------------------------------

void changeDataScale(float scaleMultiplier) { 


  float oldWidth =  hpglManager.plotWidth / hpglManager.scaleToPlotter / dataScale;    
  float oldHeight =  hpglManager.plotHeight / hpglManager.scaleToPlotter / dataScale; 
  dataScale *=scaleMultiplier;  
  float newWidth =  hpglManager.plotWidth / hpglManager.scaleToPlotter / dataScale; 
  float newHeight =  hpglManager.plotHeight / hpglManager.scaleToPlotter / dataScale; 
  float offsetChangeX = ((newWidth-oldWidth)/2f);
  float offsetChangeY = ((newHeight-oldHeight)/2f);

  dataOffset.x += offsetChangeX; 
  dataOffset.y += offsetChangeY; 

  dirty = true;
}



void plotPaths() { 

  // hpglManager.penUp(); 
  println("plotPaths"); 



  int pathCount = 0; 

  for (int i = 0; i<pathData.paths.size(); i++) { 

    long pathTime = (Long)(pathData.times.get(i)); 

    if ((pathTime<minTime) || (pathTime>maxTime)) continue; 

    ArrayList points = (ArrayList)pathData.paths.get(i); 

    if (isPathAborted(points)) continue; 
    // half and half
    //hpglManager.addPenCommand((pathCount<(numPaths/2))?  2 : 1);
    // alternating pens
    //hpglManager.addPenCommand((pathCount%2==0)?  2 : 1);
    hpglManager.addPenCommand(1); 
    plotPath(points, false);

    pathCount++;
    //if (pathCount%5 == 0) blot();
  }
}

void plotPath(ArrayList points) { 
  plotPath(points, true);
}

void plotPath(ArrayList points, boolean forwards) { 

  PVector lastPoint = new PVector(); 
  boolean penUp = true;

  int startIndex = (forwards) ? 0 : points.size()-1; 
  int endIndex = (forwards) ? points.size() : 0;
  int step = (startIndex < endIndex) ? 1 : -1; 


  boolean firstTime = true; 

  for (int j = startIndex;( ((step>0) && (j<endIndex)) || ((step<0)&&(j>=endIndex)) ); j+=step ) { 
    PVector pv = ((PVector)points.get(j)).get();

    pv.add(dataOffset); 
    pv.mult(dataScale); 

    if (visibleRect.containsPoint(pv)) { 

      if (firstTime) { 
        hpglManager.moveTo(pv.x, pv.y);
        firstTime = false;
      } else if (penUp) { 
        PVector thresholdPoint = getPointAtRectIntersection(visibleRect, lastPoint, pv); 

        hpglManager.moveTo(thresholdPoint.x, thresholdPoint.y);
        hpglManager.lineTo(pv.x, pv.y);

        //hpglManager.plotPoint(pv.x, pv.y);
      } else { 
        hpglManager.lineTo(pv.x, pv.y);
        //hpglManager.plotPoint(pv.x, pv.y);
      }
      penUp = false;
    } else if (!penUp) {

      PVector thresholdPoint = getPointAtRectIntersection(visibleRect, lastPoint, pv);
      hpglManager.lineTo(thresholdPoint.x, thresholdPoint.y);
      penUp = true;
    }

    lastPoint = pv;
  }
}

void plotCross(float x, float y) { 
  plotCross(x, y, 10);
}

void plotCross(float x, float y, float size) { 
  hpglManager.plotLine(x, y, x, y+size); 
  hpglManager.plotLine(x, y, x, y-size); 
  hpglManager.plotLine(x, y, x+size, y);
  hpglManager.plotLine(x, y, x-size, y);
}

void plotTestForces() { 
  //hpglManager.setVelocity(1); 
  float xpos = leftMargin; 
  float vspace = 12; 
  float ypos = bottomMargin - (17*vspace); 
  for (int i = 1; i<16 ; i++) { 
    hpglManager.addForceCommand(i); 

    //       float writingSize = 0.9; 
    //
    //      String title = "FORCE "+i; 
    //      plotText(title, leftMargin, topMargin +(i*vspace) - 7 , writingSize, true);
    //  
    //     for(float k = leftMargin; k<rightMargin; k+=(visibleRect.w / 20.0f)) { 
    //       hpglManager.line(k, ypos +(i*vspace), k + (visibleRect.w / 22), ypos +(i*vspace));   
    //     }
    //     
    plotCross(xpos, bottomMargin + 10, 10);
    for (int j = 0; j<10; j++ ) { 
      plotCross(xpos, bottomMargin + 30, 10);
    }       

    xpos += (visibleRect.w / 15);
  }
}

void plotLandscape() { 

  //  ArrayList path = new ArrayList(); 
  //
  //  for (int i = 0; i<visibleLandscapePoints.size(); i++) { 
  //    PVector p = ((PVector)visibleLandscapePoints.get(i)).get();
  //    p.add(dataOffset); 
  //    p.mult(dataScale); 
  //    path.add(p); 
  ////    if (i ==0 ) { 
  ////      hpglManager.moveTo(p);
  ////    } else { 
  ////      hpglManager.lineTo(p);
  ////    }
  //  }

  plotPath(visibleLandscapePoints, true);
  plotPath(visibleLandscapePoints, false);
}

void warmUpPen() { 
  warmUpPen(15);
}
void warmUpPen(int numLines) { 


  hpglManager.addVelocityCommand(5);
  float size = height/5; 
  PVector p = new PVector(); 
  PVector lastPoint = new PVector(); 
  hpglManager.moveTo(0, 0); 
  for (int i = 0; i<numLines; i++) { 

    while ( (p.dist (lastPoint)< (size/5)) || (size-p.x<p.y)) {    
      p.set(random(size), random(size));
    }

    hpglManager.lineTo(p); 
    lastPoint.set(p);
  }


  /*
  float l = 0; 
   float a = 0;
   
   hpglManager.moveTo(50,50); 
   
   while(l<50) { 
   
   hpglManager.lineTo(50 + cos(a)*l, 50 + sin(a)*l); 
   
   l+=0.1; 
   a+=radians(5);  
   
   }
   
   
   l = 0; 
   a = 0;
   
   hpglManager.moveTo(50,50); 
   
   while(l<50) { 
   
   hpglManager.lineTo(50 + cos(a)*l, 50 + sin(a)*l); 
   
   l+=0.1; 
   a-=radians(5);  
   
   }
   */


  /*
  hpglManager.moveTo(0, 0); 
   
   for (float x = 0; x<100; x+=2) { 
   hpglManager.lineTo(x, (x%4 == 0)? 100 : 0);
   }
   hpglManager.moveTo(0, 0); 
   
   for (float y = 0; y<100; y+=2) { 
   
   hpglManager.lineTo( (y%4 == 0)? 100 : 0, y);
   }
   
   float l = 0; 
   float a = 0;
   
   hpglManager.addVelocityCommand(40);
   hpglManager.moveTo(50, 50); 
   
   while (l<50) { 
   
   hpglManager.lineTo(50 + cos(a)*l, 50 + sin(a)*l); 
   
   l+=0.1; 
   a+=radians(10);
   }
   
   hpglManager.addVelocityCommand(1);
   for (float x = 0; x<100; x+=2) { 
   hpglManager.plotLine(x, 50, x, 60);
   }
   for (float x = 0; x<100; x+=2) { 
   hpglManager.plotLine(x, 62, x+1, 62);
   }
   
   */
}


void testRubber() { 

  float counter = 0; 

  hpglManager.addPenCommand(1); 
  hpglManager.addVelocityCommand(1); 
  boolean rubber = false;

  for (int i = 0; i<100; i++) { 

    if (i % 10==9)  rubber = true; else rubber = false; 

    if (rubber) {
      hpglManager.addPenCommand(3); 
      hpglManager.addVelocityCommand(1);
    } else {
      hpglManager.addPenCommand(1); 
      hpglManager.addVelocityCommand(1);
    }
    for (float y = 400; y<= (rubber? 450 : 500); y+=10) { 


      if (rubber) {

        hpglManager.moveTo(50, y); 
        for (float x = 50; x < 100; x+=2) {
          hpglManager.plotPoint(x, y);
        }
      } else {  
        hpglManager.moveTo(100, y); 
        hpglManager.lineTo(50, y);
        //        for (float x = 100; x >=50; x-=10) {
        //          hpglManager.lineTo(x, y +  ((noise(counter+=0.03)-0.5) * map(x, 50, 150, 0, 5)));
        //        }
      }
    }
  }
}

void blot() { 
  int currentPen = hpglManager.currentPen; 
  hpglManager.addPenCommand(3); 
  ArrayList points = defaultPath.defaultPoints; 
  PVector p = new PVector(); 
  for (int i = 0; i<points.size()/2; i++) { 
    p.set((PVector)points.get(i)); 
    p.add(dataOffset); 
    p.mult(dataScale);

    hpglManager.plotPoint(p);
  }
  hpglManager.addPenCommand(currentPen);
}



String[] loadFile(String filename, boolean localFirst) { 
  println("loading "+filename);

  String serverPath = "http://node.seb.ly:8002/"; 
  String localPath = "data/serverdata/"; 

  String[] returndata; 
  if(localFirst) { 
    returndata = loadStrings(localPath+filename);
    if (returndata == null) { 
      println("LOADING "+serverPath+filename);
      returndata = loadStrings(serverPath+filename);
      if (returndata!=null) saveStrings(localPath+filename, returndata);
    }  
    
  } else { 
    
    returndata = loadStrings(serverPath+filename);
    if (returndata == null) { 
      println("LOADING "+localPath+filename);
      returndata = loadStrings(localPath+filename);
    
    }  else { 
       saveStrings(localPath+filename, returndata);
    }
  }

  return returndata; 

  //}  
  //loadStrings("http://node.seb.ly:8002/"+filename);
  //  String[] returnstring= {
  //    "hello", "world"
  //  }; 

  // return returndata;
}


void stop() {

  hpglManager.close(); 
  super.stop();
}

