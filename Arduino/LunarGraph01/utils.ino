float mapEaseInOut(float value, float min1, float max1, float min2, float max2) { 

  if(value<min1) return min2; 
  else if(value>max1) return max2; 
  
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


