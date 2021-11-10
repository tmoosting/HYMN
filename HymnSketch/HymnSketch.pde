import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress recordAddress;
NetAddress generalAddress;
NetAddress narratorAddress;
NetAddress drumAddress;
NetAddress bellAddress; 

// computer-play logic & debugging
boolean usingComputerControls = false;
boolean skipToBells = false;
int forcedFrequencyStep = 0;

enum Stage {
  NONE, START, TRY, INTRO, DRUMS, BELLS, INFINITY
}
enum StrikeMode {
  NONE, DRUMS, BASS, BELLS, MELODY
}

Stage currentStage = Stage.NONE;
StrikeMode currentStrikeMode = StrikeMode.NONE;



// VR presets
float xDivider = -0.1;
float yDivider = 1.2; 
float leftYMin = 0.85f;
float leftYMax = 1.85f;


// VR inputs
float leftPositionX;
float leftPositionY;
float rightPositionX;
float rightPositionY;
boolean leftTrigger = false;
boolean rightTrigger = false;
int leftTriggerInt ;
int rightTriggerInt ;
int leftPosition = 1; // 1 is north, 2 is south
int rightPosition = 1;
boolean leftPressed = false;
boolean rightPressed = false;


// tutorial trackers
boolean checkForStrikes = false;
boolean checkForTriggers = false;
boolean checkForBells = false;
boolean leftHi;
boolean leftHiTrigger;
boolean leftLo;
boolean leftLoTrigger;
boolean rightHi;
boolean rightHiTrigger;
boolean rightLo;
boolean rightLoTrigger;
int bellTotalHits = 0;
int bellRequiredHits = 40;


// general times
int lengthRecordings = 10000; // in ms
int lengthDing = 700;


// drum times
int lengthNarrOpening = 25300;  
int minimumStrikesToTry = 20;
int lengthNarrTryTriggersAlso = 6100;  
int lengthDelayBeforeDrumsRecording = 5200;
int lengthDrumsOpening = 15000; 
int lengthDrumsFast = 16000; 
int lengthDrumsSlow = 18000; 
int lengthNarrChooseDrums = 9000;
int lengthChoseFastDrums = 6000;
int lengthChoseSlowDrums = 6000;

// bells times
int lengthBellsOpening = 15300;
int lengthBellsTried = 7000;
int lengthBellsHigh = 17200;
int lengthBellsLow = 19200;
int lengthChooseBells = 9000;
int lengthChoseHighBells = 5000;
int lengthChoseLowBells = 5000;
int lengthResolution = 10000;
int lengthFastHigh = 16200;
int lengthFastLow = 18200;
int lengthSlowHigh = 19300;
int lengthSlowLow = 17500;
int lengthFinisher = 16000;

// player input tracking
boolean standbyForDrumsChoice = false;
boolean standbyForBellsChoice = false;
boolean standbyForFinalChoice = false; 
boolean choseDrumRecording = false;
boolean choseBellsRecording = false;

// recording draw-logic-checks
boolean recordingDrums = false;
boolean recordingBells = false;


// composition tracking
boolean chosenFastDrums = false;
boolean chosenHighBells = false;

// thresholds 
int drumThreshold = 20; // strikes over the total recording time to determine 'busyness'
boolean exceededDrums = false;
boolean highBells = false;
int highBellNotes = 0;
int lowBellNotes = 0;



void startTheShow () {  
  currentStage = Stage.START;
  currentStrikeMode = StrikeMode.NONE;

  if (skipToBells == true) {
    startBells();
  } else {
    sendNarratorMsg ("/opening", 1);
    delay(lengthNarrOpening);

    // player gets to try controls
    currentStrikeMode = StrikeMode.DRUMS;
    resetHitTrackers();
    resetHitCounters();
    // now it will be tracked in draw:
    checkForStrikes = true;
  }
}

void completeStrikesTrial() {
  checkForStrikes = false;
  resetHitTrackers();
  resetHitCounters();
  currentStrikeMode = StrikeMode.NONE;
  sendNarratorMsg ("/triedmoving", 1);
  delay(lengthNarrTryTriggersAlso);
  currentStrikeMode = StrikeMode.DRUMS;
  checkForTriggers = true;
}

