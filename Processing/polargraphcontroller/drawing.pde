/**
  Polargraph controller
  Copyright Sandy Noble 2012.

  This file is part of Polargraph Controller.

  Polargraph Controller is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Polargraph Controller is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Polargraph Controller.  If not, see <http://www.gnu.org/licenses/>.
    
  Requires the excellent ControlP5 GUI library available from http://www.sojamo.de/libraries/controlP5/.
  Requires the excellent Geomerative library available from http://www.ricardmarxer.com/geomerative/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  http://code.google.com/p/polargraph/
*/
static final String CMD_CHANGELENGTH = "C01,";
static final String CMD_CHANGEPENWIDTH = "C02,";
static final String CMD_CHANGEMOTORSPEED = "C03,";
static final String CMD_CHANGEMOTORACCEL = "C04,";
static final String CMD_DRAWPIXEL = "C05,";
static final String CMD_DRAWSCRIBBLEPIXEL = "C06,";
static final String CMD_DRAWRECT = "C07,";
static final String CMD_CHANGEDRAWINGDIRECTION = "C08,";
static final String CMD_SETPOSITION = "C09,";
static final String CMD_TESTPATTERN = "C10,";
static final String CMD_TESTPENWIDTHSQUARE = "C11,";
static final String CMD_TESTPENWIDTHSCRIBBLE = "C12,";
static final String CMD_PENDOWN = "C13,";
static final String CMD_PENUP = "C14,";
static final String CMD_DRAWSAWPIXEL = "C15,";
static final String CMD_DRAWROUNDPIXEL = "C16,";
static final String CMD_CHANGELENGTHDIRECT = "C17,";
static final String CMD_TXIMAGEBLOCK = "C18,";
static final String CMD_STARTROVE = "C19,";
static final String CMD_STOPROVE = "C20,";
static final String CMD_SET_ROVE_AREA = "C21,";
static final String CMD_LOADMAGEFILE = "C23,";
static final String CMD_CHANGEMACHINESIZE = "C24,";
static final String CMD_CHANGEMACHINENAME = "C25,";
static final String CMD_REQUESTMACHINESIZE = "C26,";
static final String CMD_RESETMACHINE = "C27,";
static final String CMD_DRAWDIRECTIONTEST = "C28,";
static final String CMD_CHANGEMACHINEMMPERREV = "C29,";
static final String CMD_CHANGEMACHINESTEPSPERREV = "C30,";
static final String CMD_SETMOTORSPEED = "C31,";
static final String CMD_SETMOTORACCEL = "C32,";
static final String CMD_MACHINE_MODE_STORE_COMMANDS = "C33,";
static final String CMD_MACHINE_MODE_EXEC_FROM_STORE = "C34,";
static final String CMD_MACHINE_MODE_LIVE = "C35,";
static final String CMD_RANDOM_DRAW = "C36,";
static final String CMD_SETMACHINESTEPMULTIPLIER = "C37,";
static final String CMD_START_TEXT = "C38,";
static final String CMD_DRAW_SPRITE = "C39,";
static final String CMD_CHANGELENGTH_RELATIVE = "C40,";
static final String CMD_SWIRLING = "C41,";
static final String CMD_DRAW_RANDOM_SPRITE = "C42,";
static final String CMD_DRAW_NORWEGIAN = "C43,";
static final String CMD_DRAW_NORWEGIAN_OUTLINE = "C44,";

private PVector mouseVector = new PVector(0,0);

Comparator xAscending = new Comparator() 
{
  public int compare(Object p1, Object p2)
  {
    PVector a = (PVector) p1;
    PVector b = (PVector) p2;
    
    int xValue = new Float(a.x).compareTo(b.x);
    return xValue;
  }
};

Comparator yAscending = new Comparator() 
{
  public int compare(Object p1, Object p2)
  {
    PVector a = (PVector) p1;
    PVector b = (PVector) p2;
    
    int yValue = new Float(a.y).compareTo(b.y);
    return yValue;
  }
};

void sendResetMachine()
{
  String command = CMD_RESETMACHINE + "END";
  addToCommandQueue(command);
}
void sendRequestMachineSize()
{
  String command = CMD_REQUESTMACHINESIZE + "END";
  addToCommandQueue(command);
}
void sendMachineSpec()
{
  // ask for input to get the new machine size
  String command = CMD_CHANGEMACHINENAME+newMachineName+",END";
  addToCommandQueue(command);
  command = CMD_CHANGEMACHINESIZE+getDisplayMachine().inMM(getDisplayMachine().getWidth())+","+getDisplayMachine().inMM(getDisplayMachine().getHeight())+",END";
  addToCommandQueue(command);
  command = CMD_CHANGEMACHINEMMPERREV+int(getDisplayMachine().getMMPerRev())+",END";
  addToCommandQueue(command);
  command = CMD_CHANGEMACHINESTEPSPERREV+int(getDisplayMachine().getStepsPerRev())+",END";
  addToCommandQueue(command);
  command = CMD_SETMACHINESTEPMULTIPLIER+machineStepMultiplier+",END";
  addToCommandQueue(command);
}

