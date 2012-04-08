// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

import hypermedia.video.*;
OpenCV opencv;
import java.awt.Rectangle;

PFont f;
Population popul;
int popCount = 0;
int popMax = 5;
int displayTime = 5000;
int time = 0;
long timer = 0;
int lastTime = 0;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 0;
int rot = 0;

void setup() {
  size(1280, 800, P3D);
  colorMode(RGB, 1.0);
  f = loadFont("DINPro-Bold-29.vlw");
  smooth();
  // int popmax = 10;
  float mutationRate = .01;  // A pretty high mutation rate here, our population is rather small we need to enforce variety
  // Create a population with a target phrase, mutation rate, and population max
  popul = new Population(mutationRate, popMax);

  //face tracking!
  opencv = new OpenCV( this );
  opencv.capture( 320, 240 );                   // open video stream
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

  textMode(SCREEN);
}

void draw() {
  background(0);



  int mx = mouseX; 
  int my = mouseY;

  // Display the faces
  //   pushMatrix();

  popul.display(popCount);
  //  popMatrix();



  if (second()%5 == 0) {//change every 5 seconds
    if (second()!=lastTime) {
      popCount++;
      lastTime = second();
    }
  }


  //we have viewed all the children, so make a new generation
  if (popCount>=popMax) {
    popCount = 0;
    //generate new generation
    popul.naturalSelection();
    popul.generate();
  }
  lastTime = second();
  rot++;

  //FACE TRACKING
  // grab a new frame
  // and convert to gray
  opencv.read();
  opencv.convert( GRAY );
  opencv.contrast( contrast_value );
  opencv.brightness( brightness_value );

  // proceed detection
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );

  // display the image
  image( opencv.image(), 0, 0 );

  // Display some text
  textFont(f);
  textAlign(LEFT);
  fill(1);
  // translate(0,0);
  text("Generation #" + (popul.getGenerations()+1) + " Child #"+(popCount+1)+"/"+popMax, 25, height-50);
  text("Health:"+popul.getChildAt(popCount).fitness, 25, height - 25);

  // draw face area(s)
  noFill();
  stroke(255, 0, 0);
  rectMode(CORNER);
  for ( int i=0; i<faces.length; i++ ) {
    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height ); 
    //score image
    popul.scoreCurrent(faces.length);
  }
}

/**
 * Changes contrast/brigthness values for face camera
 */
void mouseDragged() {
  contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
  brightness_value = (int) map( mouseY, 0, width, -128, 128 );
}
