
void keyPressed() { 
  //println(key); 

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
  } else if (key =='1') { 

    //setTimeQuadrant(1);
  } else if (key =='w') { 

    warmUpPen();
  } else if (key =='r') { 

    testRubber();
  }
}