public PVector getMouseVector()
{
  if (mouseVector == null)
  {
    mouseVector = new PVector(0,0);
  }
  
  mouseVector.x = mouseX;
  mouseVector.y = mouseY;
  return mouseVector;
}
void sendMoveToPosition(boolean direct)
{
  String command = null;
  PVector p = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  p = getDisplayMachine().inSteps(p);
  p = getDisplayMachine().asNativeCoords(p);
  if (direct)
  {
    command = CMD_CHANGELENGTHDIRECT+int(p.x+0.5)+","+int(p.y+0.5)+","+getMaxSegmentLength()+",END";
  }
  else
    command = CMD_CHANGELENGTH+(int)p.x+","+(int)p.y+",END";
  
  addToCommandQueue(command);
}

int getMaxSegmentLength()
{
  return this.maxSegmentLength;
}

void sendTestPattern()
{
  String command = CMD_DRAWDIRECTIONTEST+int(gridSize)+",6,END";
  addToCommandQueue(command);
}

void sendTestPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("##0.##");
  StringBuilder sb = new StringBuilder();
  sb.append(testPenWidthCommand)
    .append(int(gridSize))
    .append(",")
    .append(df.format(testPenWidthStartSize))
    .append(",")
    .append(df.format(testPenWidthEndSize))
    .append(",")
    .append(df.format(testPenWidthIncrementSize))
    .append(",END");
  addToCommandQueue(sb.toString());
}

void sendSetPosition()
{
  PVector p = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  p = getDisplayMachine().convertToNative(p);
  p = getDisplayMachine().inSteps(p);
  
  String command = CMD_SETPOSITION+int(p.x+0.5)+","+int(p.y+0.5)+",END";
  addToCommandQueue(command);
}

void sendStartTextAtPoint()
{
  PVector p = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  p = getDisplayMachine().convertToNative(p);
  p = getDisplayMachine().inSteps(p);
  
  String command = CMD_START_TEXT+(int)p.x+","+(int)p.y+","+gridSize+",2,END";
  addToCommandQueue(command);
}

void sendSetHomePosition()
{
  PVector pgCoords = getDisplayMachine().asNativeCoords(getHomePoint());
  
  String command = CMD_SETPOSITION+int(pgCoords.x+0.5)+","+int(pgCoords.y+0.5)+",END";
  addToCommandQueue(command);
}

int scaleDensity(int inDens, int inMax, int outMax)
{
  float reducedDens = (float(inDens) / float(inMax)) * float(outMax);
  reducedDens = outMax-reducedDens;
//  println("inDens:"+inDens+", inMax:"+inMax+", outMax:"+outMax+", reduced:"+reducedDens);
  
  // round up if bigger than .5
  int result = int(reducedDens);
  if (reducedDens - (result) > 0.5)
    result ++;
  
  //result = outMax - result;
  return result;
}

SortedMap<Float, List<PVector>> divideIntoRows(Set<PVector> pixels, int direction)
{
  SortedMap<Float, List<PVector>> inRows = new TreeMap<Float, List<PVector>>();
  
  for (PVector p : pixels)
  {
    Float row = p.x;
    if (direction == DRAW_DIR_SE || direction == DRAW_DIR_NW)
      row = p.y;
      
    if (!inRows.containsKey(row))
    {
      inRows.put(row, new ArrayList<PVector>());
    }
    inRows.get(row).add(p);
  }
  return inRows;
}

