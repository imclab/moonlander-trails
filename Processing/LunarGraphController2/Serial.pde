
Serial serial; 
boolean serialCreated = false; 
String serialName = ""; 
boolean firstContact = false; 
//int numToSend = 0; 
int lunargraphCommandsToSend = 0; 
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

  if ((inByte == 0) || (inByte == 10)) { 
   // try {
     //processIncomingSerialMessage(serialMessage);
		queuedSerialMessages.add(serialMessage); 
		serialMessage = "";  
      
   // } 
   // finally { 
   //   println("ERROR IN processIncomingSerialMessage!");
   // }
  } 
  else if ((inByte>=32) && (inByte<=126)) { 
    serialMessage = serialMessage + char(inByte);  
    //println(inByte);
  }
}


void sendSerial(String msg) { 
  serial.write(msg); 
  sentSerialMessages.add("->"+msg);
}
void processIncomingSerialMessage (String msg) { 

  println("->" +msg); 

  boolean validMessage = false; 

  if (beginsWith(msg, "*")) { 

    println("HEARTBEAT");


    String data = getStringAfterChar(msg, " "); 
    String[] dataArray = split(data, " "); 

    println("MADE DATA ARRAY "+dataArray.length); 

    if (dataArray.length>=3) { 

      float x = float(dataArray[0]); 
      float y = float(dataArray[1]); 
//      boolean readyformore = (int(dataArray[2]) == 1);

      lunargraphCommandsToSend = Integer.parseInt(dataArray[2]); 
      actualPosition.x = x; 
      actualPosition.y = y; 


      println("HEARTBEAT : "+ x+ " " +y+" " + lunargraphCommandsToSend ); 
      validMessage = true;
    }
  } 
  else { 
    sentSerialMessages.add(msg);
  }

  if (beginsWith(msg, "EXE:")) {

    String data = getStringAfterChar(msg, ":"); 
    String[] dataArray = split(data, " "); 

    // println("MADE DATA ARRAY "+dataArray.length); 

    if (dataArray.length>=7) { 

      int cmdid, type;
      float p1, p2; 
      try {
        cmdid = Integer.parseInt(dataArray[0]);
        type = Integer.parseInt(dataArray[2]); 
        p1 = Float.parseFloat(dataArray[4]);
        p2 = Float.parseFloat(dataArray[5]);
        // TODO - match it up with a command in the send commands array.
		int cmdindex = findCommandIndexInArray(cmdid, sentCommands); 
		
		if(cmdindex>=0) { 
			sentCommands.remove(cmdindex); 
		
		} else { 
			// corrupt data! 
			println("ERROR : LunarGraph reported command :"+cmdid+" but not found in sentCommands") ; 
		
		} 
        
      } 
      catch (NumberFormatException e) {
        //Will Throw exception!
        //do something! anything to handle the exception.
        validMessage = false; 
      }


    }


    validMessage = true;
  } 
  else if (beginsWith(msg, "pagewidth")) { 
    pageWidth = float(getStringAfterChar(msg, ":"));   
    println("pageWidth set : "+pageWidth);
  } 
  else if (beginsWith(msg, "pageheight")) { 
    pageHeight = float(getStringAfterChar(msg, ":"));   
    println("pageHeight set : "+pageHeight);
  } 
  else if (beginsWith(msg, "stepspermil")) { 
    stepsPerMil = float(getStringAfterChar(msg, ":"));   
    println("stepsPerMil set : "+stepsPerMil);
    machineWidth = 3000 * stepsPerMil;
  } 
  else if (beginsWith(msg, "pagetop")) { 
    pageTop = float(getStringAfterChar(msg, ":"));   
    println("pageTop set : "+pageTop);
  } 
  else if (beginsWith(msg, "CHANGE STATE")) { 
    String statemessage = (getStringAfterChar(msg, ":"));
    lunargraphState = Integer.parseInt(statemessage.split(",")[0]);
    validMessage = true;
  } 
  else if (beginsWith(msg, "buttons")) { 
    String buttonstatesstring = (getStringAfterChar(msg, ":"));

    for (int i = 0; i<buttonStates.length; i++) { 
      buttonStates[i] = buttonstatesstring.charAt(i)=='1' ? true : false;
    }
    // count the buttons? 
    validMessage = true;
  }
  
  println("------");

  if (validMessage) lastHeartbeat = millis();
}



int findCommandIndexInArray(int cmdIdToFind, ArrayList commandArray) { 

	for(int i = 0; i<commandArray.size(); i++) { 
		Command cmd = (Command)commandArray.get(i); 
		if(cmd.id == cmdIdToFind) return i; 
	}

	return -1; 
}
