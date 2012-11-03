


char incoming[100]; 

void setup() { 
  Serial.begin(115200); 
  
  int chr = '0'; 
    
  for(int i = 0; i<10; i++) { 
    incoming[i] = chr;  
    chr++; 
    
  }
  incoming[10] = '\0'; 
  
  
  Serial.println(incoming); 
  
}


void loop() { 
  
  
  
}
