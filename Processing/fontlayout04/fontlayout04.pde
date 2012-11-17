
int glyphWidth = 4, glyphHeight = 6, glyphSpacing = 2;

String text = "ABCDEFGHIJKLMNOP /.: 1234567890".toUpperCase();

void setup() {
  size(1024, 768);
  noFill();
}



void draw() {


  glyphWidth = 4; 
  glyphHeight = 6; 
  glyphSpacing = 2;

  background(0);

  stroke(255, 0, 0);
  //rect(boxX, boxY, boxWidth, boxHeight);

  // if string can't be split, just make it fit
  // if it can be split, then work out best layout

    String line = "Lunar Trails - GAME exhibition at the Dublin Science Gallery 17/11/12".toUpperCase(); 
 
  float glyphScaleFactor = 2;
  // println("Scale factor: " + glyphScaleFactor);
  glyphWidth *= glyphScaleFactor;
  glyphHeight *= glyphScaleFactor;
  glyphSpacing *= glyphScaleFactor;

  float marginTop = 10; 
  float marginLeft = 10;

  //text = "";


  float ofsX = marginLeft, ofsY = marginTop;

  int glyphMarginLeft = 0;
  for ( int i = 0; i < line.length(); i++ ) {
    drawGlyph(line.charAt(i),  ofsX + glyphMarginLeft,  ofsY);
    ofsX += glyphWidth + glyphSpacing;
  }
}



void drawGlyph(char glyph, float posX, float posY) {
  pushMatrix();
  translate(posX, posY);

  
  stroke(255);
  strokeWeight(1);
  scale(glyphWidth / 4.0, glyphHeight / 6.0);
  drawLetter(glyph);
  popMatrix();
}

