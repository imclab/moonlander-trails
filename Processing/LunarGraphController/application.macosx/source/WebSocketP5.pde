

WebSocketP5 socket;
int port = 8087; 

boolean messageRestart = false;  // so we know where the home position is
boolean firstRestartReceived = false; // so we don't draw anyone half way through a game


boolean initWebSocket() { 
  println("starting WebSocket server on port "+port); 
  socket = new WebSocketP5(this, port);
  return true;
}

void websocketOnMessage(WebSocketConnection con, String msg) {
  //println(msg);

  //  if (beginsWith(msg, "landscapeend")) { 
  //    drawLandscape();
  //  } 
  //  else if (beginsWith(msg, "landscape")) { 
  //    PVector p = new PVector(0, 0); 
  //    String numbers[] = getStringAfterChar(msg, ":").split(","); 
  //
  //    int index = int(numbers[0]); 
  //
  //    p.x = float(numbers[1]); 
  //    p.y = float(numbers[2]); 
  //
  //    println(p);
  //    //p.mult(0.5f);
  //    if (landscapePoints.size()<=index) {
  //      landscapePoints.add(p);
  //    } 
  //    else {
  //      landscapePoints.set(index, p);
  //    } 
  //    //p.y-=100;
  //    //p.mult(0.8);
  //  } 
  //  else 
  if (beginsWith(msg, "{")) { 

    try {
      String readablemsg = ""; 

      JSONObject msgJson = new JSONObject(msg);
      String type = msgJson.getString("type");
      //println(type+" "+ (type == "update"));
      readablemsg+=type+" "; 
      if (type.equals("restart")) { 
        move = true;
        commands.add(new Command(COMMAND_RESTART, 0,0));
        messageRestart = true; 
        firstRestartReceived = true; 
      } 
      else if (type.equals("update")) { 
      
        if(firstRestartReceived) { 
          
         
          PVector p1 = new PVector(msgJson.getInt("x"), msgJson.getInt("y")); 

          p1.div(100);  // messages from the clients are multiplied by 100 to avoid floating points. 
          
          
          readablemsg+=": "+p1.x+", "+p1.y; 
          receivePosition = p1.get(); 
          p1 = convertDataToLunarGraph(p1); 
          
          if(messageRestart) homePosition = p1.get(); 
          
          if((p1.x<0) || (p1.x>pageWidth) || (p1.y<0) || (p1.y>pageHeight) ) {
            move = true; 
           
          } else if (move) {
            moveToXYPos(p1);
            move = false;
          } 
          else {  
            lineToXYPos(p1,true); // add true for non-smooth drawing. 
          }
        }
      }
      webSocketMessages.add(readablemsg);
    }
    catch(JSONException e) {
    }
  }
}

void drawLandscape() { 
  println("drawing landscape..."); 

//  float gap = pageWidth/20;
//  float lineheight = pageHeight/4; 
//  
//  for (float x = 0; x<pageWidth; x+=gap) { 
//    lineToXYPos(x, lineheight*0.1); 
//    lineToXYPos(x, lineheight); 
//    lineToXYPos(x+(gap/2), lineheight); 
//    lineToXYPos(x+(gap/2), lineheight*0.1); 
//    
//    
//    
//    
//  }

  // draw corners
  int cornerSize = round(3 * stepsPerMil); 
 
//  moveToXYPos(0, cornerSize);
//  lineToXYPos(0, 0);
//  lineToXYPos(cornerSize, 0);
//
//  moveToXYPos(pageWidth-cornerSize, 0);
//  lineToXYPos(pageWidth, 0);
//  lineToXYPos(pageWidth, cornerSize);
//  
//  moveToXYPos(0, pageHeight - cornerSize);
//  lineToXYPos(0, pageHeight);
//  lineToXYPos(cornerSize, pageHeight);
//
//  moveToXYPos(pageWidth-cornerSize, pageHeight);
//  lineToXYPos(pageWidth, pageHeight);
//  lineToXYPos(pageWidth, pageHeight - cornerSize);

  PVector lastPos = new PVector(); 
  
  for (float offset = 0; offset<=landscapeWidth; offset+=landscapeWidth) { 

    for (int i = 0; i<landscapePoints.size(); i++) { 

      PVector p1 = ((PVector)landscapePoints.get(i)).get();
      p1.x+=offset; 

      if (p1.x>dataWidth) break; 

      p1 = convertDataToLunarGraph(p1);  
      if ((i==0) && (offset==0)) { 
        moveToXYPos(p1);
      } 
      else { 
        lineToXYPos(p1);
        lineToXYPos(lastPos.x, lastPos.y); 
        lineToXYPos(p1.x, p1.y); 
        //lineToXYPos(p1); 
      }
      lastPos = p1.get(); 
    }
  }
}

void websocketOnOpen(WebSocketConnection con) {
  println("WebSocket client joined");
  webSocketMessages.add("WebSocket client joined");
}

void websocketOnClosed(WebSocketConnection con) {
  println("WebSocket client left");
  webSocketMessages.add("WebSocket client left");
}

<<<<<<< HEAD


=======
>>>>>>> app