void completeTriggersTrial () {
  checkForTriggers = false;
  currentStrikeMode = StrikeMode.NONE;
  sendNarratorMsg ("/triedtriggers", 1); 
  delay(lengthDelayBeforeDrumsRecording); // pause before continuing

  startDrums();
}

void startDrums () {
  currentStage = Stage.DRUMS;
  currentStrikeMode = StrikeMode.NONE;
  sendNarratorMsg ("/drumsopening", 1); // explain the goal
  delay(lengthDrumsOpening);

  resetHitCounters(); // to track drum hits
  currentStrikeMode = StrikeMode.DRUMS;
  sendGeneralMsg ("/ding", 1);
  delay(lengthDing);
  sendRecordingMsg ("/startdrums", 1);
  time= millis();
  recordingDrums = true;
}
void finishDrumRecording () {
  sendRecordingMsg ("/stopdrums", 0);
  sendGeneralMsg ("/ding", 1);
  delay(lengthDing);
  resolveDrumRecording();
}

void resolveDrumRecording () {
  currentStrikeMode = StrikeMode.NONE;

  exceededDrums  = (getTotalHits() > drumThreshold);

  if (exceededDrums == true) {
    sendNarratorMsg ("/drumsfast", 1);
    delay(lengthDrumsFast);
    sendGeneralMsg ("/drumsprerecordslow", 1);
    delay(lengthRecordings);
  } else {
    sendNarratorMsg ("/drumsslow", 1);
    delay(lengthDrumsSlow);
    sendGeneralMsg ("/drumsprerecordfast", 1);
    delay(lengthRecordings);
  }
  sendNarratorMsg ("/choosedrums", 1);
  delay(lengthNarrChooseDrums);
  standbyForDrumsChoice = true;
}


void chooseDrumRecording (boolean choosePremadeRecording) {
  standbyForDrumsChoice = false;
  choseDrumRecording = !choosePremadeRecording;

  if (exceededDrums == true) {
    if (choosePremadeRecording == true) {
      chosenFastDrums = false;
    } else {
      chosenFastDrums = true;
    }
  } else {
    if (choosePremadeRecording == true) {
      chosenFastDrums = true;
    } else {
      chosenFastDrums = false;
    }
  }

  if (chosenFastDrums == true) {
    sendNarratorMsg ("/chosefastdrums", 1);
    delay(lengthChoseFastDrums);
  } else {
    sendNarratorMsg ("/choseslowdrums", 1);
    delay(lengthChoseSlowDrums);
  }


  startBells();
}


// ------------------- BELLS


void startBells () {
  currentStage = Stage.BELLS;
  currentStrikeMode = StrikeMode.NONE;
  sendNarratorMsg ("/bellsopening", 1);
  delay(lengthBellsOpening);
  currentStrikeMode = StrikeMode.BELLS; 
  checkForBells = true;
}

void completeBellsTrial () {
  checkForBells = false;
  currentStrikeMode = StrikeMode.NONE;
  sendNarratorMsg ("/bellstried", 1);
  delay(lengthBellsTried);

  sendGeneralMsg ("/ding", 1);
  delay(lengthDing);

  highBellNotes = 0;
  lowBellNotes = 0;
  currentStrikeMode = StrikeMode.BELLS;
  sendRecordingMsg ("/startbells", 1);
  time= millis();
  recordingBells = true;
  bellTotalHits  = 0;
}



void finishBellRecording () {
  sendRecordingMsg ("/stopbells", 0);
  sendGeneralMsg ("/ding", 1);
  delay(lengthDing);
  resolveBellRecording();
}

