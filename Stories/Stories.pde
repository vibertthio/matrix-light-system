import codeanticode.syphon.*;
import controlP5.*;
import themidibus.*;
import processing.serial.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;


// controlP5
ControlP5 cp5;
Accordion accordion;

// Syphon
SyphonServer server;
PGraphics canvas;

// Sound
Minim minim;
String[][] samples = {
  {
    "dry/1-1.wav",
    "dry/1-2.wav",
    "dry/1-3.wav",
    "dry/1-4.wav",
    "dry/2-1.wav",
    "dry/2-2.wav",
    "dry/2-3.wav",
    "dry/2-4.wav",
    "dry/3-1.wav",
    "dry/3-2.wav",
    "dry/3-3.wav",
    "dry/3-4.wav",
    "dry/4-1.wav",
    "dry/4-2.wav",
    "dry/4-3.wav",
    "dry/4-4.wav",
  },
  {
    "wet/1-1.wav",
    "wet/1-2.wav",
    "wet/1-3.wav",
    "wet/1-4.wav",
    "wet/2-1.wav",
    "wet/2-2.wav",
    "wet/2-3.wav",
    "wet/2-4.wav",
    "wet/3-1.wav",
    "wet/3-2.wav",
    "wet/3-3.wav",
    "wet/3-4.wav",
    "wet/4-1.wav",
    "wet/4-2.wav",
    "wet/4-3.wav",
    "wet/4-4.wav",
  },
};

final int MAX_INT = 2147483647;
final boolean T = true;
final boolean F = false;
boolean[][] map = {
  //0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
  { F, T, F, F, F, T, T, F, F, F, F, F, F, F, F, F}, // 0
  { T, F, T, F, F, F, T, T, F, F, F, F, F, F, F, F}, // 1
  { F, T, F, T, F, F, F, T, T, F, F, F, F, F, F, F}, // 2
  { F, F, T, F, T, F, F, F, T, T, F, F, F, F, F, F}, // 3
  { F, F, F, T, F, F, F, F, F, T, T, F, F, F, F, F}, // 4
  { T, F, F, F, F, F, T, F, F, F, F, T, F, F, F, F}, // 5
  { T, T, F, F, F, T, F, T, F, F, F, T, T, F, F, F}, // 6
  { F, T, T, F, F, F, T, F, T, F, F, F, T, T, F, F}, // 7
  { F, F, T, T, F, F, F, T, F, T, F, F, F, T, T, F}, // 8
  { F, F, F, T, T, F, F, F, T, F, T, F, F, F, T, T}, // 9
  { F, F, F, F, T, F, F, F, F, T, F, F, F, F, F, T}, // 10
  { F, F, F, F, F, T, T, F, F, F, F, F, T, F, F, F}, // 11
  { F, F, F, F, F, F, T, T, F, F, F, T, F, T, F, F}, // 12
  { F, F, F, F, F, F, F, T, T, F, F, F, T, F, T, F}, // 13
  { F, F, F, F, F, F, F, F, T, T, F, F, F, T, F, T}, // 14
  { F, F, F, F, F, F, F, F, F, T, T, F, F, F, T, F}, // 15
};



System system;

color c = color(0, 160, 100);
float master = 1;


void settings() {
  size(1400, 580, P3D);
  PJOGL.profile=1;

  // Sound
  minim = new Minim(this);
}

void setup() {
  background(0);
  canvas = createGraphics(width, height, P3D);
  system = new System();

  // ControlP5
  gui();

  // Syphon
  server = new SyphonServer(this, "Processing Syphon");

  Mixer mixer = AudioSystem.getMixer(AudioSystem.getMixerInfo()[9]);
  println(AudioSystem.getMixerInfo()[8].getName());
  minim.setOutputMixer(mixer);
}

void draw() {
  background(0);
  system.render();
}

void mousePressed() {
  noStroke();
  fill(255, 0, 0);
  ellipse(mouseX, mouseY, 30, 30);
  system.mousePressed();
}

void keyPressed() {
  if (key == ' ') {
    screenshot();
  }
}

void gui() {

  cp5 = new ControlP5(this);

  // group number 1
  Group g1 = cp5.addGroup("bang test")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(100)
                ;

  cp5.addBang("dim_on")
     .setPosition(10,20)
     .setSize(30,30)
     .moveTo(g1)
     .setId(0)
     ;
  cp5.addBang("dim_off")
     .setPosition(60,20)
     .setSize(30,30)
     .moveTo(g1)
     .setId(1)
     ;

  // group number 2
  Group g2 = cp5.addGroup("Slider Control")
                .setBackgroundColor(color(64, 0))
                .setBackgroundHeight(150)
                ;

  cp5.addSlider("master")
     .setPosition(10,20)
     .setSize(100,20)
     .setRange(0,127)
     .setValue(100)
     .moveTo(g2)
     ;

  // create a new accordion
  // add g1, g2 to the accordion.
  accordion = cp5.addAccordion("acc")
                 .setPosition(40,40)
                 .setWidth(200)
                 .addItem(g1)
                 .addItem(g2)
                 ;

  accordion.open(0);
  accordion.open(1);

  // use Accordion.MULTI to allow multiple group
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);

  // when in SINGLE mode, only 1 accordion
  // group can be open at a time.
  // accordion.setCollapseMode(Accordion.SINGLE);
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    // println(
    // "## controlEvent / id:"+theEvent.controller().getId()+
    //   " / name:"+theEvent.controller().getName()+
    //   " / value:"+theEvent.controller().getValue()
    //   );

    // test for fader
    if (theEvent.controller().getName() == "master") {
      float value = theEvent.controller().getValue() / 127.0;
      master = value;
    }

    //g1 bang effects
    switch(theEvent.controller().getId()) {
      case(0):
        system.turnOn(300);
        break;
      case(1):
        system.turnOff(300);
        break;
    }
  }
}
