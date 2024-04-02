/***************************************************
 This is a library for the Multi-Touch Kit
 Designed and tested to work with Arduino Uno, MEGA2560, LilyPad(ATmega 328P)
 
 For details on using this library see the tutorial at:
 ----> https://hci.cs.uni-saarland.de/multi-touch-kit/
 
 Written by Jan Dickmann, Narjes Pourjafarian, Juergen Steimle (Saarland University), Anusha Withana (University of Sydney), Joe Paradiso (MIT)
 MIT license, all text above must be included in any redistribution
 ****************************************************/


/*
This example shows how to use "Multi-Touch Kit Processing library" in your code.

This example contains the most important options of the library and tries to explain what they do.

It is recommended that you also read the comments in the sourcecode/the documentation.

Please insert the correct Serial Port and number of RX and TX based on the size of the sensor
*/


import gab.opencv.*;
import MultiTouchKitUI.*;
import processing.serial.*;
import blobDetection.*;
import themidibus.*; //Import the library


Table table;

//Here you will have to set the tx/rx numbers, as well as the serial port
int tx = 8;               //number of transmitter lines (rx)
int rx = 5;               //number of receiver lines (rx)
//int tx = 4;               //number of transmitter lines (rx)
//int rx = 4;               //number of receiver lines (rx)
int serialPort = 1;       //serial port that the Arduino is connected to
boolean debounceB0press = true;
boolean debounceB0release = false;
int recordingIndex = 0;

Serial myPort;
MultiTouchKit mtk;
MidiBus midiBus;
BlobMidi midiBlob0;
BlobMidi midiBlob1;
BlobMidi midiBlob2;
BlobMidi midiBlob3;
BlobMidi midiBlob4;

int maxInputRange = 170;  // set the brightness of touch points
float threshold = 0.8f;  // set the threshold for blob detection
int gridSize = 80; // use this to scale the size of the output picture (with small sensors you might want to increase the number, with big sensors maybe you want to decrease it)

class BlobMidi {
  private int id;
  private Blob blob;
  private Note note;
  private int octave = 3;
  private float x;
  private float y;
  private float w;
  private float h;
  private boolean record = false;
  private int channel;
  private int midiNote;
  private int midiVelocity;
  private int lastMidiNote =99;
  private MidiBus midibus;
  private boolean debouncePress = true;
  private boolean debounceRelease = false;
  private boolean active;
  private int mode = 3; //0 = drum , 1 = piano , 2 = granular synth, 3 = pentatonic scale
  private int[][] drumMatrix3x3 = {{0,0,0},{0,0,0},{36,40,46}};
  private int[][] drumMatrix2x2 = {{36,0},
                                  {40,46}}; //Y[X,X]
  private int[] pentatonic = {0,3,5,7,10};

  BlobMidi(int id, MidiBus midibus,Note note) {
   this.id = id;
   this.channel = id;
   this.midibus = midibus;
   this.note = note;
   this.note.setChannel(id);
  }
  
  //setter
  public void setBlob(Blob blob) {this.blob = blob;this.x = 1-blob.y;this.y = 1-blob.x; this.h = blob.h;this.w = blob.w;}
  public void setActive(boolean active) {this.active = active;}
  

  public int pitchToMidi(float pitch, int oct) {return Math.round(pitch*11)+(12*oct);}
  public float map(float valueCoord1,float startCoord1, float endCoord1,float startCoord2, float endCoord2) {
    if (Math.abs(endCoord1 - startCoord1) < EPSILON) {throw new ArithmeticException("/ 0");}
    float offset = startCoord2;
    float ratio = (endCoord2 - startCoord2) / (endCoord1 - startCoord1);
    return ratio * (valueCoord1 - startCoord1) + offset;
  }
  
  public int mapToInt(float valueCoord1,float startCoord1, float endCoord1,float startCoord2, float endCoord2) {
    if (Math.abs(endCoord1 - startCoord1) < EPSILON) {throw new ArithmeticException("/ 0");}
    float offset = startCoord2;
    float ratio = (endCoord2 - startCoord2) / (endCoord1 - startCoord1);
    return Math.round(ratio * (valueCoord1 - startCoord1) + offset);
  }
  