void resolveBellRecording () {
  currentStrikeMode = StrikeMode.NONE; 
  highBells  = highBellNotes > lowBellNotes; 
  if (highBells == true) {
    sendNarratorMsg ("/bellshigh", 1);
    delay(lengthBellsHigh);
    sendGeneralMsg ("/bellsprerecordlow", 1);
    delay(lengthRecordings);
  } else {
    sendNarratorMsg ("/bellslow", 1);
    delay(lengthBellsLow);
    sendGeneralMsg ("/bellsprerecordhigh", 1);
    delay(lengthRecordings);
  }
  sendNarratorMsg ("/choosebells", 1);
  delay(lengthChooseBells);
  standbyForFinalChoice = false;
  standbyForBellsChoice = true;
}

void chooseBellRecording (boolean choosePremadeRecording) {
  standbyForBellsChoice = false;

  choseBellsRecording = !choosePremadeRecording;
  if (highBells == true) {
    if (choosePremadeRecording == true) {
      chosenHighBells = false;
    } else {
      chosenHighBells = true;
    }
  } else {
    if (choosePremadeRecording == true) {
      chosenHighBells = true;
    } else {
      chosenHighBells = false;
    }
  }

  if (chosenHighBells == true) {
    sendNarratorMsg ("/chosehighbells", 1);
    delay(lengthChoseHighBells);
  } else {
    sendNarratorMsg ("/choselowbells", 1);
    delay(lengthChoseLowBells);
  }


  startFinalSequence();
}

void startFinalSequence () {
  sendNarratorMsg ("/resolution", 1);
  delay(lengthResolution);


  // playback logic
  if (choseDrumRecording == true) {
    sendRecordingMsg("/playdrumrecording", 1);
  } else {
    if (chosenFastDrums == true) {
      sendGeneralMsg ("/drumsprerecordfast", 1);
    } else {
      sendGeneralMsg ("/drumsprerecordslow", 1);
    }
  }
  if (choseBellsRecording == true) {
    sendRecordingMsg("/playbellrecording", 1);
  } else {
    if (chosenHighBells == true) {
      sendGeneralMsg ("/bellsprerecordhigh", 1);
    } else {
      sendGeneralMsg ("/bellsprerecordlow", 1);
    }
  } 

  delay (lengthRecordings);

  if (chosenFastDrums && chosenHighBells) {
    sendNarratorMsg ("/fasthigh", 1);
    delay(lengthFastHigh);
  } else     if (chosenFastDrums && !chosenHighBells ) {
    sendNarratorMsg ("/fastlow", 1);
    delay(lengthFastLow);
  } else     if (!chosenFastDrums && chosenHighBells ) {
    sendNarratorMsg ("/slowhigh", 1);
    delay(lengthSlowHigh);
  } else     if (!chosenFastDrums && !chosenHighBells ) {
    sendNarratorMsg ("/slowlow", 1);
    delay(lengthSlowLow);
  }
  sendNarratorMsg ("/finisher", 1);
  delay(lengthFinisher);

  print ("going infinite");
  currentStage = Stage.INFINITY; 
  standbyForFinalChoice = true;
}


void playIntoInfinity (boolean drumsOverBells) {
  standbyForFinalChoice = false;


  if (drumsOverBells == true) {
    currentStrikeMode = StrikeMode.DRUMS;
  } else { 
    currentStrikeMode = StrikeMode.BELLS;
  }
}




void setup () {
  size (800, 800); 
  fill (255, 100, 0);
  oscP5 = new OscP5(this, 12000);
  recordAddress = new NetAddress("127.0.0.1", 7998); 
  narratorAddress = new NetAddress("127.0.0.1", 7999); 
  generalAddress = new NetAddress("127.0.0.1", 8000);   
  drumAddress = new NetAddress("127.0.0.1", 8001); 
  bellAddress = new NetAddress("127.0.0.1", 8002); 

  oscP5.plug(this, "receiveLVector", "/lpos");
  oscP5.plug(this, "receiveLTrigger", "/l2");  
  oscP5.plug(this, "receiveRVector", "/rpos");
  oscP5.plug(this, "receiveRTrigger", "/r2");
  currentStrikeMode = StrikeMode.NONE;
  currentStage = Stage.NONE;
}