void drawLetter(char letter) {
  if ( letter == 'A' ) {
    line(0, 6, 0, 1);
    line(0, 1, 2, 0);
    line(2, 0, 4, 1);
    line(4, 1, 4, 3);
    line(4, 3, 0, 3);
    line(4, 3, 4, 6);
  }

  if ( letter == 'B' ) {
    line(0, 0, 0, 6);
    line(0, 6, 3, 6);
    line(0, 0, 3, 0);
    line(3, 0, 4, 1);
    line(4, 1, 4, 2);
    line(4, 2, 3, 3);
    line(3, 3, 0, 3);
    line(3, 3, 4, 4);
    line(4, 4, 4, 5);
    line(4, 5, 3, 6);
  }
  if ( letter == 'C' ) {
    line(0, 0, 0, 6);
    line(4, 0, 0, 0);
    line(0, 6, 4, 6);
  }
  if ( letter == 'D' ) {
    line(0, 0, 0, 6);
    line(0, 0, 3, 0);
    line(3, 0, 4, 2);
    line(4, 2, 4, 4);
    line(4, 4, 3, 6);
    line(0, 6, 3, 6);
  }
  if ( letter == 'E' ) {
    line(0, 0, 0, 6);
    line(4, 0, 0, 0);
    line(4, 3, 0, 3);
    line(0, 6, 4, 6);
  }
  if ( letter == 'F' ) {
    line(0, 0, 4, 0);
    line(0, 3, 4, 3);
    line(0, 0, 0, 6);
  }
  if ( letter == 'G' ) {
    line(0, 0, 0, 6);
    line(0, 0, 4, 0);
    line(4, 0, 4, 1);
    line(2, 3, 4, 3);
    line(4, 3, 4, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == 'H' ) {
    line(0, 0, 0, 6);
    line(0, 3, 4, 3);
    line(4, 0, 4, 6);
  }
  if ( letter == 'I' ) {
    line(0, 0, 4, 0);
    line(2, 0, 2, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == 'J' ) {
    line(0, 4, 1, 6);
    line(2, 0, 4, 0);
    line(4, 0, 4, 6);
    line(1, 6, 4, 6);
  }
  if ( letter == 'K' ) {
    line(0, 0, 0, 6);
    line(0, 3, 4, 0);
    line(0, 3, 4, 6);
  }
  if ( letter == 'L' ) {
    line(0, 0, 0, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == 'M' ) {
    line(0, 0, 0, 6);
    line(0, 0, 2, 2);
    line(2, 2, 4, 0);
    line(4, 0, 4, 6);
  }
  if ( letter == 'N' ) {
    line(0, 0, 0, 6);
    line(0, 1, 4, 5);
    line(4, 0, 4, 6);
  }
  if ( letter == 'O' ) {
    line(0, 0, 0, 6);
    line(0, 0, 4, 0);
    line(4, 0, 4, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == 'P' ) {
    line(0, 0, 0, 6);
    line(0, 0, 4, 0);
    line(4, 0, 4, 3);
    line(0, 3, 4, 3);
  }
  if ( letter == 'Q' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 4);
    line(4, 4, 2, 6);
    line(2, 6, 0, 6);
    line(0, 6, 0, 0);
    line(2, 4, 4, 6);
  }
  if ( letter == 'R' ) {
    line(0, 0, 0, 6);
    line(0, 0, 4, 0);
    line(4, 0, 4, 3);
    line(4, 3, 0, 3);
    line(0, 3, 4, 6);
  }
  if ( letter == 'S' ) {
    line(0, 0, 0, 3);
    line(0, 0, 4, 0);
    line(0, 3, 4, 3);
    line(4, 3, 4, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == 'T' ) {
    line(0, 0, 4, 0);
    line(2, 0, 2, 6);
  }
  if ( letter == 'U' ) {
    line(0, 0, 0, 5);
    line(0, 5, 1, 6);
    line(1, 6, 3, 6);
    line(4, 0, 4, 5);
    line(4, 5, 3, 6);
  }
  if ( letter == 'V' ) {
    line(0, 0, 2, 6);
    line(4, 0, 2, 6);
  }
  if ( letter == 'W' ) {
    line(0, 0, 0, 6);
    line(0, 6, 2, 4);
    line(2, 4, 4, 6);
    line(4, 0, 4, 6);
  }
  if ( letter == 'X' ) {
    line(0, 0, 2, 3);
    line(2, 3, 0, 6);
    line(4, 0, 2, 3);
    line(2, 3, 4, 6);
  }
  if ( letter == 'Y' ) {
    line(0, 0, 2, 2);
    line(2, 2, 4, 0);
    line(2, 2, 2, 6);
  }
  if ( letter == 'Z' ) {
    line(0, 0, 4, 0);
    line(4, 0, 0, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '0' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 6);
    line(0, 0, 0, 6);
    line(0, 6, 4, 0);
    line(0, 6, 4, 6);
  }
  if ( letter == '1' ) {
    line(0, 0, 2, 0);
    line(2, 0, 2, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '2' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 3);
    line(4, 3, 0, 3);
    line(0, 3, 0, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '3' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 6);
    line(0, 3, 4, 3);
    line(0, 6, 4, 6);
  }
  if ( letter == '4' ) {
    line(0, 0, 0, 3);
    line(0, 3, 4, 3);
    line(4, 0, 4, 6);
  }
  if ( letter == '5' ) {
    line(0, 0, 0, 0);
    line(0, 0, 4, 0);
    line(0, 0, 0, 3);
    line(0, 3, 4, 3);
    line(4, 3, 4, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '6' ) {
    line(0, 0, 4, 0);
    line(0, 0, 0, 6);
    line(0, 3, 4, 3);
    line(4, 3, 4, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '7' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 6);
  }
  if ( letter == '8' ) {
    line(0, 0, 4, 0);
    line(4, 0, 4, 3);
    line(4, 3, 0, 3);
    line(0, 3, 0, 0);
    line(4, 6, 4, 3);
    line(0, 3, 0, 6);
    line(0, 6, 4, 6);
  }
  if ( letter == '9' ) {
    line(0, 0, 0, 3);
    line(0, 3, 4, 3);
    line(0, 0, 4, 0);
    line(4, 0, 4, 6);
  }
  if ( letter == '!' ) {
    line(2, 0, 2, 4);
    line(2, 5, 2, 6);
  }
  if ( letter == ':' ) {
    line(2, 1, 2, 3);
    line(2, 4, 2, 6);
  }
  if ( letter == '.' ) {
    line(2, 5, 2, 6);
  }
  if ( letter ==',') {
    line(2, 5, 2, 7);
  }
  if (letter == '#') {
    line(1, 1, 1, 5);
    line(0, 2, 4, 2);
    line(0, 4, 4, 4);
    line(3, 1, 3, 5);
  }
  if (letter =='-') {
    line(1, 3, 3, 3);
  }

  if (letter == '/') {
    line(0, 6, 4, 0);
  }
}

