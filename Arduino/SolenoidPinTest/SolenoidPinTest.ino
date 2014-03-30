 
int penDownPin = 2; 
int leftBrakePin = 3;
int rightBrakePin = 4;
float maximum = 0.4; // 40% maximum voltage


void setup() {
  // put your setup code here, to run once:
  pinMode(penDownPin, OUTPUT); 
  pinMode(leftBrakePin, OUTPUT); 
  pinMode(rightBrakePin, OUTPUT); 
  
  Serial.begin(9600); 
  
}

void loop() {
  // put your main code here, to run repeatedly:

  float value = (sin(millis()/1000.0f * PI) + 1.0f )*0.5f * maximum * 1024;
  
  analogWrite(penDownPin, value);
  analogWrite(leftBrakePin, value); 
  analogWrite(rightBrakePin, value); 
  
  //Serial.println((int)value); 
  
  

}
