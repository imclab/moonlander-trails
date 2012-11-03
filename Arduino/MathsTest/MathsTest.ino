


long pos1, pos2; 
float w; 
float ysquared;


unsigned long numCalcs; 

unsigned long startTime; 
unsigned long totalTime; 
unsigned long lastTime; 
unsigned long now; 
unsigned long maxTime; 
unsigned long minTime; 

void setup() { 
  
  pos1 = 0; 
  w = 15000; 
  maxTime = 0; 
  minTime = 999999999; 
  
  Serial.begin(115200);   
  
  startTime = micros(); 
}


void loop() { 
  
  float x = random(0.0f,15000.0f); 
  float y = random(0.0f,12000.0f);
  
  startTime = micros(); 
  updateLengths(x,y); 
  now = micros(); 
  lastTime = now-startTime; 
  totalTime += (lastTime);
 
  if(lastTime<minTime) minTime = lastTime; 
  if(lastTime>maxTime) maxTime = lastTime; 
  
  numCalcs++; 
  
  
  if(numCalcs % 1000 == 0) { 
    
    Serial.print("Ave:"); 
    Serial.print((float)totalTime/(float)numCalcs); 
    Serial.print(" max:"); 
    Serial.print(maxTime); 
    Serial.print(" min:"); 
    Serial.println(minTime); 
    
  }
  
  
}




void updateLengths(float x, float y) { 
  
  // whole function takes 148.52
  // (pre-storing sq(y) makes no difference, weirdly!
  // this line takes 81.96 microseconds  
  pos1 = round(sqrt(sq(x) + sq(y)));   
 // this line takes 88.72 micros
  pos2 = round(sqrt(sq(w-x) + sq(y)));   
  
  
}

