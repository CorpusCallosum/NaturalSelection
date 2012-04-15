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
        dna[i] = .2;
      }
      
     /* dna[0] = 0;  //degree of rotation of branches
      dna[1] = 0;  //the scale factor of sub-branches       
      dna[2] = 0;  //number of branches per level
      dna[3] = 1;  //number of levels of recursion
      dna[4] = 0; //size of the first branch
      dna[5] = 1; //change in number of branches per level range -2,+2*/
     
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
  float getGene(int index) {
    return dna[index];
  }

  //**CROSSOVER***//
  //creates new DNA sequence from two (this & 
  DNA mate(DNA partner) {
    float[] child = new float[dna.length];
    int crossover = int(random(dna.length));
    for (int i = 0; i < dna.length; i++) {
      if (i > crossover) child[i] = getGene(i);
      else               child[i] = partner.getGene(i);
    }
    DNA newdna = new DNA(child);
    return newdna;
  }

  //based on a mutation probability, picks a new random character in array spots
  float[] getMutatedDNA(float amt) {
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

  float[] getDNA() {
    return dna;
  }
}

