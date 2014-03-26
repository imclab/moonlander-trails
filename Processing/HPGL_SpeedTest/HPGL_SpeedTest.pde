

ArrayList circleShapes = new ArrayList(); 
float noiseOffset = 0; 
HPGLManager hpgl;

void setup() { 

  size(1200, 800);

  hpgl = new HPGLManager(this);
  noLoop(); 
  hpgl.initHPGL(); 
}



void draw() { 
  background(200, 200, 220);


 
  for(int i = 0; i<40; i+=2) { 
   println(i); 
   //hpgl.setVelocity(i); 
   hpgl.setVelocity(1); 
   
   //hpgl.hpgl.accelerationSelect(i); 
   float y = map(i, 0, 40, 100,700);
   for(float x = 100; x<=1000; x+=4) { 
     //float w = random(10);
     hpgl.line(new PVector(x,y ), new PVector(x+4, y));
     //x+=w-1; 
   }
  }
  
//   for(int i = 0; i<40; i+=2) { 
//   println(i); 
//   hpgl.hpgl.accelerationSelect(i); 
//   hpgl.line(new PVector(100, map(i, 0, 40, 100,700)), new PVector(1000, map(i, 0, 40, 100,700))); 
//  }
  

}




void stop() { 
  
  
  hpgl.close(); 
  super.stop();
}
