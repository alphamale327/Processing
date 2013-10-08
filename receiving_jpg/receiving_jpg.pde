 import processing.serial.*;
 Serial myPort;
 PImage outImage;
 PrintWriter output;
 boolean readData;
  boolean started;
  int param;
  int pIndex;
  int aIndex;
  int photoSize;
  float avg;
  boolean drawLine;
  boolean noObstacle;
  boolean showResult;
  
  byte[] photo =new byte[0];
 void setup()  {
   
   println(Serial.list());
   /* This part must be altered to fit your local settings. The number in brackets after "Serial.list()" is where you declare what COM port your Arduino is connected to.
      If you get error messages, try a different number starting from 0 (e.g. 0, 1, 2, 3...) . */
    myPort = new Serial(this, Serial.list()[0], 115200);  // Open the port that the Arduino board is connected to, at 9600 baud
     // Create a new file in the sketch directory
    //output = createWriter("camera.jpg");
   readData = false;
   started =false;
   drawLine = false; 
   //noObstacle = false;
   output = createWriter("camera.jpg");
} 


void draw() 
{ 
  
  String inString = null; 
  
  if(readData) 
  { 
    getPhoto(); 
  } 
  else 
  { 
    if( myPort.available() > 0 ) 
    { 
      inString = myPort.readStringUntil(','); 
    } 
    if (inString != null) 
    { 
      println("Raw data: " + inString); 
      // split the string into multiple strings 
      // where there is a ":" 
      String items[] = split(inString, ':'); 
  
      // if there was more than one string after the split 
      if (items.length > 1) 
      { 
        // remove any whitespace from the label 
        String label = trim(items[0]); 
        // remove the ',' off the end 
        String val = split(items[1], ',')[0]; 
        // check what the label was and update the appropriate variable 
        if (label.equals("Ready")) 
        { 
          println(label); 
        } 
        else if (label.equals("Stopped")) 
        { 
          started = false; 
          println(label); 
        } 
        else if (label.equals("Ping")) 
        { 
          if (val != null) 
          { 
            param = PApplet.parseInt(val); 
            if (param >= 0) 
            { 
              drawLine = true; 
              println("Index: " + pIndex); 
              println("New ping: " + param + "\n"); 
            } 
            else 
            { 
              noObstacle = true; 
              drawLine = true; 
              println("New ping: No obstacle detected"); 
            } 
          } 
        } 
        else if (label.equals("Index")) 
        { 
          pIndex = PApplet.parseInt(val); 
        } 
        else if (label.equals("Clear")) 
        { 
          finished = true; 
        } 
        else if(label.equals("AIndex")) 
        { 
          aIndex = PApplet.parseInt(val); 
        } 
        else if (label.equals("Avg")) 
        { 
          avg = abs(PApplet.parseFloat(val)); 
          if(avg > 150) 
            avg = 150; 
          println("Av: " + avg); 
          println("Index: " + (aIndex)); 
          showResult = true; 
        } 
        else if(label.equals("Size")) 
        { 
          photoSize = PApplet.parseInt(val); 
          readData = true; 
          myPort.clear(); 
          println("Photosize: " + photoSize); 
          println("Beginning transmission..."); 
          myPort.write("send"); 
        } 
      }//if value in message 
    }//if not null 
  }//if not photo 
}//draw 

void keyPressed() 
{ 
  if(key == 27) 
  { 
    key = 0; 
    stop(); 
  } 
  else if(key == ' ') 
  { 
    myPort.write("size"); 
    println("Accessing file..."); 
  } 
  else if(key == 'p') 
  { 
    myPort.write("ping"); 
  } 
}//draw 

void getPhoto() 
{ 
  byte[] buffer = new byte[64]; 
  while(myPort.available() > 0) 
  { 
    int readBytes = myPort.readBytes(buffer); 
    print( "Reading "); 
    print( readBytes ); 
    println( " bytes..."); 
    for(int i = 0; i < readBytes; i++) 
    { 
      photo = append(photo, buffer[i]); 
    } 
    println("Bytes received: " + photo.length); 
    if(photoSize != 0 && photo.length == photoSize+3) 
    { 
      readData = false; 
      myPort.clear(); 
      println("Received"); 
      savePhoto(); 
    } 
  } 
} 

void savePhoto() 
{ 
  print( "Writing "); 
  print(photo.length); 
  println( " bytes to disk..."); 
   
    output.print(photo); 
    output.flush(); 
    output.close(); 
   
  println( "DONE!"); 
} 

void delay(int ms) 
{ 
  int time = millis(); 
  while (millis () - time < ms); 
} 

void stop() //catch esc key and stop properly 
{ 
  println("Stopping..."); 
  if (started) 
    myPort.write("stop"); 
  delay(200); 
  exit(); 
} 
