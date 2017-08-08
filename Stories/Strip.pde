final int nOfLED = 60;

class Strip {
  System system;
  int id;
  float angle;
  float xpos;
  float ypos;
  float length = 180;

  TimeLine dimTimer;
  Light[] lights;

  // state
  boolean independentControl = false;
  boolean repeatBreathing = false;
  boolean hovering = false;

  // temperary
  boolean dimming = false;
  float alpha = 0;
  float targetAlpha;
  float initialAlpha;
  int dimTime = 0;
  float padAlpha = 255;

  // blink function
  boolean blink = false;
  TimeLine turnOnTimer;

  // easing
  ArrayList<Elapse> elapses;
  boolean easing = false;
  boolean easingBlink = false;
  float easeRatio;
  float dimOnEaseRatio = 8;
  float dimOffEaseRatio = 0.2;

  // fade control
  boolean fadeControl = false;
  int fadeControlMode = 0; // 0 for middle, 1 for left, 2 for right
  float fadeControlValue = 0;

  // Audio
  AudioSample wetClip;
  AudioSample dryClip;


  Strip(System _s, int _id, float _a, float _x, float _y) {
    system = _s;
    id = _id;
    angle = _a;
    // xpos = width / 2 - length / 2;
    // ypos = height / 2;
    xpos = _x;
    ypos = _y;
    initLights();

    // Timers
    dimTimer = new TimeLine(300);
    turnOnTimer = new TimeLine(50);

    // Sound
    initSound();
  }

  void initSound() {
    dryClip = minim.loadSample(
      samples[0][id],
      512
    );
    wetClip = minim.loadSample(
      samples[1][id],
      512
    );

    dryClip.setGain(-5);
    wetClip.setGain(-5);

    if ( dryClip == null ) println("loading smaple error!");
    if ( wetClip == null ) println("loading smaple error!");
  }

  void initLights() {
    elapses = new ArrayList<Elapse>();
    lights = new Light[nOfLED];
    for (int i = 0; i < nOfLED; i++) {
      lights[i] = new Light(xpos, ypos + length * i / nOfLED);
    }
  }

  void update() {
    if (independentControl) {
      lightsUpdate();
    } else {
      if (dimming) {
        float ratio = 0;
        if (repeatBreathing) {
          ratio = dimTimer.repeatBreathMovement();
        } else if (easing) {
          ratio = dimTimer.getPowIn(easeRatio);
        } else {
          ratio = dimTimer.liner();
        }

        alpha = initialAlpha +
          (targetAlpha - initialAlpha) * ratio;

        if (!dimTimer.state) {
          // alpha = targetAlpha;
          easing = false;
          dimming = false;
          repeatBreathing = false;
        }
      // } else if (blink) {
      }
      if (blink) {
        // println("blink check!!");
        if (turnOnTimer.liner() == 1) {
          if (easingBlink) {
            turnOffEasing(dimTime / 2);
            easingBlink = false;
          } else {
            turnOff(dimTime);
          }
          blink = false;
        }
      }
    }
  }

  void mouseSensed() {
    if (dist(mouseX, mouseY, xpos, ypos) < 30) {
      hovering = true;
    } else {
      hovering = false;
    }
  }

  void lightsUpdate() {
    // if (elapsing) {
    //   elapseCount++;
    //   if (elapseCount > elapseCountLimit) {
    //     elapseCount = 0;
    //     lights[elapseIndex].turnOnFor(5, elapseEdge);
    //     int dif = (elapseDirection) ? 1 : (-1);
    //     elapseIndex = (elapseIndex + dif) % nOfLED;
    //     if (elapseIndex == elapseEndIndex) {
    //       elapsing = false;
    //     }
    //   }
    // }
    // elapse.update();

    for (int i = 0, n = elapses.size(); i < n; i++) {
      elapses.get(i).update();
    }

    for (int i = 0; i < nOfLED; i++) {
      lights[i].update();
    }
  }

  void render() {
    if (independentControl) {
      for (int i = 0; i < nOfLED; i++) {
        lights[i].render();
      }
    } else {
      canvas.pushMatrix();

      canvas.translate(xpos, ypos);

      canvas.noStroke();
      canvas.fill(100);
      canvas.ellipse(0, length, 30, 15);

      for (int i = 0; i < nOfLED; i++) {
        float y = length * i / nOfLED;
        canvas.noStroke();
        canvas.fill(255, alpha * master);
        canvas.ellipse(0, y, 20, 10);
      }

      canvas.stroke(100);
      canvas.line(12, 4, 12, length);
      canvas.line(-12, 4, -12, length);

      padAlpha = padAlpha + ((hovering ? 200 : 50) - padAlpha) * 0.2;
      canvas.noStroke();
      canvas.fill(padAlpha);
      canvas.ellipse(0, 0, 30, 15);

      canvas.popMatrix();
    }
  }

  void turnOn() {
    repeatBreathing = false;
    independentControl = false;
    dimming = false;
    alpha = 255;
    initialAlpha = 255;
    targetAlpha = 255;
  }

  void turnOn(int time) {
    repeatBreathing = false;
    independentControl = false;
    dimming = true;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 255;
  }

