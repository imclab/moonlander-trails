

void setup() { 
 pinMode(2, INPUT_PULLUP);  
  Serial.begin(38400); 
}


void loop() { 
  
  
  
  Serial.println(digitalRead(2));  
  delay(100); 
  
}