void draw () {
  background (254);

  if (usingComputerControls == false) {
    checkControllerPositions();
  }
  displayPlayerHands();


  drawZoneLines(); 



  if (checkForStrikes == true) {
    if (leftHi&&leftLo&&rightHi&&rightLo && getTotalHits()>minimumStrikesToTry ) {
      completeStrikesTrial();
    }
  }
  if (checkForTriggers == true) {
    if ( leftHiTrigger&&leftLoTrigger&&rightHiTrigger&&rightLoTrigger ) {
      completeTriggersTrial();
    }
  }


  if (recordingDrums == true) {
    if (millis() > time + lengthRecordings)
    {
      recordingDrums = false;
      finishDrumRecording();
    }
  }
  if (recordingBells == true) {
    if (millis() > time + lengthRecordings)
    {
      recordingBells = false;
      finishBellRecording();
    }
  }

  if (checkForBells == true) {
    if (bellTotalHits > 40) {
      completeBellsTrial();
    }
  }

  if (currentStrikeMode == StrikeMode.BELLS) {

    sendBellFreq ("/freq", getBellFrequency());
  }
  if (currentStage == Stage.BELLS) {
    text ("Manual Bell Frequency: "+ forcedFrequencyStep, 20, 20);
  }
}
void keyPressed () {

  if (key == CODED) {
    if (keyCode == LEFT) {
      leftTrigger = true;
      if (standbyForDrumsChoice == true) {
        if (currentStage == Stage.DRUMS) {
          chooseDrumRecording (true);
        }
      }
      if (standbyForBellsChoice == true) {
        if (currentStage == Stage.BELLS) {
          chooseBellRecording (true);
        }
      }
    }
    if (keyCode == RIGHT) {
      rightTrigger = true;
      if (standbyForDrumsChoice == true) {
        if (currentStage == Stage.DRUMS) {
          chooseDrumRecording (false);
        }
      }
      if (standbyForBellsChoice == true) {
        if (currentStage == Stage.BELLS) {
          chooseBellRecording (false);
        }
      }
    }

    if (keyCode == UP) {
      forcedFrequencyStep++;
      if (forcedFrequencyStep > 15) {
        forcedFrequencyStep = 15;
      }
    }
    if (keyCode == DOWN) {
      forcedFrequencyStep--;
      if (forcedFrequencyStep < 0 ) {
        forcedFrequencyStep = 0;
      }
    }
  }

  if (key == 's') {
    //  sendStopRecordMsg(0);
    if (currentStage == Stage.NONE) {
      print ("starting");
      startTheShow ();
    }
  }

  if (key == 'd') {
    if (standbyForFinalChoice == true) {
      if (currentStage == Stage.INFINITY) {
        playIntoInfinity (true);
      }
    }
  }
  if (key == 'b') {
    if (standbyForFinalChoice == true) {
      if (currentStage == Stage.INFINITY) {
        playIntoInfinity (false);
      }
    }
  }
}

void keyReleased () {
  if (key == CODED) {
    if (keyCode == LEFT) {
      leftTrigger = false;
    }
    if (keyCode == RIGHT) {
      rightTrigger = false;
    }
  }
}
void mouseMoved () {
  if (usingComputerControls == true) {
    checkMousePosition();
  }
}



