Serial serial; 
boolean serialCreated = false; 
String serialName = ""; 
boolean firstContact = false; 
int numToSend = 0; 
int serialMessageCount = 0; 
String serialMessage = ""; 

boolean initSerial() { 

  if (serial!=null) { 
    closeSerial();
  }

  String ports[] = Serial.list(); 

  for (int i = 0; i< ports.length; i++) { 

    if (ports[i].indexOf("tty.usb")!=-1) { 
      serial = new Serial(this, ports[i], 38400); 
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
    println("Connected!");
  }

  if ((inByte == 0) || (inByte == 10)) { 
    processMessage();
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

  //println("->" +serialMessage); 

  serialMessages.add(serialMessage); 

  //println(serialMessage.substring(6,serialMessage.length()-1));
  if (beginsWith(serialMessage, "ready")) {

    numToSend = int(getStringAfterChar(serialMessage, ":"));   

    println("ready to send "+numToSend); 

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
    for(int i = 0; i<buttonStates.length; i++) { 
      buttonStates[i] = buttonstatesstring.charAt(i)=='1' ? true : false;
    }
    
  }
  serialMessage = "";  
  //println("------");
}

