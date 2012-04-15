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

  float rotX, rotY, rotZ = 0;

  //*INITIALIZE THE POPULATION*//
  Population(float m, int num) {
    mutationRate = m;
    MAX = num;
    population = new Drawing[MAX];
    darwin = new ArrayList();
    generations = 0;
    for (int i = 0; i < population.length; i++) {
      population[i] = new Drawing(new DNA(false), width/2, height/2);
    }
  }

  //display all faces
  void display(int id) {
    //   println("Population display: "+id);
    _id = id;

    pushMatrix();

    translate(width/2, height/2);
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    population[id].render();

    popMatrix();


    rotX+=.01;
    rotY+=.03;
    rotZ+=.02;

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

  //*CREATE A NEW GENERATION**//
  void generate() {
    //add first member of next generation as an exact clone of the mother

    //CHANGE THIS TO CHOOSE ONLY THE FITTEST, (no mating)
    //refill the population with children from the mating pool
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

