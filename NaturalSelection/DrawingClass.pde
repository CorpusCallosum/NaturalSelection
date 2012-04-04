// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

// The class for our "face", contains DNA sequence, fitness value, position on screen

// Fitness Function f(t) = t (where t is "time" mouse rolls over face)

class Drawing {

  DNA genes;      //face's DNA
  float fitness;  //how good is this face?
  float x, y;      //position on screen
  int wh = 1000;    //size of rectangle enclosing face
  boolean rollover; //are we rolling over this face?
  int scl = 10;
  float rotX, rotY, rotZ = 0;

  //GENES
  float theta, l;
  int numSub;

  //Create a new face
  Drawing(DNA dna, float x_, float y_) {
    genes = dna;
    x = x_; 
    y = y_;
    fitness = 1;
  }

  //render the face
  void render() {
    /* ok, so here, we are using the elements from the "genes" to pick properties for this face
     such as: head size, color, eye position, etc.
     Now, since every gene is a floating point between 0 and 1, we scale those values
     appropriately.*/
    //MY GENES
    theta  = radians(genes.getGene(0)*360);
    l  = genes.getGene(1)*.4;
    numSub = round(genes.getGene(2)*2)+2;

    //
    stroke(1);
    strokeWeight(1);
    pushMatrix();
    translate(width/2, height/2);
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    branch(height/2);
    popMatrix();
    
    rotX+=.02;
    rotY+=.01;
    rotZ+=.03;

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

  void branch(float h) {
    println("branch");

    // Each branch will be 2/3rds the size of the previous one
    h *= l;

    println(h);

    // All recursive functions must have an exit condition!!!!
    // Here, ours is when the length of the branch is 2 pixels or less
    if (h > 3) {

      for (float i = 0; i<=numSub; i++) {
        pushMatrix();    // Save the current state of transformation (i.e. where are we now)
        rotateX(theta);   // Rotate by theta
        rotateY((i/numSub)*(PI*2));   // Rotate Y

        line(0, 0, 0, -h);  // Draw the branch
        translate(0, -h); // Move to the end of the branch
        branch(h);       // Ok, now call myself to draw two new branches!!
        popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
      }
    }
  }

  float getFitness() {
    return fitness;
  }

  DNA getGenes() {
    return genes;
  }

  void score(int m) {
    fitness += 0.25*m;
  }
}

