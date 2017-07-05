import codeanticode.syphon.*;
import controlP5.*;
import processing.opengl.*;
import peasy.*;

// controlP5
ControlP5 cp5;
Accordion accordion;
ControlFrame cf;

// Syphon
SyphonServer server;
PGraphics canvas;

// Peasy
PeasyCam cam;

System system;



color c = color(0, 160, 200);
float master = 1;

void settings() {
  size(700, 500, P3D);
  PJOGL.profile=1;
}

void setup() {
  cf = new ControlFrame(this, 400, 400, "Controls");
  surface.setLocation(420, 10);
  background(0);
  canvas = createGraphics(width, height, P3D);
  system = new System();
  cam = new PeasyCam(this, canvas, 100);

  // Syphon
  server = new SyphonServer(this, "Processing Syphon");
}


void draw() {
  background(0);
  canvas.sphere(20);
  system.render();
}

void keyPressed() {
  if (key == '1') {
    system.dimRepeat(1, 20);
  }
  if (key == '2') {
    system.turnOnEasingFor(800);
  }
  if (key == '3') {
    system.dimRepeat(3, 50);
  }
  if (key == '4') {
    system.turnRandMultipleOnFor(20, 20);
  }
  if (key == '5') {
    system.bangComplexSequence(0);
  }
  if (key == '6') {
    system.bangElapseCol(3, true);
  }
  if (key == '7') {
    system.bangBounceRow(1, true);
  }


  // Independent control
  if (key == 'x') {
    system.triggerIndependentControl();
  }
  // if (key == 'v') {
  //   system.triggerFadeControl();
  // }
}


class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setLocation(10, 10);
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

    cp5.addSlider("elapse")
       .setPosition(10,50)
       .setSize(100,20)
       .setRange(0,127)
       .setValue(0)
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
  }

  void draw() {
    background(0);

    if (system.getIndependentMode()) {
      fill(255,155,155);
    } else {
      fill(137,201,151);
    }
    rect(40, 10, 20, 20);
    if (system.getFadeControlMode()) {
      fill(255,155,155);
    } else {
      fill(137,201,151);
    }
    rect(70, 10, 20, 20);
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
      } else if (theEvent.controller().getName() == "elapse") {
        float value = theEvent.controller().getValue() / 180.0;
        // TODO
        system.setFadeControlValue(value);
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
}
