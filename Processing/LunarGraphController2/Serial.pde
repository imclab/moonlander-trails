
Serial serial; 
boolean serialCreated = false; 
String serialName = ""; 
boolean firstContact = false; 
//int numToSend = 0; 
boolean lunargraphReadyForCommand = false; 
int serialMessageCount = 0; 
String serialMessage = ""; 

boolean initSerial() { 

  if (serial!=null) { 
    closeSerial();
  }

  String ports[] = Serial.list(); 
  println(ports);
  for (int i = 0; i< ports.length; i++) { 

    if (ports[i].indexOf("tty.usb")!=-1) { 
      serial = new Serial(this, ports[i], 115200); 
      println("joining port : " + ports[i] ); 
      serialCreated = true; 

      break;
    }
  }

  if (serial==null) { 
    serialCreated = false; 
    println("no serial connection found"); 
    return false;
  } 
  else { 
    return true;
  }
}

void closeSerial() { 
  if (serial!=null) { 
    serial.clear(); 
    serial.stop() ;
  }

  serial = null;
}

void serialEvent(Serial serial) { 

  int inByte = serial.read(); 

  if (!firstContact) {
    firstContact = true; 
    println("Serial Connected !");
  }

// TODO QUEUE UP MESSAGES FOR PROCESSING OUTSIDE OF THIS INTERUPTs
  if ((inByte == 0) || (inByte == 10)) { 
    try {
      processMessage();
    } finally { 
     println("ERROR IN processMessage!");  
    }
  } 
  else if ((inByte>=32) && (inByte<=126)) { 
    serialMessage = serialMessage + char(inByte);  
    //println(inByte);
  }
}


void sendSerial(String msg) { 
  serial.write(msg); 
  serialMessages.add("->"+msg);
}
void processMessage () { 

  println("->" +serialMessage); 



  if (beginsWith(serialMessage, "*")) { 
    lastHeartbeat = millis(); 
    println("HEARTBEAT");


    String data = getStringAfterChar(serialMessage, " "); 
    String[] dataArray = split(data, " "); 
    
    println("MADE DATA ARRAY "+dataArray.length); 
    
    if (dataArray.length>=3) { 
      
      float x = float(dataArray[0]); 
      float y = float(dataArray[1]); 
      boolean readyformore = (int(dataArray[2]) == 1);
      
      lunargraphReadyForCommand = readyformore; 
      actualPosition.x = x; 
      actualPosition.y = y; 
      
      
      println("HEARTBEAT : "+ x+ " " +y+" " + readyformore + " |" + dataArray[2]+"|"); 
    }
  } 
  else { 
    serialMessages.add(serialMessage);
  }

  if (beginsWith(serialMessage, "ready")) {
// TODO - check this READY command
    //numToSend = int(getStringAfterChar(serialMessage, ":"));   
lunargraphReadyForCommand = int(getStringAfterChar(serialMessage, ":"))>0; 
    println("ready to send "+lunargraphReadyForCommand); 

    // format = <cmdnum>,<cmd>,<p1>,<p2> 
    //serial.write(++counter + ",1,"+random(0,1000)+","+random(0,1000)+"\0");
  } 
  else if (beginsWith(serialMessage, "pagewidth")) { 
    pageWidth = float(getStringAfterChar(serialMessage, ":"));   
    println("pageWidth set : "+pageWidth);
  } 
  else if (beginsWith(serialMessage, "pageheight")) { 
    pageHeight = float(getStringAfterChar(serialMessage, ":"));   
    println("pageHeight set : "+pageHeight);
  } 
  else if (beginsWith(serialMessage, "stepspermil")) { 
    stepsPerMil = float(getStringAfterChar(serialMessage, ":"));   
    println("stepsPerMil set : "+stepsPerMil);
    machineWidth = 3000 * stepsPerMil;
  } 
  else if (beginsWith(serialMessage, "pagetop")) { 
    pageTop = float(getStringAfterChar(serialMessage, ":"));   
    println("pageTop set : "+pageTop);
  } 
  else if (beginsWith(serialMessage, "CHANGE STATE")) { 
    String statemessage = (getStringAfterChar(serialMessage, ":"));
    lunargraphState = int(statemessage.split(",")[0]);
  } 
  else if (beginsWith(serialMessage, "buttons")) { 
    String buttonstatesstring = (getStringAfterChar(serialMessage, ":"));
    //lunargraphState = int(statemessage.split(",")[0]);
    for (int i = 0; i<buttonStates.length; i++) { 
      buttonStates[i] = buttonstatesstring.charAt(i)=='1' ? true : false;
    }
  }
  serialMessage = "";  
  println("------");
}

