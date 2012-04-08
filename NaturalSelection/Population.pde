// Interactive Selection
// http://www.genarts.com/karl/papers/siggraph91.html
// Daniel Shiffman <http://www.shiffman.net>

// A class to describe a population of faces
// this hasn't changed very much from example to example

class Population {

  int MAX;                      //population maximum
  float mutationRate;           //mutation rate
  Drawing[] population;         //arraylist to hold the current population
  ArrayList darwin;             //ArrayList which we will use for our "mating pool"
  int generations;              //number of generations
  int _id;
  Drawing _healthiestChild;

  //*INITIALIZE THE POPULATION*//
  Population(float m, int num) {
    mutationRate = m;
    MAX = num;
    population = new Drawing[MAX];
    darwin = new ArrayList();
    generations = 0;
    for (int i = 0; i < population.length; i++) {
      population[i] = new Drawing(new DNA(),width/2,height/2);
    }
  }

  //display all faces
  void display(int id) {
    _id = id;
   // for (int i = 0; i < population.length; i++) {
      population[id].render();
   // }
  }

  

  //generate a mating pool
  void naturalSelection() {
    //clear the ArrayList
   // darwin.clear();
    
    _healthiestChild = population[0];

    //Calculate total fitness of whole population
   // float totalFitness = getTotalFitness();

    //Calculate *normalized* fitness for each member of the population
    //based on normalized fitness, each member will get added to the mating pool a certain number of times a la roulette wheel
    //a higher fitness = more entries to mating pool = more likely to be picked as a parent
    //a lower fitness = fewer entries to mating pool = less likely to be picked as a parent
    for (int i = 0; i < population.length; i++) {
      if(population[i].getFitness() > _healthiestChild.getFitness()){
        _healthiestChild = population[i];
      }
      
      
     /* float fitnessNormal = population[i].getFitness() / totalFitness;
      int n = (int) (fitnessNormal * 1000.0f);
      //print(n + " ");
      for (int j = 0; j < n; j++) {
        darwin.add(population[i]);
      }*/
    }
    //println();
    //println("-------------------------------------------------------");
  }

  //*CREATE A NEW GENERATION**//
  void generate() {
    //add first member of next generation as an exact clone of the mother
    
    //CHANGE THIS TO CHOOSE ONLY THE FITTEST, (no mating)
    //refill the population with children from the mating pool
    for (int i = 0; i < population.length; i++) {
    //  int m = int(random(darwin.size()));
    //  int d = int(random(darwin.size()));
      //pick two parents
      Drawing mom = _healthiestChild;
     // Drawing dad =  (Drawing) darwin.get(d);
      //get their genes
      DNA momgenes = mom.getGenes();
     // DNA dadgenes = dad.getGenes();
      //mate their genes
      DNA child = momgenes; //.mate(dadgenes);
      //mutate their genese
      child.mutate(1);
      //fill the new population with the new child
      population[i] = new Drawing(child,width/2,height/2);
    }
    generations++;
  }
  
  void scoreCurrent(int m){
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
  
  Drawing getChildAt(int i){
    return population[i];
  }

}
