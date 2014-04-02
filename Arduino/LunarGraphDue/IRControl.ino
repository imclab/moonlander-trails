#ifdef IR_ENABLED

#include <IRremote2.h>


long currentIRButton = -1;
long lastIRReceived = 0;

const int LEFT_UP_CODE = 0x20DF40BF;
const int LEFT_DOWN_CODE = 0x20DFC03F;
const int RIGHT_UP_CODE = 0x20DF00FF;
const int RIGHT_DOWN_CODE = 0x20DF807F; 
const int RESET_CODE = 0x20DF4EB1; 
const int PEN_CODE = 0x20DF22DD; 

IRrecv irrecv(IR_PIN);

decode_results results;

void initIR() {

  irrecv.enableIRIn(); // Start the receiver
  //irrecv.blink13(true);

#ifdef EMULATION_MODE

  pinMode(47, OUTPUT);
  pinMode(49, OUTPUT);
  digitalWrite(47, HIGH);
  digitalWrite(49, LOW); // ground pin

#endif

}

bool checkIR() {


  long time = millis();
  int timeout = 150;
  bool changed = false;

  if (irrecv.decode(&results)) {
    //Serial.print("READ : " );
    //Serial.println(results.value, HEX);
    //dump(&results);
    irrecv.resume(); // Receive the next value

    if (results.value != 0xffffffff) {
      
      //if(results.decode_type == NEC) { 
      //  results.value = results.value & 0x0000f000;
      //}
      
      if (currentIRButton != results.value) {
        //    Serial.print("old ");
        //   Serial.println(currentIRButton, HEX);
        currentIRButton = results.value;
        Serial.print("PRESSED : ");
        Serial.println(currentIRButton, HEX);
        changed = true; 
      }
    }
    lastIRReceived = time;
  } else if ((currentIRButton != -1) && (time - lastIRReceived > timeout)) {
    currentIRButton = -1;
    Serial.println("RELEASED");
    //changed = true; 

  }


  leftUpPressed = false;
  leftDownPressed = false;
  rightUpPressed = false;
  rightDownPressed = false;
  resetPressed = false;
  togglePenPressed = false;
  // Serial.println(currentIRButton == 0x77E11078);
  if (results.decode_type == NEC) {
    if (currentIRButton == LEFT_UP_CODE) leftUpPressed = true;
    else if (currentIRButton == LEFT_DOWN_CODE) leftDownPressed = true;
    else if (currentIRButton == RIGHT_UP_CODE) rightUpPressed = true;
    else if (currentIRButton == RIGHT_DOWN_CODE) rightDownPressed = true;
    else if (currentIRButton == RESET_CODE) resetPressed = true;
    else if (currentIRButton == PEN_CODE) togglePenPressed = true; 
  }


  return changed; 

}

#else

void initIR() { }
bool checkIR() { }

#endif