PVector sortPixelsInRowsAlternating(SortedMap<Float, List<PVector>> inRows, int initialDirection, float maxPixelSize)
{
  PVector startPoint = null;
  Comparator comp = null;
  boolean rowIsAlongXAxis = true;
  
  if (initialDirection == DRAW_DIR_SE || initialDirection == DRAW_DIR_NW)
  {
    rowIsAlongXAxis = true;
    comp = xAscending;
  }
  else
  {
    rowIsAlongXAxis = false;
    comp = yAscending;
  }
  
  // now sort each row, reversing the direction after each row
  boolean reverse = false;
  for (Float rowCoord : inRows.keySet())
  {
    println("row: " + rowCoord);
    List<PVector> row = inRows.get(rowCoord);

    if (reverse)
    {
      // reverse it (descending)
      Collections.sort(row, comp);
      Collections.reverse(row);
//      if (startPoint == null)
//      {
//        if (rowIsAlongXAxis)
//          startPoint = new PVector(row.get(0).x+(maxPixelSize/2.0), row.get(0).y);
//        else
//          startPoint = new PVector(row.get(0).x, row.get(0).y-(maxPixelSize/2.0));
//      }
      reverse = false;
    }
    else
    {
      // sort row ascending
      Collections.sort(row, comp);
//      if (startPoint == null)
//      {
//        if (rowIsAlongXAxis)
//          startPoint = new PVector(row.get(0).x-(maxPixelSize/2.0), row.get(0).y);
//        else
//          startPoint = new PVector(row.get(0).x, row.get(0).y+(maxPixelSize/2.0));
//      }
      reverse = true;
    }
  }
  return startPoint;
}
   
void sortPixelsInRows(SortedMap<Float, List<PVector>> inRows, int initialDirection)
{
  PVector startPoint = null;
  Comparator comp = null;
  boolean rowIsAlongXAxis = true;
  
  if (initialDirection == DRAW_DIR_SE || initialDirection == DRAW_DIR_NW)
  {
    rowIsAlongXAxis = true;
    comp = xAscending;
  }
  else
  {
    rowIsAlongXAxis = false;
    comp = yAscending;
  }
  
  // now sort each row, reversing the direction after each row
  for (Float rowCoord : inRows.keySet())
  {
    println("row: " + rowCoord);
    List<PVector> row = inRows.get(rowCoord);
    // sort row ascending
    Collections.sort(row, comp);
    
    if (initialDirection == DRAW_DIR_NW || initialDirection == DRAW_DIR_NE)
      Collections.reverse(row);
  }
}



void sendPixels(Set<PVector> pixels, String pixelCommand, int initialDirection, int startCorner, float maxPixelSize, boolean scaleSizeToDensity)
{
  
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, initialDirection);
  
  sortPixelsInRowsAlternating(inRows, initialDirection, maxPixelSize);
  
  // that was easy.
  // load the queue
  // add a preamble
  
  // set the first direction
  int drawDirection = initialDirection;
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  addToCommandQueue(changeDir);
  
  // reverse the row sequence if the draw is starting from the bottom
  // and reverse the pixel sequence if it needs to be done (odd number of rows)
  boolean reversePixelSequence = false;
  List<Float> rowKeys = new ArrayList<Float>();
  rowKeys.addAll(inRows.keySet());
  Collections.sort(rowKeys);
  if (startCorner == DRAW_DIR_SE || startCorner == DRAW_DIR_SW)
  {
    Collections.reverse(rowKeys);
    if (rowKeys.size() % 2 == 0)
      reversePixelSequence = true;
  }

  // and move the pen to just next to the first pixel
  List<PVector> firstRow = inRows.get(rowKeys.get(0));

  PVector startPoint = firstRow.get(0);
  int startPointX = int(startPoint.x);
  int startPointY = int(startPoint.y);
  int halfSize = int(maxPixelSize/2.0);

  print("Dir:");
  if (initialDirection == DRAW_DIR_SE)
  {
    startPointX-=halfSize;
    println("SE");
  }
  else if (initialDirection == DRAW_DIR_SW)
  {
    startPointY-=halfSize;
    println("SW");
  }
  else if (initialDirection == DRAW_DIR_NW)
  {
    startPointX-=halfSize;
    println("NW");
  }
  else if (initialDirection == DRAW_DIR_NE)
  {
    startPointY-=halfSize;
    println("NE");
  }
  
  if (startPoint != null)
  {
    String touchdown = CMD_CHANGELENGTH+int(startPointX)+","+int(startPointY)+",END";
    addToCommandQueue(touchdown);
    addToCommandQueue(CMD_PENDOWN+"END");
  }
  
  boolean penLifted = false;

  // so for each row
  for (Float key : rowKeys)
  {
    List<PVector> row = inRows.get(key);
    if (reversePixelSequence)
      Collections.reverse(row);
      
    for (PVector v : row)
    {
      if (isHiddenPixel(v)) // check for masked pixels,
      {
        //println("It's outside the bright/dark threshold.");
        if (liftPenOnMaskedPixels)
        {
          if (!penLifted) // if the pen isn't already up
          {
            String raisePen = CMD_PENUP + "END";
            addToCommandQueue(raisePen);
            penLifted = true;
          }
          else
          {
           // println("Pen is already lifted.");
          }
          // now convert to ints 
          int inX = int(v.x);
          int inY = int(v.y);
          int pixelSize = int(maxPixelSize);
          // render a fully bright (255) pixel.
          String command = pixelCommand+inX+","+inY+","+int(pixelSize+0.5)+",255,END";
          addToCommandQueue(command);
        }
        else
        {
          //println("liftPenOnMaskedPixels is not selected.");
        }
        // so this pixel doesn't get added to the queue.
      }
      else // pixel wasn't masked - render it up
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        int pixelSize = int(maxPixelSize);
        if (scaleSizeToDensity)
        {
          pixelSize = scaleDensity(density, 255, int(maxPixelSize));
          density = 0;
        }
        int scaledPixelSize = int((pixelSize*getPixelScalingOverGridSize())+0.5);
        String command = pixelCommand+inX+","+inY+","+scaledPixelSize+","+density+",END";
  
        // put the pen down if lifting over masked pixels is on
        if (liftPenOnMaskedPixels && penLifted)
        {
//          println("Pen down.");
          String lowerPen = CMD_PENDOWN + "END";
          addToCommandQueue(lowerPen);
          penLifted = false;
        }
        addToCommandQueue(command);
      }
    }

    drawDirection = flipDrawDirection(drawDirection);
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    addToCommandQueue(command);
  }
  
  addToCommandQueue(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}


