String getDateStringReverse(Date date) { 

  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  
  return(year+"-"+month+"-"+day);
}
String getDateString(Date date) { 

  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  
  return(day+"/"+month+"/"+year);
}
String getDateAndTimeString(long startMils, long endMils) { 
  Date date = new Date(startMils); 
  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  

  String startHours = ""+date.getHours(); 
  String startMins = ""+date.getMinutes(); 
  while (startHours.length ()<2) startHours = '0'+startHours;  
  while (startMins.length ()<2) startMins = '0'+startMins;  
  date.setTime(endMils); 
  String endHours = ""+date.getHours(); 
  String endMins = ""+date.getMinutes(); 
  while (endHours.length ()<2) endHours = '0'+endHours;  
  while (endMins.length ()<2) endMins = '0'+endMins;  


  //println(day+"/"+month+"/"+year+" "+startHours+":"+startMins+" - "+endHours+":"+endMins); 
  return(day+"/"+month+"/"+year+" "+startHours+":"+startMins+"-"+endHours+":"+endMins);
}


String getHourAndMinuteString(long mils) { 
    Date date = new Date(mils); 
    String hours = ""+date.getHours(); 
    String mins = ""+date.getMinutes(); 
    while (hours.length ()<2) hours = '0'+hours;  
    while (mins.length ()<2) mins = '0'+mins;  
    return (hours+mins); 

  
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


class PathData { 
 
   
  
  
  
  
  
  
  
}

