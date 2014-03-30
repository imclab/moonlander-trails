 
int ledPin = 13; 
int inputPin = 50; 

float maximum = 0.4; // 40% maximum voltage


void setup() {
  // put your setup code here, to run once:
  pinMode(ledPin, OUTPUT); 
  pinMode(inputPin, INPUT); 
  
  Serial.begin(9600); 
  
}

void loop() {
  // put your main code here, to run repeatedly:

  //float value = (sin(millis()/1000.0f * PI) + 1.0f )*0.5f * maximum * 1024;
  
  if(digitalRead(inputPin)) digitalWrite(ledPin, HIGH);
  else digitalWrite(ledPin, LOW);
  //analogWrite(leftBrakePin, value); 
  //analogWrite(rightBrakePin, value); 
  
  //Serial.println((int)value); 
  
  

}
