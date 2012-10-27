

void setup() {
  Serial.begin(9600); 

  Serial.println("BEGIN"); 

  for(float i = 0.0f; i<2.0f; i+=0.01f) { 

    //    Serial.print(i); 
    //    Serial.print(" "); 
    //    Serial.println(  );
    //

    Serial.println(mapEaseInOut(i, 0.0f, 2.0f, 0.0f,-5000.0f));
  }




}

void loop() {


}





float mapEaseInOut(float value, float min1, float max1, float min2, float max2) { 

  // get value between 0 and 1 
  float t = (value - min1) / (max1 - min1);  

  // ease it in and out
  t = constrain(t, 0.0f, 1.0f); 
  t = easeInOut(t);//, 0.0f, 1.0f, 1.0f);
  // and map it on to the output 

  float r = (t*(max2-min2)) + min2 ;  


  return r; 
 
}


float easeInOut(float t) {
	if ((t*=2)  < 1) return ((0.5f)*(t*t));
	return -0.5f * (((--t)*(t-2)) - 1);	
}

//
//float easeInOut(float t, float b , float c, float d) {
//  if ((t/=d/2) < 1) return ((c/2)*(t*t)) + b;
//  return -c/2 * (((--t)*(t-2)) - 1) + b;	
//}


