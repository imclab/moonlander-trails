/*
 * IRremote: IRrecvDump - dump details of IR codes with IRrecv
 * An IR detector/demodulator must be connected to the input RECV_PIN.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 * JVC and Panasonic protocol added by Kristian Lauszus (Thanks to zenwheel and other people at the original blog post)
 */

#include <IRremote2.h>
#define DEBUG

int RECV_PIN = 50;

long currentIRButton = -1; 
long lastIRReceived = 0; 

IRrecv irrecv(RECV_PIN);

decode_results results;

void setup()
{
  Serial.begin(115200);
  Serial.println("Ready!");
  

  pinMode(47, OUTPUT);
  pinMode(49, OUTPUT);
  digitalWrite(47, HIGH);
  digitalWrite(49, LOW); // ground pin
  
  
  irrecv.enableIRIn(); // Start the receiver
  irrecv.blink13(true);
  
  
  
}

// Dumps out the decode_results structure.
// Call this after IRrecv::decode()
// void * to work around compiler issue
//void dump(void *v) {
//  decode_results *results = (decode_results *)v
void dump(decode_results *results) {
  int count = results->rawlen;
  if (results->decode_type == UNKNOWN) {
    Serial.print("Unknown encoding: ");
  } 
  else if (results->decode_type == NEC) {
    Serial.print("Decoded NEC: ");
  } 
  else if (results->decode_type == SONY) {
    Serial.print("Decoded SONY: ");
  } 
  else if (results->decode_type == RC5) {
    Serial.print("Decoded RC5: ");
  } 
  else if (results->decode_type == RC6) {
    Serial.print("Decoded RC6: ");
  }
  else if (results->decode_type == PANASONIC) {	
    Serial.print("Decoded PANASONIC - Address: ");
    Serial.print(results->panasonicAddress,HEX);
    Serial.print(" Value: ");
  }
  else if (results->decode_type == JVC) {
     Serial.print("Decoded JVC: ");
  }
  Serial.print(results->value, HEX);
  Serial.print(" (");
  Serial.print(results->bits, DEC);
  Serial.println(" bits)");

}


void loop() {
  
  long time = millis(); 
  int timeout = 150; 
  if (irrecv.decode(&results)) {
    //Serial.print("READ : " ); 
    //Serial.println(results.value, HEX);
    //dump(&results);
    irrecv.resume(); // Receive the next value
    
    if(results.value != 0xffffffff) { 
      // if it's an apple remote, remove the device ID 
      if(results.decode_type == NEC) { 
        //results.value = results.value & 0x0000f000;
      }
      if(currentIRButton != results.value) { 
    //    Serial.print("old "); 
    //   Serial.println(currentIRButton, HEX);
        currentIRButton = results.value; 
        Serial.print("PRESSED : "); 
        
        Serial.println(currentIRButton, HEX); 
        dump(&results);
      }    
    }
    lastIRReceived = time; 
  } else if ((currentIRButton!=-1) && (time - lastIRReceived > timeout)) { 
    currentIRButton = -1; 
    Serial.println("RELEASED"); 
    
  }
  
  
}
