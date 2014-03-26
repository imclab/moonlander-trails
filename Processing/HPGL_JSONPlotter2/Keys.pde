
void keyPressed() { 
  //println(key); 

  if (key == 'h') {
    println("INIT"); 
    hpglManager.initHPGL();
    hpglManager.setVelocity(1);
  } else if (key == 'p') {
    println("PRINT"); 
    plotPaths();
  } else if (key == 't') { 

    plotTestForces(); 
  
  } else if (key == '-') { 


    changeDataScale(0.98); 

    dirty = true;
  } else if (key == '=') { 

    changeDataScale(1.02);
  } 
}

