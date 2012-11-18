
void keyPressed() {
  if (key == 'r') { 
//    if (socket!=null) 
//      socket.stop();
//      
    closeSerial(); 
    initSerial();
    firstRestartReceived = false; 
//    initWebSocket(8087); 
  }
  if (key == 'f') { 
    //resize(displayWidth, displayHeight);  
    //frame.setSize(displayWidth, displayHeight);
    // frame.setUndecorated(true); 
    //frame.setLocation(0, 0);
    fullSizePreview = !fullSizePreview; 
    if (fullSizePreview) {
      //resize(displayWidth, displayHeight);  
      //frame.setSize(displayWidth, displayHeight);
      //frame.setLocation(0, 0);
      noSmooth();
    } 
    else {
      //resize(round(viewWidth*viewScale), round(viewHeight*viewScale));  
      //frame.setSize(round(viewWidth*viewScale), round(viewHeight*viewScale));
      smooth();
    }
  }
  if (key == 'l') { 
    drawLandscape();
  } 
  else if (key == 'p')  { 
    if (state == STATE_PAUSED) {
      state = STATE_RUNNING;
    } 
    else if (state == STATE_PAUSE_NEXT) { 
      state = STATE_PAUSED;
    } 
    else { 
      state = STATE_PAUSE_NEXT;
    }
  } 
  else if ((key == 'n')|| (key==' ')){ 
       
     if(state == STATE_RUNNING) { 
       state = STATE_PEN_CHANGE_NEXT; 
       //insertPenMoveIntoQueue(); 
     
     }  else if(state == STATE_PEN_CHANGE) { 
        state = STATE_RUNNING; 
        lastPenChange = millis(); 
       
     }   else if(state == STATE_PEN_CHANGE_NEXT) {
        state = STATE_RUNNING; 
     } 
     
     
   
    
  }
}