  void turnOnEasing(int time) {
    turnOn(time);
    easeRatio = dimOnEaseRatio;
    easing = true;
  }

  void turnOnEasing(int time, int ratio) {
    dimOnEaseRatio = ratio;
    turnOnEasing(time);
  }

  void turnOff() {
    repeatBreathing = false;
    independentControl = false;
    dimming = false;
    alpha = 0;
    initialAlpha = 0;
    targetAlpha = 0;
  }

  void turnOff(int time) {
    repeatBreathing = false;
    independentControl = false;
    dimming = true;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 0;
  }

  void turnOffEasing(int time) {
    turnOff(time);
    easeRatio = dimOffEaseRatio;
    easing = true;
  }

  void turnOffEasing(int time, int ratio) {
    dimOffEaseRatio = ratio;
    turnOffEasing(time);
  }

  void turnOnFor(int time) {
    repeatBreathing = false;
    blink = true;
    dimTime = 0;
    turnOn();
    turnOnTimer.limit = time;
    turnOnTimer.startTimer();
  }

  void turnOnFor(int time, int ll) {
    repeatBreathing = false;
    blink = true;
    dimTime = ll;
    turnOn(dimTime);
    turnOnTimer.limit = time;
    turnOnTimer.startTimer();
  }

  // only one param here,
  // because the length of dimming and opening
  // must match at usual cases
  void turnOnEasingFor(int time) {
    repeatBreathing = false;
    blink = true;
    easingBlink = true;
    dimTime = time;
    turnOnEasing(time);
    turnOnTimer.limit = time;
    turnOnTimer.startTimer();
  }

  void blink() {
    turnOnFor(20);
  }

  void setLimit(int ll) {
    dimTimer.limit = ll;
  }

  void triggerIndependentControl() {
    independentControl = !independentControl;
  }

  void setIndependentControl(boolean s) {
    independentControl = s;
  }

  void bangElapse(int st, int en, boolean dir) {
    for (int i = 0, n = elapses.size(); i < n; i++) {
      Elapse e = elapses.get(i);
      if (!e.elapsing) {
        e.bang(st, en, dir);
        return;
      }
    }
    Elapse e = new Elapse(this);
    elapses.add(e);
    e.bang(st, en, dir);
  }

  void setElapseCountLimit(int ll) {
    for (int i = 0, n = elapses.size(); i < n; i++) {
      elapses.get(i).elapseCountLimit = ll;
    }
  }

  // dim 3 times
  void dimRepeat(int time, int ll) {
    alpha = 0;
    independentControl = false;
    repeatBreathing = true;
    dimming = true;
    initialAlpha = 0;
    targetAlpha = 255;
    dimTimer.limit = ll;
    dimTimer.repeatTime = time;
    dimTimer.breathState = false;
    dimTimer.startTimer();
  }

  void dimRepeatInverse(int time, int ll) {
    alpha = 255;
    independentControl = false;
    repeatBreathing = true;
    dimming = true;
    initialAlpha = 255;
    targetAlpha = 0;
    dimTimer.limit = ll;
    dimTimer.repeatTime = time;
    dimTimer.breathState = false;
    dimTimer.startTimer();
  }

  void triggerFadeControl() {
    fadeControl = !fadeControl;
  }

  void setFadeControlMode(int m) {
    fadeControlMode = m;
  }

  void setFadeControlValue(float value) {
    if (independentControl && fadeControl) {


      if (fadeControlMode == 0)  { // middle
        int number = int( (nOfLED / 2) * value );
        if (value > fadeControlValue) {
          // left
          for (int i = nOfLED / 2, n =  nOfLED / 2 - number; i > n; i--) {
            if (lights[i].alpha < 5) {
              lights[i].turnOn();
            }
          }

          // right
          for (int i = nOfLED / 2, n =  nOfLED / 2 + number; i < n; i++) {
            if (lights[i].alpha < 5) {
              lights[i].turnOn();
            }
          }
        } else {
          // left
          for (int i = 0, n =  nOfLED / 2 - number; i <= n; i++) {
            if (lights[i].alpha > 5) {
              lights[i].turnOff();
            }
          }

          // right
          for (int i = nOfLED - 1, n =  nOfLED / 2 + number; i > n; i--) {
            if (lights[i].alpha > 5) {
              lights[i].turnOff();
            }
          }
        }
      } else if (fadeControlMode == 1) { // left
        int number = int( nOfLED  * value );
        if (value > fadeControlValue) {
          for (int i = nOfLED - 1, n =  nOfLED - 1 - number; i > n; i--) {
            if (lights[i].alpha < 5) {
              lights[i].turnOn();
            }
          }
        } else {
          for (int i = 0, n = nOfLED - 1 - number; i <= n; i++) {
            if (lights[i].alpha > 5) {
              lights[i].turnOff();
            }
          }
        }
      } else if (fadeControlMode == 2) { // right
        int number = int( nOfLED  * value );
        if (value > fadeControlValue) {
          for (int i = 0, n = number; i < n; i++) {
            if (lights[i].alpha < 5) {
              lights[i].turnOn();
            }
          }
        } else {
          for (int i = nOfLED - 1, n = number; i >= n; i--) {
            if (lights[i].alpha > 5) {
              lights[i].turnOff();
            }
          }
        }
      }

    }
    fadeControlValue = constrain(value, 0, 1);
  }

