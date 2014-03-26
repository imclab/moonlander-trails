
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
  saveTable(records, "data/printrecords.csv");
  return lastIndex;
}

String getDateString(String s) { 

  return new Date(Date.parse(s)).toString();
}

String getDateString(long mils) { 

  return new Date(mils).toString();
}
