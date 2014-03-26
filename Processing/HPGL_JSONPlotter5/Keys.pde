

Boolean controlPressed = false; 
void keyPressed() { 
  //println(key); 
 
  
  println(keysPressedCount); 
  if(!keys[keyCode]) {
    keys[keyCode] = true;
    keysPressedCount ++;   
  }
  if (keyCode == CONTROL) { 
    controlPressed = true; 
    println("CONTROL PRESSED");
  }


  if (key == 'h') {
    println("INIT"); 
    hpglManager.initHPGL();
    hpglManager.setVelocity(1);
    //hpglManager.setOffset(0,-6); // for board
  } else if (key == 'p') {
    println("PRINT"); 

    addPrintRecord(minTime, maxTime, dataOffset.x, dataOffset.y, dataScale);

    hpglManager.addPenCommand(1); 
    warmUpPen(); 

    hpglManager.addVelocityCommand(1); 

    plotLandscape();

    hpglManager.addPenCommand(2);
    warmUpPen();
    hpglManager.addVelocityCommand(1); 

    plotCross(leftMargin, topMargin, 5); 
    plotCross(rightMargin, topMargin, 5); 
    plotCross(rightMargin, topMargin + (visibleRect.h/3), 5); 
    plotCross(rightMargin, topMargin + (visibleRect.h/3*2), 5); 
    plotCross(rightMargin, bottomMargin, 5); 
    plotCross(leftMargin, bottomMargin, 5); 
    plotCross(leftMargin, topMargin + (visibleRect.h/3), 5); 
    plotCross(leftMargin, topMargin + (visibleRect.h/3*2), 5); 

    hpglManager.addPenCommand(2);

    renderTimes(true);
    hpglManager.addPenCommand(1);
    renderText(true);

    hpglManager.addPenCommand(1);

    hpglManager.addVelocityCommand(20); 
    plotPaths();
  } else if (key == 't') { 

    //    plotTestForces(); 

    //plotCross(leftMargin, topMargin); 
    //plotCross(rightMargin, topMargin); 
    plotCross(rightMargin, bottomMargin); 
    plotCross(leftMargin, bottomMargin); 
    renderText(true);
  } else if (key == '-') { 


    changeDataScale(0.98); 
    dirty = true;
  } else if (key == '=') { 
    changeDataScale(1.02);
  } else if (key =='w') { 
    warmUpPen();
  } else if (key =='r') { 
    testRubber();
  } else if (keyCode == RIGHT) {    
    changePathData(currentFileIndex+1);
  } else if (keyCode == LEFT) {     
    changePathData(currentFileIndex-1);
  } else if (keyCode == UP) { 
    changePathData(currentFileIndex+10);
  } else if (keyCode == DOWN) { 
    changePathData(currentFileIndex-10);
  } else if (key=='l') { 
    if (pathData!=null) pathData.loadData();
  }
  

  
 
  
}

void changePathData(int index) { 
  index = (int)clamp(index, 0, pathDataObjects.size()-1); 
  if (currentFileIndex == index) return;

  currentFileIndex = index; 
  pathData = (PathData)pathDataObjects.get(currentFileIndex); 
  dirty = true;
}


void keyReleased() { 
  
  if(keys[keyCode]) keysPressedCount--; 
  
  //keys[keyCode] = false;
  if(keysPressedCount ==0) { 
    keys = new boolean[526];
  }
  
  println(keysPressedCount); 
  
  if (key == CODED) { 
    if (keyCode == CONTROL) { 
      controlPressed = false; 
      println("CONTROL RELEASED");
    }
  }
}


boolean isKeyPressed(int k)
{
  //println(keyEvent.getKeyCode()); 
  //for(int i = 0; i < keys.length; i++)
  //  if(KeyEvent.getKeyText(i).toLowerCase().equals(k.toLowerCase())) 
  
  return keys[k];  
    
  
  //return false;
}

void checkKeys() { 
  
  float start = MAX_FLOAT; 
  float end = -1; 

  if (isKeyPressed('1')) { 
    start = min(start, 0); 
    end = max(end, 0.125); 
  
  } 
  if (isKeyPressed('2')) {
    start = min(start, 0.125); 
    end = max(end, 0.250); 
  } 
  if(isKeyPressed('3')) { 
    start = min(start, 0.25); 
    end = max(end, 0.375); 
  } 
  if (isKeyPressed('4')) { 
    start = min(start, 0.375); 
    end = max(end, 0.5); 
  } 
  if(isKeyPressed('5')){ 
    start = min(start, 0.5); 
    end = max(end, 0.625); 
  } 
  if (isKeyPressed('6')) { 
    start = min(start, 0.625); 
    end = max(end, 0.75); 
  }
  if(isKeyPressed('7')) { 
    start = min(start, 0.75); 
    end = max(end, 0.875); 
  } 
  if (isKeyPressed('8')) { 
    start = min(start, 0.875); 
    end = max(end, 1); 

  } 
  if (isKeyPressed('0')) { 
    start = min(start, 0); 
    end = max(end, 1); 

  }
  
  if(end>-1) { 
    setUnitTimeLimits(start, end); 
  
  }
  
  
}

void setUnitTimeLimits(float start, float end){
  
  sliderLeft.x = map(start, 0, 1, 0.0f, (float)width);
  sliderRight.x = map(end, 0, 1, -5.0f, (float)width-5); 
  dirty = true;
}