  // Sound
  void triggerDryClip() {
    dryClip.setGain(-2);
    dryClip.trigger();
  }
  void triggerDryClip(float gain) {
    dryClip.setGain(gain);
    dryClip.trigger();
  }
  void triggerWetClip() {
    wetClip.setGain(-2);
    wetClip.trigger();
  }
  void triggerWetClip(float gain) {
    wetClip.setGain(gain);
    wetClip.trigger();
  }

  boolean playingDelayWetClip = false;
  int wetClipDelay = 30;
  int wetClipDelayCount = 0;
  void soundUpdate() {
    if (playingDelayWetClip) {
      wetClipDelayCount++;
      if (wetClipDelayCount > wetClipDelay) {
        triggerWetClip(-10);
        wetClipDelayCount = 0;
        playingDelayWetClip = false;
      }
    }
  }
  void triggerWetClipDelay() {
    playingDelayWetClip = true;
  }
  void triggerWetClipDelay(int delay) {
    wetClipDelay = delay;
    playingDelayWetClip = true;
  }

  void mousePressed() {
    if (hovering) {
      // println("id : " + id);
      // triggerDryClip();
      // turnOnFor(300, 100);
      // boolean[] ls = map[id];
      // for (int i = 0; i < ls.length; i++) {
      //   if (ls[i]) {
      //     system.strips[i].turnOnEasingFor(300);
      //     system.strips[i].triggerWetClip();
      //   }
      // }
    }
  }
}

class Elapse {
  Strip strip;

  boolean elapsing = false;
  int elapseStartIndex;
  int elapseEndIndex;
  boolean elapseDirection = true; // true for right, false for left
  int elapseIndex = 0;
  int elapseEdge = 500;
  int elapseCount = 0;
  int elapseCountLimit = 0;

  Elapse(Strip _s) { strip = _s; }

  void bang(int st, int en, boolean dir) {
    elapsing = true;
    elapseStartIndex = constrain(st, 0, nOfLED - 1);
    elapseEndIndex = constrain(en, 0, nOfLED - 1);
    elapseDirection = dir;
    elapseIndex = constrain(st, 0, nOfLED - 1);
    elapseCount = 0;
  }

  void update() {
    if (elapsing) {
      elapseCount++;
      if (elapseCount > elapseCountLimit) {
        elapseCount = 0;
        int dif = (elapseDirection) ? 1 : (-1);
        strip.lights[elapseIndex].turnOnFor(5, elapseEdge);
        elapseIndex = (elapseIndex + dif) % nOfLED;
        if (elapseIndex == elapseEndIndex) {
          elapsing = false;
          return;
        }
        strip.lights[elapseIndex].turnOnFor(5, elapseEdge);
        elapseIndex = (elapseIndex + dif) % nOfLED;
        if (elapseIndex == elapseEndIndex) {
          elapsing = false;
          return;
        }
      }
    }
  }
}

class Light {
  // temperary
  float xpos;
  float ypos;

  float alpha = 0;
  float targetAlpha = 0;
  float initialAlpha = 0;
  boolean dimming = false;

  int dimTime;
  TimeLine dimTimer;

  boolean autoOff = false;
  TimeLine turnOnTimer;

  Light(float _x, float _y) {
    xpos = _x;
    ypos = _y;
    dimTimer = new TimeLine(300);
    turnOnTimer = new TimeLine(50);
  }

  void update() {
    if (dimming) {
      alpha = initialAlpha +
        (targetAlpha - initialAlpha) * dimTimer.liner();
      if (abs(alpha - targetAlpha) < 1) {
        alpha = targetAlpha;
        dimming = false;
      }
    }
    if (autoOff) {
      if (!turnOnTimer.state) {
        if (dimTimer.liner() == 1) {
          turnOnTimer.startTimer();
        }
      } else if (turnOnTimer.liner() == 1) {
        autoOff = false;
        turnOff(dimTime);
        autoOff = false;
      }
    }
  }

  void render() {
    canvas.pushMatrix();

    canvas.translate(xpos, ypos);
    canvas.noStroke();
    canvas.fill(255, alpha * master);
    canvas.ellipse(0, 0, 5, 5);

    canvas.popMatrix();
  }

  void turnOn() {
    dimming = false;
    alpha = 255;
    initialAlpha = 255;
    targetAlpha = 255;
  }

  void turnOn(int time) {
    dimming = true;
    dimTime = time;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 255;
  }

  void turnOff() {
    dimming = false;
    alpha = 0;
    initialAlpha = 0;
    targetAlpha = 0;
  }

  void turnOff(int time) {
    dimming = true;
    dimTime = time;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 0;
  }

  void turnOnFor(int time, int ll) {
    autoOff = true;
    turnOnTimer.limit = time;
    dimTime = ll;
    turnOn(ll);
  }

  void setLimit(int ll) {
    dimTime = ll;
    dimTimer.limit = ll;
  }
}
