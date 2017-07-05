class System {
  Strip[] strips;
  int nOfStrips = 16;
  int nOfCol = 4;

  System() {
    strips = new Strip[nOfStrips];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        strips[i * 4 + j] = new Strip(i, 0, -75, 100 * (i - 1.5), 100 * (j - 1.5));
      }
    }

    initElapseStateControls();
  }

  public void render() {
    canvas.beginDraw();
    canvas.background(0);

    updateSequence();
    updateComplexSequence();
    updateAsyncSequence();
    updateComplexAsyncSequence();
    updateElapseStateControls();
    updateComplexAsyncElapse();

    for (int i = 0; i < nOfStrips; i++) {
      strips[i].update();
      strips[i].render();
    }

    image(canvas, 0, 0);
    canvas.endDraw();
    server.sendImage(canvas);
  }

  void turnOn() {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOn();
    }
  }
  void turnOn(int time) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOn(time);
    }
  }
  void turnOnEasing(int time) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOnEasing(time);
    }
  }
  void turnOnFor(int time, int ll) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOnFor(time, ll);
    }
  }
  void turnOnEasingFor(int time) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOnEasingFor(time);
    }
  }
  void turnOnEasingForCol(int time, int col) {
    int nInCol = nOfStrips / nOfCol;
    for (int i = col * nInCol, n = (col + 1) * nInCol; i < n; i += 1) {
      strips[i].turnOnEasingFor(time);
    }
  }
  void turnOneOn(int id) {
    strips[id].turnOn();
  }
  void turnOneOn(int id, int time) {
    strips[id].turnOn(time);
  }
  void turnOneOnFor(int id, int time, int ll) {
    strips[id].turnOnFor(time, ll);
  }
  void turnRandOneOnFor(int time, int ll) {
    turnOneOnFor(int(random(nOfStrips)),time, ll);
  }
  void turnRandMultipleOnFor(int time, int ll) {
    final int NUM = int(random(nOfStrips));
    final IntList nums = new IntList(NUM);

    for (int rnd, i = 0; i != NUM; nums.append(rnd), ++i)
    do {
      rnd = (int) random(nOfStrips);
    } while (nums.hasValue(rnd));

    for (int i = 0; i < NUM; i++) {
      turnOneOnFor(nums.get(i), time, ll);
    }
  }
  void turnMultipleOnFor(int time, int ll, int number) {
    final int NUM = number;
    final IntList nums = new IntList(NUM);

    for (int rnd, i = 0; i != NUM; nums.append(rnd), ++i)
    do {
      rnd = (int) random(nOfStrips);
    } while (nums.hasValue(rnd));

    for (int i = 0; i < NUM; i++) {
      turnOneOnFor(nums.get(i), time, ll);
    }
  }
  void turnOff() {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOff();
    }
  }
  void turnOff(int time) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOff(time);
    }
  }
  void turnOffEasing(int time) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].turnOffEasing(time);
    }
  }
  void turnOneOff(int id) {
    strips[id].turnOff();
  }
  void turnOneOff(int id, int time) {
    strips[id].turnOff(time);
  }
  void dimRepeat(int time, int ll) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].dimRepeat(time, ll);
    }
  }
  void dimRepeatCol(int time, int ll, int col) {
    int nInCol = nOfStrips / nOfCol;
    for (int i = col * nInCol, n = (col + 1) * nInCol; i < n; i += 1) {
      strips[i].dimRepeat(time, ll);
    }
  }
  void blink() {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].blink();
    }
  }

  boolean turnSequenceActivate = false;
  int sequenceTriggerIndex = 0;
  boolean bangSequence = false;
  int turnSequenceTime = 100;
  int turnSequenceIndex = 0;
  int turnSequenceCount = 0;
  int turnSequenceCountLimit = 5;
  int[][] sequenceSet = {
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}, // 0
    { 3, 4, 11 },
    { 0, 3, 4, 7, 8, 11 },
    { 0, 4, 8, 1, 5, 9, 2, 6, 10, 3, 7, 11 },
    { 0, 11, 4, 8 },
    { 9, 2, 1, 10 }, // 5
    { 0, 4, 8, 1, 5, 9 },
    { 10, 6, 2, 11, 7, 3 },
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 },
    { 8, 9, 10, 11, 4, 5, 6, 7, 0, 1, 2, 3 },
    { 0, 1, 2, 3}, // 10
    { 3, 2, 1, 0},
    { 0, 3, 2, 1},
    { 0, 2, 1, 3},
    { 4, 5, 6, 7},
    { 7, 6, 5, 4}, // 15
    { 4, 7, 5, 6},
    { 7, 5, 6, 4},
    { 8, 9, 10, 11},
    { 11, 10, 9, 8},
    { 8, 11, 10, 9}, // 20
    { 8, 10, 9, 11},
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
    { 11, 10, 9, 8, 3, 2, 1, 0 },
    { 0, 1, 2, 3, 8, 9, 10, 11 },
    { 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ,0}, // 25
    { 0, 7, 8, 3, 4, 11},
    { 11, 4, 3, 8, 7, 0},
    { 0, 1, 2, 3, 7, 6, 5, 4, 8, 9, 10, 11,
      10, 9, 8, 4, 5, 6, 7, 3, 2, 1, 0 },
    { 3, 2, 1, 0, 4, 5, 6, 7, 11, 10, 9, 8,
      9, 10, 11, 7, 6, 5, 4, 0, 1, 2, 3 },
    { 0, 0, 0, 0}, // 30 // this one if for random sequence, don't modify it
  };
  int[] sequence;

  void triggerSequence() {
    triggerSequence(sequenceTriggerIndex);
    // turnSequenceActivate = !turnSequenceActivate;
    // turnSequenceCount = 0;
  }
  void triggerSequence(int index) {
    turnOff();
    // turnSequenceActivate = true;
    if (index == sequenceTriggerIndex) {
      turnSequenceActivate = !turnSequenceActivate;
    } else {
      turnSequenceActivate = true;
    }

    sequenceTriggerIndex = index;
    sequence = sequenceSet[index%sequenceSet.length];
    turnSequenceIndex = 0;
    turnSequenceCount = 0;
  }
  void triggerSequence(int index, int time) {
    triggerSequence(index);
    turnSequenceTime = time;
  }
  void bangSequence(int index) {
    triggerSequence(index);
    bangSequence = true;
  }
  void bangSequence(int index, int time) {
    triggerSequence(index, time);
    bangSequence = true;
  }
  void updateSequence() {
    if (turnSequenceActivate) {
      turnSequenceCount++;
      if (turnSequenceCount > turnSequenceCountLimit) {
        // int prev = (turnSequenceIndex > 0)? (turnSequenceIndex - 1) : (sequence.length - 1);
        // turnOneOn(sequence[turnSequenceIndex], turnSequenceTime);
        // turnOneOff(sequence[prev], turnSequenceTime);
        turnOneOnFor(sequence[turnSequenceIndex], turnSequenceTime, 20);
        turnSequenceIndex = (turnSequenceIndex + 1) % sequence.length;
        turnSequenceCount = 0;

        if (bangSequence && turnSequenceIndex == 0) {
          triggerSequence();
          bangSequence = false;
        }
      }
    }
  }

  // complex sequence (一次會執行不只一條燈)
  boolean complexSequenceActivate = false;
  int complexSequenceTriggerIndex = 0;
  boolean bangComplexSequence = false;
  int complexSequenceTime = 20;
  int complexSequenceDur = 50;
  int complexSequenceIndex = 0;
  int complexSequenceCount = 0;
  int complexSequenceCountLimit = 5;
  int[][][] complexSequenceSet = {
    {
      {0, 1, 2, 3},
      {4, 5, 6, 7},
      {8, 9, 10, 11},
      {12, 13, 14, 15},
    },
    {
      {12, 13, 14, 15},
      {8, 9, 10, 11},
      {4, 5, 6, 7},
      {0, 1, 2, 3},
    },
    {
      {0, 4, 8, 12},
      {1, 5, 9, 13},
      {2, 6, 10, 14},
      {3, 7, 11, 15},
    },
    {
      {3, 7, 11, 15},
      {2, 6, 10, 14},
      {1, 5, 9, 13},
      {0, 4, 8, 12},
    },
  };
  int[][] complexSequence;
  void triggerComplexSequence() {
    triggerComplexSequence(complexSequenceTriggerIndex);
    // complexSequenceActivate = !complexSequenceActivate;
    // complexSequenceCount = 0;
  }
  void triggerComplexSequence(int index) {
    if (index == complexSequenceTriggerIndex) {
      complexSequenceActivate = !complexSequenceActivate;
    } else {
      complexSequenceActivate = true;
    }

    complexSequenceTriggerIndex = index;
    complexSequence = complexSequenceSet[index%complexSequenceSet.length];
    complexSequenceIndex = 0;
    complexSequenceCount = 0;
  }
  void bangComplexSequence(int index) {
    triggerComplexSequence(index);
    bangComplexSequence = true;
  }
  void updateComplexSequence() {
    if (complexSequenceActivate) {
      complexSequenceCount++;
      if (complexSequenceCount > complexSequenceCountLimit) {
        for (int i = 0, n = complexSequence[complexSequenceIndex].length; i < n; i++) {
          turnOneOnFor(complexSequence[complexSequenceIndex][i], complexSequenceDur, complexSequenceTime);
        }
        complexSequenceIndex = (complexSequenceIndex + 1) % complexSequence.length;
        complexSequenceCount = 0;

        if (bangComplexSequence && complexSequenceIndex == 0) {
          triggerComplexSequence();
          bangComplexSequence = false;
        }
      }
    }
  }



  // asynce sequence （同個數字要被cue到兩次才會開關。 一次亮暗一條）
  boolean asyncSequenceActivate = false;
  int asyncSequenceTriggerIndex = 0;
  boolean bangAsyncSequence = false;
  int asyncSequenceTime = 50;
  int asyncSequenceIndex = 0;
  int asyncSequenceCount = 0;
  int asyncSequenceCountLimit = 2;
  int[][] asyncSequenceSet = {
    { 0, 1, 2, 3, 3, 2, 1, 0 },     //0
    { 4, 5, 6, 7, 7, 6, 5, 4 },
    { 8, 9, 10, 11, 11, 10, 9, 8 },

    { 3, 2, 1, 0, 0, 1, 2, 3 },
    { 7, 6, 5, 4, 4, 5, 6, 7 },
    { 11, 10, 9, 8, 8, 9, 10, 11 },  //5

    { 0, 1, 2, 3, 7, 6, 5, 4, 8, 9, 10, 11,
      11, 10, 9, 8, 4, 5, 6, 7, 3, 2, 1, 0 },  //6
    { 3, 2, 1, 0, 4, 5, 6, 7, 11, 10, 9, 8,
      8, 9, 10, 11, 7, 6, 5, 4, 0, 1, 2, 3 },  //7
  };
  boolean[] asyncRecord = {
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
  };
  int[] asyncSequence;

  void triggerAsyncSequence() {
    triggerAsyncSequence(asyncSequenceTriggerIndex);
    // asyncSequenceActivate = !asyncSequenceActivate;
    // asyncSequenceCount = 0;
  }
  void triggerAsyncSequence(int index) {
    for (int i = 0, n = nOfStrips; i < n; i++) {
      asyncRecord[i] = false;
    }
    turnOff();
    if (index == asyncSequenceTriggerIndex) {
      asyncSequenceActivate = !asyncSequenceActivate;
    } else {
      asyncSequenceActivate = true;
    }

    asyncSequenceTriggerIndex = index;
    asyncSequence = asyncSequenceSet[index%asyncSequenceSet.length];
    asyncSequenceIndex = 0;
    asyncSequenceCount = 0;
  }
  void bangAsyncSequence(int index) {
    triggerAsyncSequence(index);
    bangAsyncSequence = true;
  }
  void updateAsyncSequence() {
    if (asyncSequenceActivate) {
      asyncSequenceCount++;
      if (asyncSequenceCount > asyncSequenceCountLimit) {

        if (asyncRecord[asyncSequence[asyncSequenceIndex]]) {
          turnOneOff(asyncSequence[asyncSequenceIndex], asyncSequenceTime);
        } else {
          turnOneOn(asyncSequence[asyncSequenceIndex], asyncSequenceTime);
        }
        asyncRecord[asyncSequence[asyncSequenceIndex]] = !asyncRecord[asyncSequence[asyncSequenceIndex]];
        asyncSequenceIndex = (asyncSequenceIndex + 1) % asyncSequence.length;
        asyncSequenceCount = 0;

        if (bangAsyncSequence && asyncSequenceIndex == 0) {
          triggerAsyncSequence();
          bangAsyncSequence = false;
        }
      }
    }
  }

  // complex async sequence （一次亮暗好幾條）
  boolean complexAsyncSequenceActivate = false;
  int complexAsyncSequenceTriggerIndex = 0;
  boolean bangComplexAsyncSequence = false;
  int complexAsyncSequenceTime = 50;
  int complexAsyncSequenceIndex = 0;
  int complexAsyncSequenceCount = 0;
  int complexAsyncSequenceCountLimit = 3;
  int[][][] complexAsyncSequenceSet = {
    {
      { 0, 4, 8 },
      { 1, 5, 9 },
      { 2, 6, 10 },
      { 3, 7, 11 },
      { 3, 7, 11 },
      { 2, 6, 10 },
      { 1, 5, 9 },
      { 0, 4, 8 },
    },
    {
      { 3, 7, 11 },
      { 2, 6, 10 },
      { 1, 5, 9 },
      { 0, 4, 8 },
      { 0, 4, 8 },
      { 1, 5, 9 },
      { 2, 6, 10 },
      { 3, 7, 11 },
    },
  };
  boolean[] complexAsyncRecord = {
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
  };
  int[][] complexAsyncSequence;

  void triggerComplexAsyncSequence() {
    triggerComplexAsyncSequence(complexAsyncSequenceTriggerIndex);
    // complexAsyncSequenceActivate = !complexAsyncSequenceActivate;
    // complexAsyncSequenceCount = 0;
  }
  void triggerComplexAsyncSequence(int index) {
    for (int i = 0, n = nOfStrips; i < n; i++) {
      complexAsyncRecord[i] = false;
    }
    turnOff();
    if (index == complexAsyncSequenceTriggerIndex) {
      complexAsyncSequenceActivate = !complexAsyncSequenceActivate;
    } else {
      complexAsyncSequenceActivate = true;
    }

    complexAsyncSequenceTriggerIndex = index;
    complexAsyncSequence = complexAsyncSequenceSet[index%complexAsyncSequenceSet.length];
    complexAsyncSequenceIndex = 0;
    complexAsyncSequenceCount = 0;
  }
  void bangComplexAsyncSequence(int index) {
    triggerComplexAsyncSequence(index);
    bangComplexAsyncSequence = true;
  }
  void updateComplexAsyncSequence() {
    if (complexAsyncSequenceActivate) {
      complexAsyncSequenceCount++;
      if (complexAsyncSequenceCount > complexAsyncSequenceCountLimit) {

        int[] cas = complexAsyncSequence[complexAsyncSequenceIndex];
        for (int i = 0, n = cas.length; i < n; i++) {
          if (complexAsyncRecord[cas[i]]) {
            turnOneOff(cas[i], complexAsyncSequenceTime);
          } else {
            turnOneOn(cas[i], complexAsyncSequenceTime);
          }
          complexAsyncRecord[cas[i]] = !complexAsyncRecord[cas[i]];
        }
        complexAsyncSequenceIndex = (complexAsyncSequenceIndex + 1) % complexAsyncSequence.length;
        complexAsyncSequenceCount = 0;

        if (bangComplexAsyncSequence && complexAsyncSequenceIndex == 0) {
          triggerComplexAsyncSequence();
          bangComplexAsyncSequence = false;
        }
      }
    }
  }


  // rand sequence, length = 4
  final int RANDSEQUENCE = 30;
  void turnFourRandSequence(int time) {
    final int NUM = 4;
    final IntList nums = new IntList(NUM);

    for (int rnd, i = 0; i <= NUM; nums.append(rnd), ++i)
    do {
      rnd = (int) random(nOfStrips);
    } while (nums.hasValue(rnd));

    for (int i = 0; i < NUM; i++) {
      sequenceSet[RANDSEQUENCE][i] = nums.get(i);
    }
    triggerSequence(RANDSEQUENCE, time);
  }
  void bangFourRandSequence(int time) {
    final int NUM = 4;
    final IntList nums = new IntList(NUM);

    for (int rnd, i = 0; i <= NUM; nums.append(rnd), ++i)
    do {
      rnd = (int) random(nOfStrips);
    } while (nums.hasValue(rnd));

    for (int i = 0; i < NUM; i++) {
      sequenceSet[RANDSEQUENCE][i] = nums.get(i);
    }
    bangSequence(RANDSEQUENCE, time);
  }

  // rand on off
  int randomDimOnOffTime = 100;
  void turnRandOneOn() {
    int rnd;
    do {
      rnd = (int) random(nOfStrips);
    }  while (strips[rnd].alpha > 0);
    turnOneOn(rnd, randomDimOnOffTime);
  }
  void turnRandOneOff() {
    int rnd;
    do {
      rnd = (int) random(nOfStrips);
    }  while (strips[rnd].alpha < 100);
    turnOneOff(rnd, randomDimOnOffTime);
  }

  // elapse bang left/right
  void triggerIndependentControl() {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].triggerIndependentControl();
    }
  }
  void bangElapseOne(int id, int st, int en, boolean dir) {
    strips[id].bangElapse(st, en, dir);
  }

  void bangElapseRow(int index, boolean dir) {
    for (int i = 0; i < nOfCol; i++) {
      bangElapseOne(
        i + index * nOfCol,
        dir ? 0 : nOfLED - 1,
        !dir ? 0 : nOfLED - 1,
        dir
      );
    }
  }

  void bangElapseCol(int index, boolean dir) {
    for (int i = 0; i < nOfCol; i++) {
      bangElapseOne(
        index + i * nOfCol,
        dir ? 0 : nOfLED - 1,
        !dir ? 0 : nOfLED - 1,
        dir
      );
    }
  }
  void bangElapseLeft() {
    elapseStateControls[0].bang();
    elapseStateControls[2].bang();
    elapseStateControls[4].bang();
    elapseStateControls[6].bang();
  }
  void bangElapseRight() {
    elapseStateControls[1].bang();
    elapseStateControls[3].bang();
    elapseStateControls[5].bang();
    elapseStateControls[7].bang();  }
  void randomBangElapseLeft() {
    int index = int(random(4)) * 2;
    bangElapse(index);
  }
  void randomBangElapseRight() {
    int index = int(random(4)) * 2 + 1;
    bangElapse(index);
  }

  // bounce bang
  void bangBounceOne(int id, int st, int en) {
    strips[id].bangBounce(st, en);
  }
  void bangBounceRow(int index, boolean dir) {
    for (int i = 0; i < nOfCol; i++) {
      bangBounceOne(
        i + index * nOfCol,
        dir ? 0 : nOfLED - 1,
        !dir ? 0 : nOfLED - 1
      );
    }
  }
  void bangBounceCol(int index, boolean dir) {
    for (int i = 0; i < nOfCol; i++) {
      bangBounceOne(
        index + i * nOfCol,
        dir ? 0 : nOfLED - 1,
        !dir ? 0 : nOfLED - 1
      );
    }
  }

  boolean complexAsyncElapseActivate = false;
  int complexAsyncElapseTriggerIndex = 0;
  boolean bangComplexAsyncElapse = false;
  int complexAsyncElapseIndex = 0;
  int complexAsyncElapseCount = 0;
  int complexAsyncElapseCountLimit = 5;
  int [][][] complexAsyncElapseSet = {
    {
      { 0, 1},
      { 2, 3},
      { 4, 5},
      { 6, 7},
    },
    {
      { 6, 7},
      { 4, 5},
      { 2, 3},
      { 0, 1},
    },
  };
  int [][] complexAsyncElapse;
  void triggerComplexAsyncElapse() {
    triggerComplexAsyncElapse(complexAsyncElapseTriggerIndex);
  }
  void triggerComplexAsyncElapse(int index) {
    if (index == complexAsyncElapseTriggerIndex) {
      complexAsyncElapseActivate = !complexAsyncElapseActivate;
    } else {
      complexAsyncElapseActivate = true;
    }

    complexAsyncElapseTriggerIndex = index;
    complexAsyncElapse = complexAsyncElapseSet[index%complexAsyncElapseSet.length];
    complexAsyncElapseIndex = 0;
    complexAsyncElapseCount = 0;
  }
  void bangComplexAsyncElapse(int index) {
    triggerComplexAsyncElapse(index);
    bangComplexAsyncElapse = true;
  }
  void updateComplexAsyncElapse() {
    if (complexAsyncElapseActivate) {
      complexAsyncElapseCount++;
      if (complexAsyncElapseCount > complexAsyncElapseCountLimit) {

        int[] cas = complexAsyncElapse[complexAsyncElapseIndex];
        for (int i = 0, n = cas.length; i < n; i++) {
          bangElapse(cas[i]);
        }
        complexAsyncElapseIndex = (complexAsyncElapseIndex + 1) % complexAsyncElapse.length;
        complexAsyncElapseCount = 0;

        if (bangComplexAsyncElapse && complexAsyncElapseIndex == 0) {
          triggerComplexAsyncElapse();
          bangComplexAsyncElapse = false;
        }
      }
    }
  }

  ElapseStateControl[] elapseStateControls;
  void initElapseStateControls() {
    elapseStateControls = new ElapseStateControl[8];
    for (int i = 0, n = nOfStrips / nOfCol; i < n; i++) {
      elapseStateControls[2 * i] = new ElapseStateControl(this, i, false);
      elapseStateControls[2 * i + 1] = new ElapseStateControl(this, i, true);
    }
  }
  void updateElapseStateControls() {
    for (int i = 0, n = elapseStateControls.length; i < n; i++) {
      elapseStateControls[i].update();
    }
  }
  void bangElapse(int id) {
    elapseStateControls[id].bang();
  }
  void setElapseCountLimit(int ll) {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].setElapseCountLimit(ll);
    }
  }

  void triggerFadeControl() {
    for (int i = 0; i < nOfStrips; i++) {
      strips[i].triggerFadeControl();
      switch(i / 4) {
        case(0) :
          strips[i].setFadeControlMode(1);
          break;
        case(1) :
          strips[i].setFadeControlMode(0);
          break;
        case(2) :
          strips[i].setFadeControlMode(2);
          break;
      }
    }
  }
  void setFadeControlValue(float value) {
    for (int i = 0; i < 4; i++) {
      strips[i].setFadeControlValue(
        constrain(value * 3.0 - 1.0, 0, 1)
      );
      strips[i + 4].setFadeControlValue(
        constrain(value * 3.0, 0, 1)
      );
      strips[i + 8].setFadeControlValue(
        constrain(value * 3.0 - 1.0, 0, 1)
      );
    }
  }

  boolean getIndependentMode() {
    return (strips[0].independentControl);
  }
  boolean getFadeControlMode() {
    return (strips[0].fadeControl);
  }

}

class ElapseStateControl {
  System system;
  boolean elapsing = false;
  boolean started = false;
  int rowIndex;
  boolean dir; // true for right, false for left

  ElapseStateControl(System _s, int _r, boolean _d) {
    system = _s;
    rowIndex = _r % (_s.nOfStrips / _s.nOfCol);
    dir = _d;
  }
  void bang() {
    elapsing = true;
  }
  void update() {
    if (elapsing) {
      if (!started) {
        started = true;
        int s = nOfLED / 2;
        int e = dir ? (nOfLED - 1) : 0;
        system.bangElapseOne(4 + rowIndex, s, e, dir);
      }
      if (!system.strips[4 + rowIndex].elapses.get(0).elapsing) {
        int s = !dir ? (nOfLED - 1) : 0;
        int e = dir ? (nOfLED - 1) : 0;
        system.bangElapseOne((dir ? 8 : 0) + rowIndex, s, e, dir);
        elapsing = false;
        started = false;
      }
    }
  }
}
