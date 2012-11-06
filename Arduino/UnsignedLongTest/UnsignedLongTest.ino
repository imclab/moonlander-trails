unsigned long startTime; 

void setup() { 
  int delayMils = 5;
  startTime = micros(); 
  Serial.begin(115200); 
  
  
  startTime += delayMils*1000; 
  
  Serial.println(startTime); 
  
}

void loop() { 
  int delayMils = 500; 
  
  unsigned long delayMicros = (unsigned long)(delayMils)*1000; 
  
  Serial.print(delayMicros); 
  Serial.print(" "); 
  
  startTime = micros(); 
  Serial.print(micros()); 
  startTime = micros() + delayMils*1000; 
  Serial.print(" "); 
  Serial.println(startTime); 
  
  delay(5000); 
  
  
}
