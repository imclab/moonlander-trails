
class PathData { 


  ArrayList paths = new ArrayList(); 
  ArrayList times = new ArrayList(); 
  //  int numPaths; 
  //  int numPoints;  
  JSONArray sessions;
  int lastSessionParsed = -1; 

  Date startTime;  // MM/DD/YY
  Boolean loaded = false; 
  String fileName;

  PathData(String fileName) {  // MM/DD/YY 

   // fileName = "2013-06-30.json";
    this.fileName = fileName; 
    
    startTime = convertFilenameToDate(fileName);
    println(startTime); 

//    String dateString = fileName; 
//
//    startTime = new Date(dateString);  // MM/DD/YY 

    
//    loadData();
//     loaded = false; 
//     sessions = new JSONArray(); 
//     paths = new ArrayList(); 
//    times = new ArrayList(); 
    
   // println("paths length : "+paths.size()); 
   // println("first path length : "+((ArrayList)paths.get(0)).size());
    //    ArrayList points = (ArrayList)paths.get(0); 
    //    for (int i = 0; i<points.size(); i++) { 
    //      println(i+" " +points.get(i));
    //    }
  }

  void loadData() { 
    //println("LOADING " +"http://node.seb.ly:8002/"+fileName); 
    String[] data = loadFile(fileName, true); 


    if (data.length>1) { 
      println("MULTI-LINE DATA FOUND");
      exit();
    }
    JSONObject json = JSONObject.parse(data[0]);

    sessions = json.getJSONArray("sessions");
    for (int i = 0; i<2 && i<sessions.size(); i++) { 
      parseSession(sessions, i);
    }
    loaded = true;
  }

  boolean update() { 
    boolean dirty = false;
    
    if(!loaded) return false; //
    //if(!loaded) loadData(); 
    
    if(lastSessionParsed < sessions.size()-1) {
      for (int i = 0; i<30; i++) { 
        if (lastSessionParsed+1< sessions.size()) { 
          parseSession(sessions, lastSessionParsed+1); 
          dirty = true;
        } 
      }
    } else if(sessions.size()>0) { 
      
     sessions = new JSONArray(); 
    }
    return dirty;
  }
  void renderTopBar() { 

    pushStyle();

    noStroke(); 
    fill(0, 0, 0); 
    blendMode(REPLACE);
    //fill(100,100,100); 
    //
    rect(0, 0, width, 40); 
    noFill(); 
    stroke(0, 255, 0); 

    for (int i = 0; i<times.size(); i++) { 

      long sessiontime = (Long)times.get(i); 

      if ((sessiontime<minTime) || (sessiontime>maxTime)) stroke(100); else stroke(0, 255, 0); 

      float xpos = map(sessiontime, startMils, endMils, 0, width); 
      //println(xpos);
      line(xpos, 0, xpos, 30);
    }

    /*
    for(int i = 0; i<paths.size(); i++) { 
     
     long sessiontime = (Long)times.get(i); 
     if ((sessiontime<minTime) || (sessiontime>maxTime)) stroke(100); else stroke(0, 255, 0); 
     
     float xpos = map(sessiontime, startMils, endMils, 0, width);
     line(xpos, 0, xpos, 30);
     
     }*/
    stroke(255, 255, 255); 

    for (int i = 0; i<24; i++) { 
      float x = map(i, 0, 24, 0, width); 
      line(x, 0, x, 10);
    }
    popStyle();
  }

  void parseSession(JSONArray sessions, int index) { 

    JSONObject session = sessions.getJSONObject(index); 

    println("session time stamp = "+session.getLong("time")); 
    println("Date object : "+new Date(session.getLong("time"))); 

    JSONArray jsonpaths = session.getJSONArray("paths");  
    long pathtime = session.getLong("time");

    for (int j = 0; j<jsonpaths.size(); j++) { 

      JSONArray path = jsonpaths.getJSONArray(j); 
      times.add(pathtime);  
      //println(path.size());

      ArrayList points = new ArrayList(); 

      for (int k = 0; k<path.size(); k++) { 

        JSONObject point = path.getJSONObject(k);
        PVector pv = new PVector(point.getFloat("x")/100.0f, point.getFloat("y")/100.0f); 
        points.add(pv); 
        pathtime +=100; 

        //println("   "+point.getInt("x")); //.size());
      }

      paths.add(points);
    }

    lastSessionParsed = index; 
    println(lastSessionParsed+" "+ sessions.size());
  }
}

