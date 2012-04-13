// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

// The class for our "face", contains DNA sequence, fitness value, position on screen

// Fitness Function f(t) = t (where t is "time" mouse rolls over face)

class Drawing {

  DNA genes;      //face's DNA
  float fitness;  //how good is this face?
  float x, y;      //position on screen
  float rotX, rotY, rotZ = 0;

  int levelCnt = 0;

  //GENES
  float theta, l, branchStep, thickness, gRotY, gRotZ;
  int numSub, numLevels;

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
    //reset vars

    //MY GENES
    theta  = radians(genes.getGene(0)*360); //degree of rotation of branches
    l  = genes.getGene(1)*2+.1;               //the scale factor of sub-branches             
    numSub = round(genes.getGene(2)*5)+1; //number of branches per level
    numLevels = round(genes.getGene(3)*4)+1;
    float startSize = (genes.getGene(4)*(height/2))+height/5;
    branchStep = (genes.getGene(5)*4)-2; //range -2,+2
    gRotY  = radians(genes.getGene(6)*360); //degree of rotation of branches
    gRotZ  = radians(genes.getGene(7)*360); //degree of rotation of branches

    // branchGrowth = genes.getGene(5)*2;
    //  thickness = round(genes.getGene(5)*5)+1;

    //
    stroke(1);
    strokeWeight(1);
   // pushMatrix();
//    translate(width/2, height/2);
   /* rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);*/
    branch(startSize, 0);
 //   popMatrix();

   /* rotX+=.02;
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
    }*/
  }

  void branch(float h, int level) {
    // println("branch");

    // Each branch will be scaled
    h *= l;
    // numSub = ceil(numSub*(branchGrowth*(level+1)));
    //increment number of sub branches based on step num, per level
    int numSubBranches = round(numSub + (level*branchStep));
    //   println(h);

    // All recursive functions must have an exit condition!!!!
    // Here, ours is when it reaches the number of levels gene
    if (level < numLevels) {
      // if (h > 3) {
      for (float i = 0; i<=numSubBranches; i++) {
        pushMatrix();    // Save the current state of transformation (i.e. where are we now)
        rotateX(theta);   // Rotate by theta
        rotateY((i/numSubBranches)*(PI*2));   // Rotate Y
        //        rotateY(gRotY);   // Rotate by theta

        // rotateZ(gRotZ);   // Rotate by theta

        //Dont draw trunk
        if (level>0) {
          try{
            line(0, 0, 0, -h);  // Draw the branch
            translate(0, -h); // Move to the end of the branch
          }
          catch(Exception e){
            println("ERROR drawing trunk :( ");
            println(e);
          }
        }
        branch(h, level+1);       // Ok, now call myself to draw sub-branches
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
