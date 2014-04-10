class Command { 
  
  public : 
  
  Command(){
     Command(0,0,0,0);
  }
  
  Command (int _c, int _id, float _p1, float _p2) { 
    
    cmd = _c; 
    id = _id; 
    p1 = _p1; 
    p2 = _p2; 
    //p3 = _p3; 
    //p4 = _p4;   
  }
  
  
  
  int cmd; 
  unsigned long id; 
  float p1, p2; 
  
  
  
};
