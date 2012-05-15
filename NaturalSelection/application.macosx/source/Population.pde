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
  void display(int id) {
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

    rotX+=.003;
    rotY+=.001;
    rotZ+=.002;

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
  void naturalSelection() {

    _healthiestChild = population[0];

    for (int i = 0; i < population.length; i++) {
      if (population[i].getFitness() > _healthiestChild.getFitness()) {
        _healthiestChild = population[i];
      }
    }
  }
  
  void naturalSelectionSexual() {
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
  void generate() {
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
  
   void generateSexual() {
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
  void regenerate(){
    for (int i = 0; i < population.length; i++) {
      //get their genes
      DNA momgenes = mom.getGenes();
      //mutate their genes
      DNA child = new DNA(momgenes.getMutatedDNA(mutationRate));
      //fill the new population with the new child
      population[i] = new Drawing(child, width/2, height/2);
    }
  }

  float[] getMomDNA() {
    return mom.getGenes().getDNA();
  }

  void scoreCurrent(int m) {
    population[_id].score(m);
  }

  int getGenerations() {
    return generations;
  }

  //compute total fitness for the population
  float getTotalFitness() {
    float total = 0;
    for (int i = 0; i < population.length; i++) {
      total += population[i].getFitness();
    }
    return total;
  }

  Drawing getChildAt(int i) {
    return population[i];
  }
}

