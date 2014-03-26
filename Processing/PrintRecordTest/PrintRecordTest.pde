import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

//Date startTime = new Date("04/18/2013");  // MM/DD/YY
//println(startTime);

SimpleDateFormat sdf = new SimpleDateFormat("MMM dd HH:mm:ss yyyy");


//Date date = new Date(); 
//println(new Date(Date.parse("06/11/2013 11:00:00")));
//println("d"+date);


void setup() { 

  Table records = loadTable("printrecords.csv", "header"); 

  TableRow row = records.getRow(0); 

  for (int i = 0; i<records.getRowCount(); i++) { 
    row = records.getRow(0);
  }

  addRow(0, 0, 0, 0, 0);
}

void draw() {
}

String getDateString(String s) { 

  return new Date(Date.parse(s)).toString();
}

String getDateString(long mils) { 

  return new Date(mils).toString();
}


int addPrintRecord(long minTime, long maxTime, float x, float y, float scale) { 
  Table records = loadTable("printrecords.csv", "header"); 
  int lastIndex = records.getRow(records.getRowCount()-1).getInt("printNum"); 
  println(lastIndex); 
  TableRow row = records.addRow(); 
  row.setInt("printNum", lastIndex+1);
  row.setString("printTime", new Date().toString()); 
  row.setString("minTime", getDateString(minTime)); 
  row.setString("maxTime", getDateString(maxTime)); 
  row.setFloat("xOffset", x); 
  row.setFloat("yOffset", y); 
  row.setFloat("scale", scale); 
  row.setString("recipient", "TBC");    
  saveTable(records, "data/printrecords2.csv", "tabbed");
  return lastIndex;
}

