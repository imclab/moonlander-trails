#ifdef IR_ENABLED

#include <IRremote2.h>


long currentIRButton = -1;
long lastIRReceived = 0;

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

void checkIR() {


  long time = millis();
  int timeout = 150;

  if (irrecv.decode(&results)) {
    //Serial.print("READ : " );
    //Serial.println(results.value, HEX);
    //dump(&results);
    irrecv.resume(); // Receive the next value

    if (results.value != 0xffffffff) {
      
      if(results.decode_type == NEC) { 
        results.value = results.value & 0x0000f000;
      }
      
      if (currentIRButton != results.value) {
        //    Serial.print("old ");
        //   Serial.println(currentIRButton, HEX);
        currentIRButton = results.value;
        Serial.print("PRESSED : ");
        Serial.println(currentIRButton, HEX);
      }
    }
    lastIRReceived = time;
  } else if ((currentIRButton != -1) && (time - lastIRReceived > timeout)) {
    currentIRButton = -1;
    Serial.println("RELEASED");

  }


  leftUpPressed = false;
  leftDownPressed = false;
  rightUpPressed = false;
  rightDownPressed = false;
  resetPressed = false;
  // Serial.println(currentIRButton == 0x77E11078);
  if (results.decode_type == NEC) {
    if (currentIRButton == 0x1000) leftUpPressed = true;
    else if (currentIRButton == 0xB000) leftDownPressed = true;
    else if (currentIRButton == 0xD000) rightUpPressed = true;
    else if (currentIRButton == 0xE000) rightDownPressed = true;
    else if (currentIRButton == 0x4000) resetPressed = true;
  }




}

#else

void initIR() { }
void checkIR() { }

#endif