int flipDrawDirection(int curr)
{
  if (curr == DRAW_DIR_SE)
    return DRAW_DIR_NW;
  else if (curr == DRAW_DIR_NW)
    return DRAW_DIR_SE;
  else if (curr == DRAW_DIR_NE)
    return DRAW_DIR_SW;
  else if (curr == DRAW_DIR_SW)
    return DRAW_DIR_NE;
  else return DRAW_DIR_SE;
}
  

int getPixelDirectionMode()
{
  return pixelDirectionMode;
}


void sendSawtoothPixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWSAWPIXEL, renderStartDirection, renderStartPosition, getGridSize(), false);
}
void sendCircularPixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWROUNDPIXEL, renderStartDirection, renderStartPosition, getGridSize(), false);
}

void sendScaledSquarePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWPIXEL, renderStartDirection, renderStartPosition, getGridSize(), true);
}

void sendSolidSquarePixels(Set<PVector> pixels)
{
  for (PVector p : pixels)
  {
    if (p.z != MASKED_PIXEL_BRIGHTNESS)
      p.z = 0.0;
  }
  sendPixels(pixels, CMD_DRAWPIXEL, renderStartDirection, renderStartPosition, getGridSize(), false);
}

void sendSquarePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWPIXEL, renderStartDirection, renderStartPosition, getGridSize(), false);
}

void sendScribblePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWSCRIBBLEPIXEL, renderStartDirection, renderStartPosition, getGridSize(), false);
}


void sendOutlineOfPixels(Set<PVector> pixels)
{
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, DRAW_DIR_SE);
  
  sortPixelsInRowsAlternating(inRows, DRAW_DIR_SE, getGridSize());

  float halfGrid = getGridSize() / 2.0;
  for (Float key : inRows.keySet())
  {
    for (PVector p : inRows.get(key))
    {
      PVector startPoint = new PVector(p.x-halfGrid, p.y-halfGrid);
      PVector endPoint = new PVector(p.x+halfGrid, p.y+halfGrid);
      String command = CMD_DRAWRECT + int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
      addToCommandQueue(command);
    }
  }  
}

