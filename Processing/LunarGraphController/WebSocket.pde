WsServer socket;
int port = 8087; 

boolean initWebSocket() { 
  println("starting WebSocket server on port "+port); 
  socket = new WsServer(this, port);
  return true;
}

void onWsMessage(WebSocket con, String msg) {
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
      } 
      else if (type.equals("update")) { 

        PVector p1 = new PVector(msgJson.getInt("x"), msgJson.getInt("y")); 

        p1.div(100);  // messages from the clients are multiplied by 100 to avoid floating points. 
        
        
        readablemsg+=": "+p1.x+", "+p1.y; 
        receivePosition = p1.get(); 
        p1 = convertDataToLunarGraph(p1);  
        if (move) {
          moveToXYPos(p1);
          move = false;
        } 
        else {  
          lineToXYPos(p1, true);
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

  // draw corners
  int cornerSize = round(50 * stepsPerMil); 
 
  moveToXYPos(0, cornerSize);
  lineToXYPos(0, 0);
  lineToXYPos(cornerSize, 0);

  moveToXYPos(pageWidth-cornerSize, 0);
  lineToXYPos(pageWidth, 0);
  lineToXYPos(pageWidth, cornerSize);

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
      }
    }
  }
}

void onWSOpen(WebSocket con) {
  println("WebSocket client joined");
  webSocketMessages.add("WebSocket client joined");
}

void onWSClose(WebSocket con) {
  println("WebSocket client left");
  webSocketMessages.add("WebSocket client left");
}

