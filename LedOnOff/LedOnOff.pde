/*
 
A simple Processing script for enabling or disabling the LED on an Arduino using a web interface and serial communication.
Author: Sindre Lindstad
Created: 19th of January 2011
 
http://projects.sindrelindstad.com
 
*/
 import processing.serial.*;
 Serial port;
 PrintWriter output;
 PImage outImage;
 
 PImage ByteArrayToImage(byte[] data, int w, int h, int ch);
 void makeJPG(byte[] inBuffer);
 void keyPressed();
 
 void setup()  {
   
   println(Serial.list());
   /* This part must be altered to fit your local settings. The number in brackets after "Serial.list()" is where you declare what COM port your Arduino is connected to.
      If you get error messages, try a different number starting from 0 (e.g. 0, 1, 2, 3...) . */
    port = new Serial(this, Serial.list()[0], 115200);  // Open the port that the Arduino board is connected to, at 9600 baud
     // Create a new file in the sketch directory
    //output = createWriter("camera.jpg"); 
}

 void draw() {
 
  String onoroff[] = loadStrings("http://localhost/LEDstate.txt"); // Insert the location of your .txt file    
  print(onoroff[0]);  // Prints whatever is in the file ("1" or "0")
  
 
  if (onoroff[0].equals("1") == true) {
    //println(" - TELLING ARDUINO TO TURN LED ON");
    port.write('H'); // Send "H" over serial to set LED to HIGH
 
  } else {
 
    //println(" - TELLING ARDUINO TO TURN LED OFF");
    port.write('L');  // Send "L" over serial to set LED to LOW
 }
 byte[] inBuffer = new byte[32768]; //32KB
 
 while(port.available() > 0){
     inBuffer = port.readBytes();
     port.readBytes(inBuffer);
     if (inBuffer != null){
       //String myString = new String(inBuffer);
       //output.print(myString);
     }   
 }
 
 makeJPG(inBuffer);
 image(outImage,0,0); 
 //output.flush(); // Writes the remaining data to the file
 //output.close(); // Finishes the file
 
 //keyPressed();
 println("- Processing running ");
 }
 
  PImage ByteArrayToImage(byte[] data, int w, int h, int ch){
  //make a new image
  PImage outImage = new PImage(w,h,RGB);
 
  //copy date to this new image 
  outImage.loadPixels();
  
  for(int i = 0; i < w*h; i++)
  {
    outImage.pixels[i] = color(data[i*ch],data[i*ch+1],data[i*ch+2]);
  }
  
  outImage.updatePixels();
  
  return outImage;
}

 void makeJPG(byte[] inBuffer){
    int w = 320;
    int h = 240;
    int ch = 3; //colour channels per pixel
  
    //this is what you would get from you micro-controller
    //you have to know the dimensions and what colour format it has
    //i.e. greay scale ch=1 or RGB = 3, or with alpha transparency ch = 4 
    byte[] imageFromMBED = inBuffer;
  
    outImage = ByteArrayToImage(imageFromMBED, w, h, ch);
  
    outImage.save("image.jpg"); //done!
 }
 
 void keyPressed() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}

