/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
 
// Pin 13 has an LED connected on most Arduino boards.
// give it a name:


int const PEN_DROP_PIN = 42; // or 42? 
int const A_BRAKE_PIN = 40;
int const B_BRAKE_PIN = 51;

int led = B_BRAKE_PIN;
int counter = 0; 


// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);     
  
//  pinMode(19, OUTPUT); 
//  digitalWrite(19,LOW); 
// 
}

// the loop routine runs over and over again forever:
void loop() {
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(5000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(2000);               // wait for a second
  counter+=0.1; 
}