void enterTopLeft () {  
  // controller first enters teh zone with trigger held
  leftPosition =1;

  if (currentStrikeMode == StrikeMode.DRUMS) {
    if (leftTrigger == true) {
      leftHiTrigger = true;
      hitsLeftHiTrigger++;
      sendDrumMsg ("/topleftT", 1);
    } else {
      leftHi= true;
      hitsLeftHi++;
      sendDrumMsg ("/topleftF", 1);
    }
  }
}
void enterBottomLeft () { 
  // controller first enters teh zone with trigger held
  leftPosition =2;
  if (currentStrikeMode == StrikeMode.DRUMS) {
    if (leftTrigger == true) {
      leftLoTrigger = true;
      hitsLeftLoTrigger++;
      sendDrumMsg ("/botleftT", 1);
    } else {
      leftLo = true;
      hitsLeftLo++;
      sendDrumMsg ("/botleftF", 1);
    }
  }
}
void enterTopRight () { 
  // controller first enters teh zone with trigger held
  rightPosition =1;
  if (currentStrikeMode == StrikeMode.DRUMS) {
    if (rightTrigger == true) {
      rightHiTrigger = true;
      hitsRightHiTrigger++;
      sendDrumMsg ("/toprightT", 1);
    } else {
      rightHi = true;
      hitsRightHi++;
      sendDrumMsg ("/toprightF", 1);
    }
  }
  if (currentStrikeMode == StrikeMode.BELLS) {
    bellTotalHits++;
    if (recordingBells == true) {
      if (usingComputerControls == true ) {
        if (forcedFrequencyStep > 8) {
          highBellNotes++;
        } else    if (forcedFrequencyStep < 8) {
          lowBellNotes++;
        }
      } else {
        if (getBellStep () > 8) {
          highBellNotes++;
        } else    if (getBellStep () < 8) {
          lowBellNotes++;
        }
      }
    }
    if (rightTrigger == true) {
      rightHiTrigger = true;
      hitsRightHiTrigger++;
      sendBellStrike ("/toprightT");
    } else {
      rightHi = true;
      hitsRightHi++;

      sendBellStrike ("/toprightF");
    }
  }
}
void enterBottomRight () { 
  // controller first enters teh zone with trigger held
  rightPosition =2;
  if (currentStrikeMode == StrikeMode.DRUMS) {
    if (rightTrigger == true) {
      rightLoTrigger = true; 
      sendDrumMsg ("/botrightT", 1 );
    } else {
      rightLo = true; 
      sendDrumMsg ("/botrightF", 1);
    }
  }
  if (currentStrikeMode == StrikeMode.BELLS) {
    bellTotalHits++;
    if (recordingBells == true) {
      if (usingComputerControls == true ) {
        if (forcedFrequencyStep > 8) {
          highBellNotes++;
        } else    if (forcedFrequencyStep < 8) {
          lowBellNotes++;
        }
      } else {
        if (getBellStep () > 8) {
          highBellNotes++;
        } else    if (getBellStep () < 8) {
          lowBellNotes++;
        }
      }
    }
    if (rightTrigger == true) {
      rightLoTrigger = true; 
      sendBellStrike ("/botrightT" );
    } else {
      rightHi = true; 
      sendBellStrike ("/botrightF" );
    }
  }
}


void pressLeftTrigger () { 
  // print ("leftx: " + leftPositionX + "  lefty: " + leftPositionY +"\n" );

  if (standbyForDrumsChoice == true) {
    if (currentStage == Stage.DRUMS) {
      chooseDrumRecording (true);
    }
  }
  if (standbyForBellsChoice == true) {
    if (currentStage == Stage.BELLS) {
      chooseBellRecording (true);
    }
  }
  if (standbyForFinalChoice == true && currentStage == Stage.INFINITY) {  
    playIntoInfinity (true);
  }
}
void pressRightTrigger() {
  //  print ("rightx: " + rightPositionX + "  righty: " + rightPositionY+"\n");
  if (standbyForDrumsChoice == true) {
    if (currentStage == Stage.DRUMS) {
      chooseDrumRecording (false);
    }
  }
  if (standbyForBellsChoice == true) {
    if (currentStage == Stage.BELLS) {
      chooseBellRecording (false);
    }
  }
  if (standbyForFinalChoice == true && currentStage == Stage.INFINITY) {  
    playIntoInfinity (false);
  }
}



