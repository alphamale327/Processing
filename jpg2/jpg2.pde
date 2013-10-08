import processing.serial.*;

Serial myPort;
OutputStream output;
String ImageFilename;
boolean picTaken;
void setup() {

  size(320, 240);

  //println( Serial.list() );
  myPort = new Serial( this, Serial.list()[0], 115200);
  myPort.clear();
  picTaken = false;
  File deletingFile = new File("tmpImage.jpg");
  deletingFile.delete();
  output = createOutput("tmpImage.jpg");
}


void draw() {
  try { 
    while ( myPort.available () > 0 ) {
      output.write(myPort.read());
      picTaken = true;
    }
    delay(3000);
    if(picTaken == true){
       imageUpdate();
       picTaken = false;
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
  } 
}


void imageUpdate() {

  try { 
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
   
    ImageFilename = "Photo_" + year() + "_" + month() + "_" + day() + "-" + hour() + "-" + minute() + "-" + second() +".jpg";
    PImage pic;
    pic = loadImage("tmpImage.jpg");
    pic.save(ImageFilename);
    File deletingFile = new File("tmpImage.jpg");
    deletingFile.delete();
    output = createOutput("tmpImage.jpg");
    image(pic, 0, 0);
    print(ImageFilename);
    println(" saved!");
  } 

  catch (IOException e) {
    e.printStackTrace();
  }
}
