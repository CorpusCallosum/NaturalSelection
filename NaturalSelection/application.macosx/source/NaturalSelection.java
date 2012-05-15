import processing.core.*; 
import processing.xml.*; 

import processing.video.*; 
import hypermedia.video.*; 
import java.awt.Rectangle; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class NaturalSelection extends PApplet {

//*****************************************************
// Natural Selection
// Jack Kalish - ITP Spring 2012
//*****************************************************
// Based on: 
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>


Capture myCapture;




//CONTROL VARS

OpenCV opencv;
Timer _faceBufferTimer;
Timer _popCycleTimer;
Timer _rateTimer;

PFont f;
Population popul;
int popCount = 0;
int popMax = 5;
int displayTime = 60;
int lastTime = 0;
int textSpacer = 30;
int _facesLastTime = 0;
int _camWidth = 320;
int _camHeight = 240;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 21;

int y;    //var used to space text on screen

boolean debug, _anySeen;


public void setup() {
  //list available cameras
  println(Capture.list());
  // myCapture = new Capture(this, 320, 240, 30); 
  //myCapture.settings();  
  noCursor();
  size(1440, 900, P3D);
  //   size(1280, 800);

  colorMode(RGB, 1.0f);
  f = loadFont("DINPro-Bold-29.vlw");
  smooth();
  // int popmax = 10;
  float mutationRate = .05f;  // A pretty high mutation rate here, our population is rather small we need to enforce variety
  // Create a population with a target phrase, mutation rate, and population max
  popul = new Population(mutationRate, popMax, true);
  //makeNewGeneration();

  //face tracking!
  opencv = new OpenCV( this );
  // opencv.allocate(_camWidth,_camHeight);
  float s = 2;
  opencv.capture( PApplet.parseInt(320*s), PApplet.parseInt(240*s) ); 
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

  textMode(SCREEN);
  debug = false;
  _faceBufferTimer = new Timer(2);
  _popCycleTimer = new Timer(5);//1 min
  _rateTimer = new Timer(1);//how long to wait after finding face, before starting to rate image

  _popCycleTimer.start();

  _anySeen = false;

  //write start data, timestamp when software starts running
  Date d = new Date();
  long time = d.getTime()/1000; 
  String j = "{'type':'start','timestamp':"+time+"}";
  saveToFile(j);
}

public void draw() {
  background(0, 0, 0, .5f);

  int mx = mouseX; 
  int my = mouseY;

  // Display the child
  popul.display(popCount);

  displayText();
  detect();
}

public void displayText(){
   // Display some text
  textFont(f);
  textAlign(LEFT);
  fill(1);
  // translate(0,0);
  y = height-100;
  text("Generation #" + (popul.getGenerations()) + " Iteration #"+(popCount+1)+"/"+popMax, 25, y);
  y += textSpacer;
  text("Rating:"+popul.getChildAt(popCount).fitness, 25, y);
  y += textSpacer;
  //  text("Total runtime:", 25, y);
}

public void detect(){
  
  //FACE TRACKING
  // grab a new frame
  // and convert to gray
  opencv.read();
  opencv.convert( GRAY );
  opencv.contrast( contrast_value );
  opencv.brightness( brightness_value );

  //WEBCAM DISPLAY
  // display the image
  if (debug) {
    image( opencv.image(), 0, 0 );
    text("fps:"+frameRate, 500, y);
  }

  //FACE DETECTON************************************
  // face detection
  Rectangle[] faces = opencv.detect( 1.2f, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
  // draw face area(s)
  noFill();
  stroke(255, 0, 0);
  rectMode(CORNER);
  for ( int i=0; i<faces.length; i++ ) {
    if (debug)
      rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height ); //draw faces
  }

  //advance when all look away
  //and when timer is surpassed

  if (faces.length == 0) {

      _faceBufferTimer.update();
    
    
    if (_faceBufferTimer.isExpired()) {
      println("face buffer timer is expired, go next");
      //_faceBufferTimer.reset();
      _faceBufferTimer.stop();
      next();
    }
    
    if (_facesLastTime > 0) {
      //start timer here
      println("reset face buffer timer");
      _faceBufferTimer.reset();
      _faceBufferTimer.start();
      println("start face buffer timer");
      _rateTimer.stop();
    }
    
  }
  else {
    //A FACE IS FOUND
    _popCycleTimer.reset();
    _popCycleTimer.start();
    if (_facesLastTime == 0) {
      _rateTimer.start();
    }
  }

  _rateTimer.update();

  if (_rateTimer.isExpired()) {
    //start scoring image after miniumum facetime is up (2 seconds)
    popul.scoreCurrent(faces.length);
    _anySeen = true;
    _rateTimer.reset();
        _rateTimer.start();

    //WE HAVE AT LEAST ONE FACE
    //stay on this image
  //  _faceBufferTimer.reset();
  }

  _popCycleTimer.update();
  if (_popCycleTimer.isExpired()) {
    next();
  }

  //log data
  if (faces.length != _facesLastTime) {
    Date d = new Date();
    long time = d.getTime()/1000; 
    String j = "{'type':'face','timestamp':"+time+",'numFaces':"+faces.length+", 'generation':"+popul.getGenerations()+", 'iteration':"+popCount+"}";
    saveToFile(j);
  }

  _facesLastTime = faces.length;
}

//go to next child or next generation
public void next() {
  popCount++;
  _popCycleTimer.reset();
  _popCycleTimer.start();
  //we have viewed all the children, so make a new generation
  if (popCount>=popMax) {
    if (_anySeen) {//only advance if any of the generation were observed/rated
      makeNewGeneration();
    }
    else {
      //loop to first
      popCount = 0;
      popul.regenerate();
    }
  }
  _faceBufferTimer.reset();
  _rateTimer.reset();
}

public void makeNewGeneration() {
  _anySeen = false;
  popCount = 0;
  //generate new generation
  popul.naturalSelection();
  popul.generate();

  //record data
  Date d = new Date();
  long time = d.getTime()/1000;
  float[] momGenes = popul.getMomDNA();
  String data = "{'type':'generation','timestamp':"+time+", 'generation':"+popul.getGenerations()+", 'momGenes':[";
  int i;
  for (i = 0; i<momGenes.length-1;i++) {
    data+= momGenes[i]+",";
  }
  //final gene to string, no comma
  data+= momGenes[i]+"]}";
  saveToFile(data);

  //take screenshot with time stamp
  saveFrame("images/"+time+".jpg");
}

public void saveToFile(String s) {
  // println("saveToFile: "+s);
  try {
    BufferedWriter writer = new BufferedWriter(new FileWriter(dataPath("data.txt"), true));
    writer.write(s+"\n");
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
public void mouseDragged() {
  contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
  brightness_value = (int) map( mouseY, 0, width, -128, 128 );

  println("contrast_value: "+contrast_value);
  println("brightness_value: "+brightness_value);
}

//KEY INPUT
public void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  } 
  else if (key == ' ') {
    //bypass timer to iterate next
    next();
  }
  else if (key == 'o') {
    //randomize the next generation
    println("rotX: "+popul.rotX);
        println("rotY: "+popul.rotY);
    println("rotZ: "+popul.rotZ);
  }
  else if(key == 's'){
    _anySeen = true;
      popul.scoreCurrent(1);
  }
}

//*****************************************************
// Natural Selection
// Jack Kalish - ITP Spring 2012
//*****************************************************
// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

class DNA {

  //The genetic sequence
  float[] dna;
  int len = 20;  //arbitrary length

  //Constructor (makes a random DNA)
  DNA(boolean randomGenes ) {
    dna = new float[len];

    if (randomGenes) {
      //DNA is random floating point values between 0 and 1 (!!)
      //OR RANDOMIZE
      for (int i = 0; i < dna.length; i++) {
        dna[i] = random(0, 1);
      }
    }
    else {
      //DEFINE default values here
      for (int i = 0; i < dna.length; i++) {
        dna[i] = .4f;
      }
      
     
     // dna[0] = 0;    //degree of rotation of branches
      dna[1] = 0.2f;    //the scale factor of sub-branches       
     /* dna[2] = 0;    //number of branches per level
      dna[3] = 1;    //number of levels of recursion*/
      dna[4] = .1f;    //size of the first branch
      /*dna[5] = 1;    //change in number of branches per level range -2,+2*/
     
      /*
      //GENES ARE******
       #0  theta  = radians(genes.getGene(0)*360);                     //degree of rotation of branches
       #1  l  = genes.getGene(1)*2+.1;                                 //the scale factor of sub-branches             
       #2  numSub = round(genes.getGene(2)*5)+1;                       //number of branches per level
       #3  numLevels = round(genes.getGene(3)*4)+1;                    //number of levels of recursion
       #4  float startSize = (genes.getGene(4)*(height/2))+height/5;   //size of the first branch
       #5  branchStep = (genes.getGene(5)*4)-2;                        //range -2,+2


      /* dna[0] = 0.5;
       dna[1] = 0.5; 
       dna[2] = 0.5;
       dna[3] = 0.5;
       dna[4] = 0.5;
       dna[5] = 0.5; */
    }
  }

  DNA(float[] newdna) {
    //dna = (float []) newdna.clone();  //not working as an applet?
    dna = newdna;
  }

  //returns one element from array 
  public float getGene(int index) {
    return dna[index];
  }

  //**CROSSOVER***//
  //creates new DNA sequence from two (this & 
  public DNA mate(DNA partner) {
    float[] child = new float[dna.length];
    int crossover = PApplet.parseInt(random(dna.length));
    for (int i = 0; i < dna.length; i++) {
      if (i > crossover) child[i] = getGene(i);
      else               child[i] = partner.getGene(i);
    }
    DNA newdna = new DNA(child);
    return newdna;
  }

  //based on a mutation probability, picks a new random character in array spots
  public float[] getMutatedDNA(float amt) {
    // println("mutate child: ");
    float[] child = new float[dna.length];

    for (int i = 0; i < dna.length; i++) {
      // if (random(1) < m) {
      //create random offset between -.1 and .1
      //make sure it does not get bigger or smaller than 
      float randomOffset = random(-amt, amt);

      child[i] = constrain(dna[i] + randomOffset, 0, 1);

      //  println("dna "+i+": "+ dna[i]);
    }
    return child;
  }

  public float[] getDNA() {
    return dna;
  }
  
}

//*****************************************************
// Natural Selection
// Jack Kalish - ITP Spring 2012
//*****************************************************
// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

// The class for our phenotype, contains DNA sequence, fitness value, position on screen

// Fitness Function f(t) = t (where t is "time" mouse rolls over face)

class Drawing {

  DNA genes;      //face's DNA
  float fitness;  //how good is this face?
  float x, y;      //position on screen
  float rotX, rotY, rotZ = 0;

  int levelCnt = 0;

  //GENES
  float theta, l, branchStep, thickness, gRotY, gRotZ, rotRate;
  float startR, startG, startB, endR, endG, endB, _curl, curlRate;
  int numSub, numLevels;

  //Create a new face
  Drawing(DNA dna, float x_, float y_) {
    genes = dna;
    x = x_; 
    y = y_;
    fitness = 0;
  }

  //render the face
  public void render() {
    /* ok, so here, we are using the elements from the "genes" to pick properties for this face
     such as: head size, color, eye position, etc.
     Now, since every gene is a floating point between 0 and 1, we scale those values
     appropriately.*/
    //reset vars

    //MY GENES
    theta  = radians(genes.getGene(0)*360);                    //degree of rotation of branches
    l  = genes.getGene(1)*2+.1f;                                //the scale factor of sub-branches             
    numSub = round(genes.getGene(2)*5)+1;                      //number of branches per level
    numLevels = round(genes.getGene(3)*3)+2;                   //number of levels of recursion
    float startSize = (genes.getGene(4)*(height/2))+height/5;  //size of the first branch
    branchStep = (genes.getGene(5)*4)-2;                       //range -2,+2
    rotRate = genes.getGene(6);                                //rotation rate
    startR = genes.getGene(7);                                 //R
    startG = genes.getGene(8);                                 //G
    startB = genes.getGene(9);                                 //B
    endR = genes.getGene(10);                                  //endR
    endG = genes.getGene(11);                                  //endG
    endB = genes.getGene(12);                                  //endB
    _curl = radians(genes.getGene(13)*360);                                 
    curlRate = genes.getGene(14);                                 


    // gRotY  = radians(genes.getGene(6)*360);                    //degree of rotation of branches
    // gRotZ  = radians(genes.getGene(7)*360);                    //degree of rotation of branches

    //  thickness = round(genes.getGene(5)*5)+1;
     colorMode(HSB, 1.0f);

stroke(1);
    stroke(startR, startG, startB);
    strokeWeight(1);
    
    //pushMatrix();
    //rotateX(-PI/2);   // Rotate by theta

    branch(startSize, 0, theta, _curl);
    //popMatrix();
  }

  public void branch(float h, int level, float rot, float c) {

    //increment number of sub branches based on step num, per level
    int numSubBranches = round(numSub + (level*branchStep));

    float color1 = startR+((endR - startR)*(PApplet.parseFloat(level)/PApplet.parseFloat(numLevels)));
    float color2 = startG+((endG - startG)*(PApplet.parseFloat(level)/PApplet.parseFloat(numLevels)));
    float color3 = startB+((endB - startB)*(PApplet.parseFloat(level)/PApplet.parseFloat(numLevels)));

    //modify rate genes
    if(level>1){
    h *= l;
    rot *= rotRate;
    if(rot>=2*PI){
      rot -= 2*PI;
    }
    }

    // All recursive functions must have an exit condition!!!!
    // Here, ours is when it reaches the number of levels gene
    if (level < numLevels) {
      // if (h > 3) {
      for (float i = 0; i<=numSubBranches; i++) {
        pushMatrix();    // Save the current state of transformation (i.e. where are we now)
       

        // rotateZ(gRotZ);   // Rotate by theta

        //Dont draw trunk
        if (level>1) {
         
        //        rotateY(gRotY);   // Rotate by theta
          try {
            stroke(color1, color2, color3);
            line(0, 0, 0, -h);  // Draw the branch
            translate(0, -h); // Move to the end of the branch
          }
          catch(Exception e) {
            println("ERROR drawing trunk :( ");
            println(e);
          }
        }
    
        rotateX(rot);   // Rotate by theta
        rotateY((i/numSubBranches)*2*PI);   // Rotate Y
       // rotateY(curl);   // Rotate Y

        c *= curlRate;
        branch(h, level+1, rot, c);       // Ok, now call myself to draw sub-branches
        popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
      }
    }
  }

  public float getFitness() {
    return fitness;
  }

  public DNA getGenes() {
    return genes;
  }

  public void score(int m) {
    fitness += 1*m;
  }
}

//*****************************************************
// Natural Selection
// Jack Kalish - ITP Spring 2012
//*****************************************************
class Gene{
  
  int _id;
  float _val, _min, _max;
  
  Gene(int id, float val, float minimum, float maximum){
    
    _id = id;
    _val = val;
    _min = minimum;
    _max = maximum;
    
  }
  
  //return gene value scaled to max and min range
  public float getScaledValue(){
   return _val*(_max-_min)+_min;
  }
  
  
  
}
//*****************************************************
// Natural Selection
// Jack Kalish - ITP Spring 2012
//*****************************************************
// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

// A class to describe a population of recursive trees structures

class Population {

  int MAX;                      //population maximum
  float mutationRate;           //mutation rate
  Drawing[] population;         //arraylist to hold the current population
  DNA[] genotypes;
  ArrayList darwin;             //ArrayList which we will use for our "mating pool"
  int generations;              //number of generations
  int _id;
  Drawing _healthiestChild;
  Drawing mom;

  float rotX = 0;
  float rotY = 0;
  float rotZ = 0;

  //*INITIALIZE THE POPULATION*//
  Population(float m, int num, boolean randomize) {
    mutationRate = m;
    MAX = num;
    population = new Drawing[MAX];
    darwin = new ArrayList();
    generations = 0;
    for (int i = 0; i < population.length; i++) {
      population[i] = new Drawing(new DNA(randomize), width/2, height/2);
    }
    
   // rotateX(-PI);
   
  }

  //display all faces
  public void display(int id) {
    //   println("Population display: "+id);
    _id = id;

    pushMatrix();
    translate(width/2, height/2);
  //  rotateZ(-PI/2);
  //  rotateX(-PI/2);
 //   rotateY(PI);

    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    population[id].render();

    popMatrix();

    rotX+=.003f;
    rotY+=.001f;
    rotZ+=.002f;

    if (rotX >= 2*PI) {
      rotX = 0;
    }
    if (rotY >= 2*PI) {
      rotY = 0;
    }
    if (rotZ >= 2*PI) {
      rotZ = 0;
    }
  }



  //generate a mating pool
  public void naturalSelection() {

    _healthiestChild = population[0];

    for (int i = 0; i < population.length; i++) {
      if (population[i].getFitness() > _healthiestChild.getFitness()) {
        _healthiestChild = population[i];
      }
    }
  }
  
  public void naturalSelectionSexual() {
 //clear the ArrayList
    darwin.clear();

    //Calculate total fitness of whole population
    float totalFitness = getTotalFitness();

    //Calculate *normalized* fitness for each member of the population
    //based on normalized fitness, each member will get added to the mating pool a certain number of times a la roulette wheel
    //a higher fitness = more entries to mating pool = more likely to be picked as a parent
    //a lower fitness = fewer entries to mating pool = less likely to be picked as a parent
    for (int i = 0; i < population.length; i++) {
      float fitnessNormal = population[i].getFitness() / totalFitness;
      int n = (int) (fitnessNormal * 1000.0f);
      //print(n + " ");
      for (int j = 0; j < n; j++) {
        darwin.add(population[i]);
      }
    }
    //println();
    //println("----------------
  }

  //*CREATE A NEW GENERATION**//
  public void generate() {
    //add first member of next generation as an exact clone of the mother?
    //CHANGE THIS TO CHOOSE ONLY THE FITTEST, (no mating)
    for (int i = 0; i < population.length; i++) {
    //  println("make child: "+ i);
      mom = _healthiestChild;
      //get their genes
      DNA momgenes = mom.getGenes();
      //mutate their genes
      DNA child = new DNA(momgenes.getMutatedDNA(mutationRate));
      //fill the new population with the new child
      population[i] = new Drawing(child, width/2, height/2);
    }
    generations++;
  }
  
   public void generateSexual() {
    //add first member of next generation as an exact clone of the mother?
    //CHANGE THIS TO CHOOSE ONLY THE FITTEST, (no mating)
    for (int i = 0; i < population.length; i++) {
    //  println("make child: "+ i);
      mom = _healthiestChild;
      //get their genes
      DNA momgenes = mom.getGenes();
      //mutate their genes
      DNA child = new DNA(momgenes.getMutatedDNA(mutationRate));
      //fill the new population with the new child
      population[i] = new Drawing(child, width/2, height/2);
    }
    generations++;
  }
  
  //make new set of children from the same parent
  public void regenerate(){
    for (int i = 0; i < population.length; i++) {
      //get their genes
      DNA momgenes = mom.getGenes();
      //mutate their genes
      DNA child = new DNA(momgenes.getMutatedDNA(mutationRate));
      //fill the new population with the new child
      population[i] = new Drawing(child, width/2, height/2);
    }
  }

  public float[] getMomDNA() {
    return mom.getGenes().getDNA();
  }

  public void scoreCurrent(int m) {
    population[_id].score(m);
  }

  public int getGenerations() {
    return generations;
  }

  //compute total fitness for the population
  public float getTotalFitness() {
    float total = 0;
    for (int i = 0; i < population.length; i++) {
      total += population[i].getFitness();
    }
    return total;
  }

  public Drawing getChildAt(int i) {
    return population[i];
  }
}

class Timer {

  long _startTime;
  long _time;
  boolean _expired, _stopped;


  Timer(long t) {
    _time = t*1000; //convert from seconds to ms
    reset();
  }

  public float getElapsedTime() {
    return millis() - _startTime;
  }

  public void update() {
    if (!_stopped) {
      if (getElapsedTime() > _time) {
        _expired = true;
        //reset();
      }
    }
  }

  public boolean isExpired() {
    return _expired;
  }

  public void reset() {
    _startTime = millis();
    _expired = false;
    _stopped = true;
  }

  public void stop() {
    reset();
  }
  
  public void start() {
    _startTime = millis();
    _stopped = false;
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "NaturalSelection" });
  }
}