void sendNarratorMsg(String label, int oneOrZero) {
  OscMessage msg = new OscMessage(label); 
  msg.add(oneOrZero);
  oscP5.send(msg, narratorAddress);
}
void sendDrumMsg(String label, int oneOrZero) {
  OscMessage msg = new OscMessage(label); 
  msg.add(oneOrZero);
  oscP5.send(msg, drumAddress);
}
void sendStartRecordMsg(int oneOrZero) {
  OscMessage msg = new OscMessage("/startrecord"); 
  msg.add(oneOrZero);
  oscP5.send(msg, generalAddress);
}
void sendStopRecordMsg(int oneOrZero) {
  OscMessage msg = new OscMessage("/stoprecord"); 
  msg.add(oneOrZero);
  oscP5.send(msg, generalAddress);
} 
void sendGeneralMsg(String label, int oneOrZero) {
  OscMessage msg = new OscMessage(label); 
  msg.add(oneOrZero);
  oscP5.send(msg, generalAddress);
}
void sendRecordingMsg(String label, int oneOrZero) {
  OscMessage msg = new OscMessage(label); 
  msg.add(oneOrZero);
  oscP5.send(msg, recordAddress);
}
void sendBellFreq(String label, float freq) {
  OscMessage msg = new OscMessage(label); 
  msg.add(freq);
  oscP5.send(msg, bellAddress);
}
void sendBellStrike(String label  ) {
  OscMessage msg = new OscMessage(label); 
  msg.add("noteon");
  oscP5.send(msg, bellAddress);
}



// tracking variables

int time = 0;
int hitsLeftHi = 0;
int hitsLeftHiTrigger = 0;
int hitsLeftLo = 0;
int hitsLeftLoTrigger = 0;
int hitsRightHi = 0;
int hitsRightHiTrigger = 0;
int hitsRightLo = 0;
int hitsRightLoTrigger = 0;


// ----------- Unchanging Functions 


void checkMousePosition () {
  if (mouseX > 0 && mouseX < width/2 && mouseY > 0 && mouseY < height/2 ) {
    if (leftPosition != 1)
      enterTopLeft();
  } else if (mouseX > width/2 && mouseX < width && mouseY > 0 && mouseY < height/2 ) {
    if (rightPosition != 1)
      enterTopRight();
  } else if (mouseX > 0 && mouseX < width/2 && mouseY > height/2 && mouseY < height ) {
    if (leftPosition != 2)
      enterBottomLeft();
  } else if (mouseX > width/2 && mouseX < width && mouseY > height/2 && mouseY < height ) {
    if (rightPosition != 2)
      enterBottomRight();
  }
}

void displayPlayerHands() {
  int displayFigureSize = 40; 
  if (leftPosition == 1)
    circle (width/8, height/8, displayFigureSize);    
  else   if (leftPosition == 2)
    circle (width/8, height-(height/8), displayFigureSize);   
  if (rightPosition == 1)
    circle (width-(width/8), height/8, displayFigureSize);    
  else   if (rightPosition == 2)
    circle (width-(width/8), height-(height/8), displayFigureSize);
}


void drawZoneLines () {
  strokeWeight(2);
  line(width/2, 0, width/2, height/4);
  line(width/2, (3*height/4), width/2, height);
  line(0, height/2, width/4, height/2);
  line((3*width/4), height/2, width, height/2);
  line((3*width/4), height/2, width, height/2);
  line (width/4, height/4, (3*width/4), height/4);
  line (width/4, 3*height/4, (3*width/4), 3*height/4);
  line (width/4, height/4, width/4, 3*height/4);
  line (3*width/4, height/4, 3*width/4, 3*height/4);
  strokeWeight(1);
  line(width/2, height/4, width/2, height-(height/4));
  strokeWeight(12);
  if (leftTrigger == true) {
    line (6, 0, 6, height);
  }
  if (rightTrigger == true) {
    line (width-6, 0, width-6, height);
  }
}

public void receiveLTrigger(int valueA, float valueB) { 
  if (valueA == 1) {
    if (leftTrigger == false) {
      pressLeftTrigger();
    }
  } 
  leftTrigger = (valueA == 1);
  leftTriggerInt = valueA;
}
public void receiveLVector(float valueA, float valueB, float valueS) {
  leftPositionX = valueA;
  leftPositionY = valueB;
}
public void receiveRTrigger(int valueA, float valueB) {
  if (valueA == 1) {
    if (rightTrigger == false) {
      pressRightTrigger();
    }
  }  
  rightTrigger = (valueA == 1);
  rightTriggerInt = valueA;
}
public void receiveRVector(float valueA, float valueB, float valueS) {
  rightPositionX = valueA;
  rightPositionY = valueB;
}
void leftControllerIsTop() {

  if (leftPosition == 2) {
    enterTopLeft();
  }
  // cotnroller is in topleft
}

