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

  DNA genes;      //drawing's DNA
  float fitness;  //how good is this drawing?
  float x, y;      //position on screen
  float rotX, rotY, rotZ = 0;

  int levelCnt = 0;

  //GENES
  float theta, l, branchStep, thickness, gRotY, gRotZ, rotRate;
  float startR, startG, startB, endR, endG, endB;
  int numSub, numLevels;

  //Create a new face
  Drawing(DNA dna, float x_, float y_) {
    genes = dna;
    x = x_; 
    y = y_;
    fitness = 0;
  }

  //render the face
  void render() {
    //reset vars

    //MY GENES
    theta  = radians(genes.getGene(0)*360);                    //degree of rotation of branches
    l  = genes.getGene(1)*2+.1;                                //the scale factor of sub-branches             
    numSub = round(genes.getGene(2)*5)+1;                      //number of branches per level
    numLevels = round(genes.getGene(3)*4)+1;                   //number of levels of recursion
    float startSize = (genes.getGene(4)*(height/2))+height/5; //size of the first branch
    branchStep = (genes.getGene(5)*4)-2;                       //range -2,+2
    rotRate = genes.getGene(6);                             //rotation rate
    startR = genes.getGene(7);                             //R
    startG = genes.getGene(8);                             //G
    startB = genes.getGene(9);                             //B
    endR = genes.getGene(10);                             //endR
    endG = genes.getGene(11);                             //endG
    endB = genes.getGene(12);                             //endB

    // gRotY  = radians(genes.getGene(6)*360);                    //degree of rotation of branches
    // gRotZ  = radians(genes.getGene(7)*360);                    //degree of rotation of branches

    //  thickness = round(genes.getGene(5)*5)+1;
     colorMode(HSB, 1.0);

stroke(1);
    stroke(startR, startG, startB);
    strokeWeight(1);

    branch(startSize, 0, theta);
  }

  void branch(float h, int level, float rot) {
    // println("branch");

    //increment number of sub branches based on step num, per level
    int numSubBranches = round(numSub + (level*branchStep));

    float color1 = startR+((endR - startR)*(float(level)/float(numLevels)));
    float color2 = startG+((endG - startG)*(float(level)/float(numLevels)));
    float color3 = startB+((endB - startB)*(float(level)/float(numLevels)));
    
 /*       println("LEVEL: "+level + "/"+numLevels);

    println("startR: "+startR);
    println("color1: "+color1);
        println("endR: "+endR);*/


    
    //modify rate genes
    h *= l;
    rot *= rotRate;
    if(rot>=2*PI){
      rot -= 2*PI;
    }

    // All recursive functions must have an exit condition!!!!
    // Here, ours is when it reaches the number of levels gene
    if (level < numLevels) {
      // if (h > 3) {
      for (float i = 0; i<=numSubBranches; i++) {
        pushMatrix();    // Save the current state of transformation (i.e. where are we now)
        rotateX(rot);   // Rotate by theta
        rotateY((i/numSubBranches)*(PI*2));   // Rotate Y
        //        rotateY(gRotY);   // Rotate by theta

        // rotateZ(gRotZ);   // Rotate by theta

        //Dont draw trunk
        if (level>0) {
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

        branch(h, level+1, rot);       // Ok, now call myself to draw sub-branches
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
    fitness += 1*m;
  }
}