  public void setMonophonic() {
    Note noteMonophonic = new Note(this.channel,126,0);
    this.midibus.sendNoteOn(noteMonophonic);
  }
  //midi handling
  public void update() {       
    if (this.active == true) {    
      if (this.record) {
      TableRow newRow = table.addRow();
        newRow.setFloat("id", this.id);
        newRow.setFloat("X", this.x);
        newRow.setFloat("Y", this.y);
        newRow.setFloat("H", this.h);
        newRow.setFloat("W", this.blob.w);
        newRow.setFloat("Area", this.blob.w * this.blob.h);
      }
      
      if (this.debouncePress) { //PUSH
          switch (this.mode) {
            case 0:
               this.midiNote = drumMatrix2x2[mapToInt(this.y,0,1,0,1)][mapToInt(this.x,0,1,0,1)];
               break;
            case 1:
              this.midiNote = (mapToInt(this.x,0,1,0,11)*11)+(12*mapToInt(this.y,0,1,3,5)); //final note is
              break;
            case 3:
              this.midiNote = (pentatonic[mapToInt(this.x,0,1,0,4)])+(12*mapToInt(this.y,0,1,4,5)); //final note is 
              break;
          }
          this.debouncePress = false;
          this.debounceRelease = true;    
          
          this.note.setVelocity(mapToInt(this.blob.h*this.blob.w,0,1,40,127));
          this.note.setPitch(this.midiNote);
          this.midibus.sendNoteOn(note);  
          
        } else {   //HOLD
        println(this.channel);
          switch (this.mode) {
            case 0:
              ControlChange change = new ControlChange(this.channel, 7, mapToInt(this.h,0,1,0,127));
              this.midibus.sendControllerChange(change); // Send a controllerChange  
              break;
            case 1:
              change = new ControlChange(this.channel, 7, mapToInt(this.h,0,1,0,127));
              this.midibus.sendControllerChange(change); // Send a controllerChange  
              break;
            case 3:
              this.midiNote = (pentatonic[mapToInt(this.x,0,1,0,4)])+(12*mapToInt(this.y,0,1,4,5));
              if (this.midiNote!=this.lastMidiNote) {
                //this.note.setVelocity(mapToInt(this.blob.h*this.blob.w,0,0.4,50,127));
                //this.note.setChannel(mapToInt(this.y,0,1,0,2));
                //this.midibus.sendNoteOn(note);
                //this.lastMidiNote = this.midiNote;
              } 
              
          }
        }
   } else if (this.active == false && this.debounceRelease) { //RELEASE
      this.debouncePress = true;
      this.debounceRelease = false;  
      //Note releaseNote = new Note(this.channel,this.changedNote,velocity);
      //this.midibus.sendNoteOff(releaseNote);
      ControlChange change = new ControlChange(this.channel, 123, 0); //CC123 = all notes off
      this.midibus.sendControllerChange(change); 
      
      if (this.record==true) {
        saveTable(table, recordingIndex+".csv");
        table.clearRows();
        recordingIndex++;
      }
   }
   
  }
  
  

  
  public void printCoor() {
    println("X: " + Float.toString(this.blob.x) + " ,Y: " + Float.toString(this.blob.y));
  }
  
}

  
void setup(){
  size(400,400);
  //Multi touch kit
  mtk = new MultiTouchKit(this,tx,rx,serialPort);      // instantiate the MultiTouchKit  
  mtk.autoDraw(true);                         // visualize the touch points, this will take full control of the window, you cant draw yourself anymore
  //mtk.drawBlobs(true);                        // set this to false to not draw the blobs, will be true by default
  //mtk.setDrawBlobCenters(true);               // set this to false to not draw the blob centers (touchpoints), will be true by default
  //mtk.setDrawBlobEdges(true);                 // set this to false to not draw the blob edges, will be true by default
  mtk.interpolationCubic(true);               // set this to false to use nearest neighbour interpolation ("blocky" output image), default will be Cubic interpolation, which is smooth
  mtk.setMaxInputRange(maxInputRange);        // set the brightness of touch points, decreasing this value will make everything "brigther", this is also the value that is beeing changed by the buttons
  mtk.setThresh(threshold);                   // set the threshold for blob detection
  mtk.enableUI(true);                         // enable the ui (buttons to change maxInputRange on the fly)
  //mtk.setRecordReplay(true);                  // from the moment this is set to true a replay will be recorded (mutually exclusive with playReplay()), until you terminate the sketch or set it to false
  //mtk.setReplayName("Recording_test");                // set the name of the recorded replay, the default name is "Replay", you can also use this to create several replays without restarting the sketch
  //mtk.playReplay(true,"Replay.csv");          // use this to play a replay, replace "Replay.csv" with whatever your replay is called
  mtk.setSizePerIntersection(gridSize);             
  
  
  //Midi
  MidiBus.list();
  
  midiBus = new MidiBus();
  midiBus.addOutput(4); //set MIDI VIRTUAL PORT
  
  //Note blob0_note = new Note();
  Note blob0Note = new Note(0,0,0);
  midiBlob0 = new BlobMidi(0,midiBus,blob0Note);
  midiBlob0.setMonophonic();
  
  Note blob1Note = new Note(1,0,0);
  midiBlob1 = new BlobMidi(1,midiBus,blob1Note);
  midiBlob1.setMonophonic();
  
  
  table = new Table();
  
  table.addColumn("id");
  table.addColumn("X");
  table.addColumn("Y");
  table.addColumn("W");
  table.addColumn("H");
  table.addColumn("Area");
  
}

void draw(){
 
  //boolean calibrationDone = mtk.calibrationDone();                     // if this is true, the calibration is done                                    
  
  //int[][] values = mtk.getAdjustedValues();                            // raw values recieved from serial port
  //int[][] rawvalues = mtk.getRawValues();                              // values used for visualization (max((raw values - baseline = adjusted values),0))
  //long[][] baseline = mtk.getBaseLine();                               // baseline values saved for calibartion
  
  BlobDetection bd = mtk.getBlobDetection();    
  
  Blob b0 = bd.getBlob(0);
  Blob b1 = bd.getBlob(1);
  
  if (b0 != null) { 
   // println(b0.getEdgeNb());
    midiBlob0.setBlob(b0);
    midiBlob0.setActive(true);
    midiBlob0.update();
    midiBlob0.printCoor();
  } else {
    midiBlob0.setActive(false);
    midiBlob0.update();
  }
  
  if (b1 != null) { 
    midiBlob1.setBlob(b1);
    midiBlob1.setActive(true);
    midiBlob1.update();
    midiBlob1.printCoor();
  } else {
    midiBlob1.setActive(false);
    midiBlob1.update();
  }
  
  //PImage sbc = mtk.getScaledbc();                                      // the output image that is displayed when autoDrawing is enabled
  
}

void mouseClicked() {
  saveTable(table, recordingIndex+".csv");
  table.clearRows();
  recordingIndex++;
}
