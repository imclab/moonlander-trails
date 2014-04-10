
const int maxMessageLength = 256;
char incoming[256];
char parseBuffer[15];

String readyString; 
// stores the last received command details

long cmdId;
int cmdType;
float p1,p2;

int incomingCharCount = 0;
int incomingParsePos = 0;



void addCommand(int c, float p1, float p2, int id = -1) {

  // check numCommands!
  // TODO HOW DOES THIS WORK!? IT SHOULDN'T!!!
  int commandindex = (currentCommand + numCommands) % numStoredCommands;

  if (commandindex < numStoredCommands) {
    Command* cmd = &(commands[commandindex]);
    cmd->cmd = c;
    cmd->p1 = p1;
    cmd->p2 = p2;
	cmd->id = id; 
    //currentCommand = (currentCommand+1)%numStoredCommands;
    numCommands++;
  }

  else {

    Serial.print("COMMAND INDEX OUT OF BOUNDS! ");
    Serial.println(commandindex);
  }
  //Serial.print("ADDING COMMAND ");
  //Serial.print(cmd->p1);
  //Serial.print(" " );
  //Serial.println(cmd->p2);


}

boolean nextCommand() {
  if (numCommands == 0) {
    sendReady();

    return false;
  }

  Serial.print("EXE:");

  Command * c = &(commands[currentCommand]);


  Serial.print(c->id);

  Serial.print(" ");
  Serial.print(currentCommand);

  Serial.print(" ");
  Serial.print(c->cmd);
  Serial.print(" ");
  Serial.print(commandStrings[c->cmd]);
  Serial.print(" ");
  Serial.print(c->p1);
  Serial.print(" ");
  Serial.print(c->p2);
  Serial.print(" " );
  Serial.print(numCommands);

  Serial.println(" " );


  currentCommand = (currentCommand + 1) % numStoredCommands;

  numCommands--;

  if (c->cmd == COMMAND_MOVE) {
    moveTo(c->p1, c->p2);
  } else if (c->cmd == COMMAND_DRAW) {
    lineTo(c->p1, c->p2);
  } else if (c->cmd == COMMAND_DRAW_DIRECT) {
    lineToDirect(c->p1, c->p2);
  }

  sendReady();

  return true;


}


void checkIncoming() {

  while (Serial.available() > 0) {

    char c = Serial.read();
    if (incomingCharCount < maxMessageLength) {
      incoming[incomingCharCount] = c;
    }
    else {
      Serial.println("MESSAGE TOO LONG! : ");
      Serial.println(incoming);
    }
    incomingCharCount++;

    if (c == '\0') {

      // format = <cmdnum>,<cmd>,<p1>,<p2>

      incomingParsePos = 0;


      cmdId = parseIncomingUnsignedLong();
      cmdType = parseIncomingInt();
      p1  = parseIncomingFloat();
      p2  = parseIncomingFloat();

      Serial.print("REC:");
      Serial.print(cmdId);
      Serial.print(" ");
      Serial.print(commandStrings[cmdType]);
      Serial.print(" ");
      Serial.print(p1);
      Serial.print(" ");
      Serial.println(p2);
      addCommand(cmdType, p1, p2, cmdId);

      incoming[0] = '\0';
      incomingCharCount = 0;


    }

  }
}

int parseIncomingInt() {

  insertNextNumberIntoBuffer();
  return strtol(parseBuffer, 0, 10);

}

unsigned long parseIncomingUnsignedLong() {

  insertNextNumberIntoBuffer();
  return strtoul(parseBuffer, NULL, 10);

}


float parseIncomingFloat() {

  insertNextNumberIntoBuffer();
  return strtof(parseBuffer, NULL);

}

boolean insertNextNumberIntoBuffer() {


  // should probably check for end of parsebuffer or incoming string

  if (incoming[incomingParsePos] == ',') incomingParsePos++;

  int j = 0;

  while ((incoming[incomingParsePos] >= '.' & incoming[incomingParsePos] <= '9') || (incoming[incomingParsePos] == '-')) {

    parseBuffer[j] = incoming[incomingParsePos];
    incomingParsePos++;
    j++;
  }
  parseBuffer[j] = '\0';
  return true;

}


void sendReady() {
  
  bool readyForMore = (numCommands < numStoredCommands-1);
  updateCartesianByLengths();
  
  readyString = "* " + String(xPos,2) + ' ' + String(yPos,2) + ' ' + (numStoredCommands-numCommands-1);
  
  
  Serial.println(readyString);
  //Serial.print(xPos);
  //Serial.print(" ");
  //Serial.print(yPos);
  //Serial.print(" " );
  //Serial.println(readyForMore);

}





