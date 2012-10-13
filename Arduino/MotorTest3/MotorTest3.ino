//Define pins;
#define CLK_PIN 2
#define ENABLE_PIN 6
#define RESET_PIN 8
#define CCW_PIN 3

void setup() {
// Make all the pins OUTPUT and set them to LOW
for (int i = 8 ; i <= 11 ; i++) {
pinMode(i, OUTPUT);
digitalWrite(i, HIGH);
}

// This is the order according to the application notes
digitalWrite(RESET_PIN, LOW);
digitalWrite(ENABLE_PIN, LOW);
}

int del = 750;
int counter = 0;
int dir = LOW;

void loop() {
// Send out a clock signal. switch the direction bit every 2000 clocks.
digitalWrite(CLK_PIN, HIGH);
delayMicroseconds(del);
digitalWrite(CLK_PIN, LOW);
delayMicroseconds(del);
counter++;
if (counter == 2000) {
if (dir == LOW) {
dir = HIGH;
}
else {
dir = LOW;
}
digitalWrite(CCW_PIN, dir);
counter = 0;
}
}


