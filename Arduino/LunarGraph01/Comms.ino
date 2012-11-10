
const int maxMessageLength = 256; 
char incoming[256]; 
char parseBuffer[15]; 
int cmdNumber; 
int cmd; 
float p1; 
float p2; 

int incomingCharCount = 0; 
int incomingParsePos = 0; 


void addCommand(int c, float p1, float p2) { 

  // check numCommands! 

  Command* cmd = &(commands[currentCommand+numCommands]); 
  cmd->cmd = c; 
  cmd->p1 = p1; 
  cmd->p2 = p2; 
  //currentCommand = (currentCommand+1)%numStoredCommands; 
  numCommands++; 

  Serial.print("ADDING COMMAND ");
  Serial.print(cmd->p1); 
  Serial.print(" " ); 
  Serial.println(cmd->p2); 


}

boolean nextCommand() { 
  if(numCommands==0) {
    sendReady();
    return false; 
  }

  Serial.print("NEXT COMMAND "); 
  Serial.print(numCommands); 
  Serial.print(" " ); 

  Command * c = &(commands[currentCommand]); 


  Serial.print(currentCommand); 

  Serial.print(" "); 
  Serial.print(c->p1); 
  Serial.print(" "); 
  Serial.print(c->p2); 
  Serial.println(" " ); 


  currentCommand = (currentCommand+1)%numStoredCommands; 

  numCommands--; 

  if(c->cmd == COMMAND_MOVE) {
    moveTo(c->p1, c->p2); 
  } else if(c->cmd == COMMAND_DRAW) { 
    lineTo(c->p1, c->p2); 
  }else if(c->cmd == COMMAND_DRAW_DIRECT) { 
    lineToDirect(c->p1, c->p2); 
  }
  
  sendReady();

  return true; 


}


void checkIncoming() { 

  if(Serial.available()>0) { 

    char c = Serial.read(); 
    if(incomingCharCount<maxMessageLength) {
      incoming[incomingCharCount] = c; 
    }
    else {
      Serial.println("MESSAGE TOO LONG! : "); 
      Serial.println(incoming); 
    }
    incomingCharCount++; 

    if(c=='\0') {

      // format = <cmdnum>,<cmd>,<p1>,<p2> 

      incomingParsePos = 0; 
      
      
      cmdNumber = parseIncomingInt(); 
      cmd = parseIncomingInt(); 
      p1  = parseIncomingFloat(); 
      p2  = parseIncomingFloat(); 

      Serial.print("cn:"); 
      Serial.print(cmdNumber);       
      Serial.print(" c:"); 
      Serial.print(cmd); 
      Serial.print(" p1:"); 
      Serial.print(p1); 
      Serial.print(" p2:");
      Serial.println(p2);  
      addCommand(cmd, p1, p2); 
      incoming[0] = '\0'; 
      incomingCharCount = 0; 
      
      //Serial.println("ready:1"); 
    } 

  }
}

int parseIncomingInt() { 

  insertNextNumberIntoBuffer(); 
  return atoi(parseBuffer); 

}


float parseIncomingFloat() { 

  insertNextNumberIntoBuffer(); 
  return atof(parseBuffer); 

}

boolean insertNextNumberIntoBuffer() { 

  
  // should probably check for end of parsebuffer or incoming string
  
  if(incoming[incomingParsePos]==',') incomingParsePos++;  

  int j = 0; 

  while((incoming[incomingParsePos]>='.' & incoming[incomingParsePos]<='9') || (incoming[incomingParsePos]=='-')){ 

    parseBuffer[j] = incoming[incomingParsePos]; 
    incomingParsePos++;
    j++;
  }
  parseBuffer[j] = '\0'; 
  return true; 

}


void sendReady() { 
    if(numCommands<numStoredCommands) {
    Serial.print("ready:");
    Serial.println(numStoredCommands-numCommands); 
  }
}