void sendOutlineOfRows(Set<PVector> pixels, int drawDirection)
{
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, drawDirection);
  
  sortPixelsInRows(inRows, drawDirection);

  PVector offset = new PVector(getGridSize() / 2.0, getGridSize() / 2.0);
  for (Float key : inRows.keySet())
  {
    PVector startPoint = inRows.get(key).get(0);
    PVector endPoint = inRows.get(key).get(inRows.get(key).size()-1);
    
    if (drawDirection == DRAW_DIR_SE)
    {
      startPoint.sub(offset);
      endPoint.add(offset);
    }
    else if (drawDirection == DRAW_DIR_NW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    else if (drawDirection == DRAW_DIR_SW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    else if (drawDirection == DRAW_DIR_NW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    
    String command = CMD_DRAWRECT + int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
    addToCommandQueue(command);
  }  
}

void sendGridOfBox(Set<PVector> pixels)
{
  sendOutlineOfRows(pixels, DRAW_DIR_SE);
  sendOutlineOfRows(pixels, DRAW_DIR_SW);
}


void sendOutlineOfBox()
{
  // convert cartesian to native format
  PVector tl = getDisplayMachine().inSteps(getBoxVector1());
  PVector br = getDisplayMachine().inSteps(getBoxVector2());

  PVector tr = new PVector(br.x, tl.y);
  PVector bl = new PVector(tl.x, br.y);
  
  tl = getDisplayMachine().asNativeCoords(tl);
  tr = getDisplayMachine().asNativeCoords(tr);
  bl = getDisplayMachine().asNativeCoords(bl);
  br = getDisplayMachine().asNativeCoords(br);
  
  String command = CMD_CHANGELENGTHDIRECT+(int)tl.x+","+(int)tl.y+","+getMaxSegmentLength()+",END";
  addToCommandQueue(command);

  command = CMD_CHANGELENGTHDIRECT+(int)tr.x+","+(int)tr.y+","+getMaxSegmentLength()+",END";
  addToCommandQueue(command);

  command = CMD_CHANGELENGTHDIRECT+(int)br.x+","+(int)br.y+","+getMaxSegmentLength()+",END";
  addToCommandQueue(command);

  command = CMD_CHANGELENGTHDIRECT+(int)bl.x+","+(int)bl.y+","+getMaxSegmentLength()+",END";
  addToCommandQueue(command);

  command = CMD_CHANGELENGTHDIRECT+(int)tl.x+","+(int)tl.y+","+getMaxSegmentLength()+",END";
  addToCommandQueue(command);
  
}

void sendVectorShapes()
{
  RPoint[][] pointPaths = getVectorShape().getPointsInPaths();      
  
  String command = "";
  
  // go through and get each path
  for (int i = 0; i<pointPaths.length; i++)
  {
    if (pointPaths[i] != null) 
    {
      boolean firstPointFound = false;
      for (int j = 0; j<pointPaths[i].length; j++)
      {
        PVector p = null;

        // look for the first point that's actually on the page
        if (!firstPointFound)
        {
          // get the first point
          RPoint firstPoint = pointPaths[i][j];
          p = new PVector(firstPoint.x, firstPoint.y);
          p = PVector.mult(p, (vectorScaling/100));
          p = PVector.add(p, getVectorPosition());
          p = getDisplayMachine().inSteps(p);
          if (getDisplayMachine().getPage().surrounds(p))
          {
            p = getDisplayMachine().asNativeCoords(p);
            
            // pen UP!
            addToCommandQueue(CMD_PENUP+"END");
            // move to this point and put the pen down
            command = CMD_CHANGELENGTH+(int)p.x+","+(int)p.y+",END";
            addToCommandQueue(command);
            addToCommandQueue(CMD_PENDOWN+"END");
            firstPointFound = true;
          }
        }
        else
        {
          RPoint point = pointPaths[i][j];
          p = new PVector(point.x, point.y);
          p = PVector.mult(p, (vectorScaling/100));
          p = PVector.add(p, getVectorPosition());
          p = getDisplayMachine().inSteps(p);
          if (getDisplayMachine().getPage().surrounds(p))
          {
            p = getDisplayMachine().asNativeCoords(p);
            command = CMD_CHANGELENGTHDIRECT+(int)p.x+","+(int)p.y+","+getMaxSegmentLength()+",END";
            addToCommandQueue(command);
          }
          else
          {
            firstPointFound = false;
          }
        }
      }
      if (firstPointFound)
      {
        // finished drawing that path
        addToCommandQueue(CMD_PENUP+"END");
      }
    }
  }
}

void sendMachineStoreMode()
{
  String overwrite = ",R";
  if (!getOverwriteExistingStoreFile())
    overwrite = ",A";
    
  addToCommandQueue(CMD_MACHINE_MODE_STORE_COMMANDS + getStoreFilename()+overwrite+",END");
}
void sendMachineLiveMode()
{
  addToCommandQueue(CMD_MACHINE_MODE_LIVE+"END");
}
void sendMachineExecMode()
{
  sendMachineLiveMode();
  if (storeFilename != null && !"".equals(storeFilename))
    addToCommandQueue(CMD_MACHINE_MODE_EXEC_FROM_STORE + getStoreFilename() + ",END");
}
void sendRandomDraw()
{
  addToCommandQueue(CMD_RANDOM_DRAW+"END");
}
void sendStartSwirling()
{
  addToCommandQueue(CMD_SWIRLING+"1,END");
}
void sendStopSwirling()
{
  addToCommandQueue(CMD_SWIRLING+"0,END");
}
void sendDrawRandomSprite(String spriteFilename)
{
  addToCommandQueue(CMD_DRAW_RANDOM_SPRITE+","+spriteFilename+",100,500,END");
}

  

