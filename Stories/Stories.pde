import codeanticode.syphon.*;
import controlP5.*;
import themidibus.*;
import processing.serial.*;


// controlP5
ControlP5 cp5;
Accordion accordion;

// Syphon
SyphonServer server;
PGraphics canvas;

System system;

color c = color(0, 160, 100);
float master = 1;


void settings() {
  size(1400, 580, P3D);
  PJOGL.profile=1;
}

void setup() {
  background(0);
  canvas = createGraphics(width, height, P3D);
  system = new System();

  // controlP5
  gui();

  // Syphon
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  background(0);
  system.render();
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
