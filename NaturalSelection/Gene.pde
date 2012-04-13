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
  float getScaledValue(){
   return _val*(_max-_min)+_min;
  }
  
  
  
}
