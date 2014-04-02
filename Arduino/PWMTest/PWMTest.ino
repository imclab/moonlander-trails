void setup() {
  // put your setup code here, to run once:
  pinMode(2, OUTPUT); 
  pinMode(3, OUTPUT); 
  pinMode(4, OUTPUT); 
  
}

void loop() {
  // put your main code here, to run repeatedly:
  analogWrite(2, 50); 
  analogWrite(3, 50); 
  analogWrite(4, 50); 
  //analogWrite(13,12); 
  
}
