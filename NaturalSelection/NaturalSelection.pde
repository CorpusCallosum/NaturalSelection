// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

import hypermedia.video.*;
OpenCV opencv;
import java.awt.Rectangle;

PFont f;
Population popul;
int popCount = 0;
int popMax = 20;
int displayTime = 60;
int lastTime = 0;
int textSpacer = 30;
int _facesLastTime = 0;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 0;

boolean debug;


void setup() {
  size(1280, 800, P3D);
  colorMode(RGB, 1.0);
  f = loadFont("DINPro-Bold-29.vlw");
  smooth();
  // int popmax = 10;
  float mutationRate = .05;  // A pretty high mutation rate here, our population is rather small we need to enforce variety
  // Create a population with a target phrase, mutation rate, and population max
  popul = new Population(mutationRate, popMax);

  //face tracking!
  opencv = new OpenCV( this );
  opencv.capture( 320, 240 );                   // open video stream
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

  textMode(SCREEN);
  debug = false;
}

void draw() {
  background(0, 0, 0, .5);

  int mx = mouseX; 
  int my = mouseY;

  // Display the child
  popul.display(popCount);


  //change on a timer
  if (second()%displayTime == 0) {//change every 5 seconds
    if (second()!=lastTime) {
      //disabled for now, uncomment to enable timer
      //  next();
    }
  }




  //FACE TRACKING
  // grab a new frame
  // and convert to gray
  opencv.read();
  opencv.convert( GRAY );
  opencv.contrast( contrast_value );
  opencv.brightness( brightness_value );



  // Display some text
  textFont(f);
  textAlign(LEFT);
  fill(1);
  // translate(0,0);
  int y = height-100;
  text("Generation #" + (popul.getGenerations()+1) + " Iteration #"+(popCount+1)+"/"+popMax, 25, y);
  y += textSpacer;
  text("Rating:"+popul.getChildAt(popCount).fitness, 25, y);
  y += textSpacer;
  text("Total runtime:", 25, y);

  //WEBCAM DISPLAY
  // display the image
  if (debug)
    image( opencv.image(), 0, 0 );

  //FACE DETECTON************************************
  // face detection
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
  // draw face area(s)
  noFill();
  stroke(255, 0, 0);
  rectMode(CORNER);
  for ( int i=0; i<faces.length; i++ ) {
    if (debug)
      rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height ); 
    //score image
    popul.scoreCurrent(faces.length);
  }

  //advance when all look away
  if (faces.length == 0) {
    if (_facesLastTime > 0) {
      next();
    }
  }

  //log data
  if (faces.length != _facesLastTime) {
    
    Date d = new Date();
    long time = d.getTime()/1000; 

    String j = "{'type':'face','timestamp':"+time+",'numFaces':"+faces.length+"}";
    saveToFile(j);
  }

  _facesLastTime = faces.length;

  // fill(1,0,0,.5);
  //rect(0,0,width,height);
}

//go to next child or next generation
void next() {
  popCount++;
  // lastTime = second();
  //we have viewed all the children, so make a new generation
  if (popCount>=popMax) {
    popCount = 0;
    //generate new generation
    popul.naturalSelection();
    popul.generate();
  }
  lastTime = second();
}

void saveToFile(String s) {
  println("saveToFile: "+s);
  try {
    BufferedWriter writer = new BufferedWriter(new FileWriter("data.txt", true));
    writer.write(s);
    writer.flush();
    writer.close();
  } 
  catch (IOException ioe) {
    println("error: " + ioe);
  }
}

/**
 * Changes contrast/brigthness values for face camera
 */
void mouseDragged() {
  contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
  brightness_value = (int) map( mouseY, 0, width, -128, 128 );
}

//KEY INPUT
void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  } 
  else if (key == ' ') {
    //bypass timer to iterate next
    next();
  }
}

