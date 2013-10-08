import processing.serial.*;

Serial myPort;
int i;
int TotalBytes;
String ImageFilename = "Photo_" + year() + "_" + month() + "_" + day() + "-" + hour() + "-" + minute() + "-" + second() +".jpg";
PrintWriter output;
void setup()
{
  //Set and open serial port
  println( Serial.list() );
  myPort = new Serial( this, Serial.list()[0], 115200 );
  output = createWriter(ImageFilename); 
}

void draw()
{
  // Import Picture
  byte[] buffer = new byte[32000];

  while( myPort.available() > 0 )
  {
    buffer = myPort.readBytes();
    String myString ="";
   for(int i = 0 ; i < buffer.length; i++){ 
    if (buffer[i] == 'E' && buffer[i+1] == 'O' && buffer[i+2] == 'F'){
      // Save picture to file
          output.flush(); 
          output.close();
          println( "DONE!" );
          
          // Open Picture
          size(320, 240);
          PImage pic;
          pic = loadImage(ImageFilename);
          image(pic, 0, 0);
          //Flush serial port
          myPort.clear();
          noLoop();
          break;
      }else{
        myString += (char)buffer[i];
      }
   }
      output.print(myString);
      buffer = null;
      println("buffer nulling");  
  }
}
