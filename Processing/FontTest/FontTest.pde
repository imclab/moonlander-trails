

import processing.serial.*; 
import org.json.*;


PFont font; 

void setup() { 
  font = loadFont("Monaco-11.vlw"); 
  size(800,600); 

}
void draw() { 
  
  textFont(font); 

  text("HELLO", 100,100); 
}