void leftControllerIsBottom() {
  if (leftPosition == 1) {
    enterBottomLeft();
  }
}
void rightControllerIsTop() {
  if (rightPosition == 2) {
    enterTopRight();
    // controlller is in botright
  }
}
void rightControllerIsBottom() {
  if (rightPosition == 1) {
    enterBottomRight();
    // controlller is in botright
  }
}

void checkControllerPositions () {

  if (currentStrikeMode == StrikeMode.DRUMS) {
    if (leftPositionX < xDivider && leftPositionY > yDivider) {
      leftControllerIsTop();
    } else   if (leftPositionX < xDivider && leftPositionY < yDivider) {
      leftControllerIsBottom();
    }
    if (rightPositionX > xDivider && rightPositionY > yDivider) {
      rightControllerIsTop();
    } else   if (rightPositionX > xDivider && rightPositionY < yDivider) {
      rightControllerIsBottom();
    }
  } else   if (currentStrikeMode == StrikeMode.BELLS) {

    if (rightPositionX > xDivider && rightPositionY > yDivider) {
      rightControllerIsTop();
    } else   if (rightPositionX > xDivider && rightPositionY < yDivider) {
      rightControllerIsBottom();
    }
  }
}
int getBellStep () { 
  // 0 is the lowest position, 13 is the highest 
  float yRange = leftYMax - leftYMin; // nu 1
  float stepSize = yRange / 15; 
  float amountOverMin = leftPositionY - leftYMin;
  int bellStep =(int) (amountOverMin / stepSize);
  return bellStep;
}

int getBellFrequency () {


  int bellStep = 0;
  if (usingComputerControls == false) {
    bellStep = getBellStep();
  } else {
    bellStep = forcedFrequencyStep;
  }

  float returnFrequency = 440;

  if (bellStep == 1)
    returnFrequency = 220;
  if (bellStep == 2)
    returnFrequency = 246.941651f;
  if (bellStep == 3)
    returnFrequency = 261.625565;
  if (bellStep == 4)
    returnFrequency = 293.664768; 
  if (bellStep == 5)
    returnFrequency = 329.627557; 
  if (bellStep == 6)
    returnFrequency = 349.228231; 
  if (bellStep == 7)
    returnFrequency = 391.995436; 
  if (bellStep == 8)
    returnFrequency = 440; 
  if (bellStep == 9)
    returnFrequency = 493.883301; 
  if (bellStep == 10)
    returnFrequency = 523.251131; 
  if (bellStep == 11)
    returnFrequency = 587.329536; 
  if (bellStep == 12)
    returnFrequency = 659.255114; 
  if (bellStep == 13)
    returnFrequency = 698.456463;  
  if (bellStep == 14)
    returnFrequency = 783.990872; 
  if (bellStep == 15)
    returnFrequency = 880; 

  int frequencyStep = 660 / 15;

  return (bellStep * frequencyStep) + 220;
}

void resetHitCounters() {
  hitsLeftHi = 0;  
  hitsLeftHiTrigger = 0;
  hitsLeftLo = 0;
  hitsLeftLoTrigger = 0;
  hitsRightHi = 0;
  hitsRightHiTrigger = 0;
  hitsRightLo = 0;
  hitsRightLoTrigger = 0;
}

void resetHitTrackers() {
  leftHi = false;
  leftHiTrigger= false;
  leftLo= false;
  leftLoTrigger= false;
  rightHi= false;
  rightHiTrigger= false;
  rightLo= false;
  rightLoTrigger= false;
}

int getTotalHits () {
  return hitsLeftHi +hitsLeftHiTrigger   + hitsLeftLo  +hitsLeftLoTrigger  + hitsRightHi +hitsRightHiTrigger  + hitsRightLo + hitsRightLoTrigger  ;
}
