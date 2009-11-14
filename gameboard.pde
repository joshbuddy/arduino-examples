//**************************************************************//
//  Name    : shiftOutCode, Dual Binary Counters                 //
//  Author  : Carlyn Maw, Tom Igoe                               //
//  Date    : 25 Oct, 2006                                       //
//  Version : 1.0                                                //
//  Notes   : Code for using a 74HC595 Shift Register            //
//          : to count from 0 to 255                             //
//**************************************************************//

//Pin connected to ST_CP of 74HC595
const int latchPin = 8;
//Pin connected to SH_CP of 74HC595
const int clockPin = 12;
////Pin connected to DS of 74HC595
//int dataPin0 = 10;
const int dataPin = 11;

const int button1Pin = 9;     // the number of the pushbutton pin

int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 50;    // the debounce time; increase if the output flickers


/* Global/static vars */


int digit(int pos, char c) {
  switch (c) {
    case '0': return pos == 0 ? (1 << 8) * 7 + 176 : (1 << 8) * 176 + 14;
    case '1': return pos == 0 ? (1 << 8) * 4 + 16 : (1 << 8) * 128 + 2;
    case '2': return pos == 0 ? (1 << 8) * 3 + 112 : (1 << 8) * 112 + 6;
    case '3': return pos == 0 ? (1 << 8) * 6 + 112 : (1 << 8) * 224 + 6;
    case '4': return pos == 0 ? (1 << 8) * 4 + 208 : (1 << 8) * 192 + 10;
    case '5': return pos == 0 ? (1 << 8) * 6 + 224 : (1 << 8) * 224 + 12;
    case '6': return pos == 0 ? (1 << 8) * 7 + 224 : (1 << 8) * 240 + 12;
    case '7': return pos == 0 ? (1 << 8) * 4 + 48 : (1 << 8) * 128 + 6;
    case '8': return pos == 0 ? (1 << 8) * 7 + 240 : (1 << 8) * 240 + 14;
    case '9': return pos == 0 ? (1 << 8) * 4 + 240 : (1 << 8) * 192 + 14;
  }
}
/*
int leftDigits[] = { 
  (1 << 8) * 7 + 176, // 0
  (1 << 8) * 4 + 16,  // 1
  (1 << 8) * 3 + 112, // 2
  (1 << 8) * 6 + 112, // 3
  (1 << 8) * 4 + 208, // 4
  (1 << 8) * 6 + 224, // 5
  (1 << 8) * 7 + 224, // 6
  (1 << 8) * 4 + 48,  // 7
  (1 << 8) * 7 + 240, // 8
  (1 << 8) * 4 + 240  // 9
};

int rightDigits[] = { 
  (1 << 8) * 176 + 14, // 0
  (1 << 8) * 128 + 2,   // 1
  (1 << 8) * 112 + 6,  // 2
  (1 << 8) * 224 + 6,  // 3
  (1 << 8) * 192 + 10,  // 4
  (1 << 8) * 224 + 12,  // 5
  (1 << 8) * 240 + 12,  // 6
  (1 << 8) * 128 + 6,  // 7
  (1 << 8) * 240 + 14,   // 8
  (1 << 8) * 192 + 14,  // 9
};
*/
void setup() {
  //Start Serial for debuging purposes	
  //Serial.begin(9600);
  //set pins to output because they are addressed in the main loop
  pinMode(latchPin, OUTPUT);
  pinMode(button1Pin, INPUT);
  digitalWrite(button1Pin, HIGH);
  delay(1000);
}

void loop() {
  //count up routine
  char number[10] = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
  
   // read the state of the switch into a local variable:
   int reading = digitalRead(button1Pin);
  
   // check to see if you just pressed the button 
   // (i.e. the input went from LOW to HIGH),  and you've waited 
   // long enough since the last press to ignore any noise:  
  
   // If the switch changed, due to noise or pressing:
   if (reading != lastButtonState) {
     // reset the debouncing timer
     lastDebounceTime = millis();
   } 
  
   if ((millis() - lastDebounceTime) > debounceDelay) {
     // whatever the reading is at, it's been there for longer
     // than the debounce delay, so take it as the actual current state:
     buttonState = reading;
   }
  
   // set the LED using the state of the button:
   digitalWrite(ledPin, buttonState);
  
   // save the reading.  Next time through the loop,
   // it'll be the lastButtonState:
   lastButtonState = reading;  

  if (bounceFilter == 0) {
    if (buttonState != digitalRead(button1Pin)) {
      buttonState = (buttonState == HIGH ? LOW : HIGH);
      bounceFilter = BOUNCE_DELAY;
  
      if (buttonState == LOW) {
        number[0] = '0';
      } else {
        number[0] = '2';
      }
    }
  } else {
    bounceFilter--;
  }
  
  
  
  //unsigned long num = 999999999UL; //(int)rand() * 1000000000;
  digitalWrite(latchPin, 0);
  for(int i = 0; i < 10; i+=2) {
    shiftOut(dataPin, clockPin, 65535 ^ (digit(0, number[i]) | digit(1, number[i + 1]))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
  }
  
  //writeBinNumber(num);
  
  digitalWrite(latchPin, 1);
  delay(10);
  
  
  
  
  /*
  for (int j=0; j<=1000000000; j+=1000) {
    digitalWrite(latchPin, 0);
   // shiftOut(dataPin, clockPin, 65535);
    //shiftOut(dataPin, clockPin, 65535);
    //shiftOut(dataPin, clockPin, 65535);
    //shiftOut(dataPin, clockPin, 65535);
    shiftOut(dataPin, clockPin, 65535 ^ (number(j / 10000000))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    shiftOut(dataPin, clockPin, 65535 ^ (number((j / 100000) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    shiftOut(dataPin, clockPin, 65535 ^ (number((j / 1000) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    shiftOut(dataPin, clockPin, 65535 ^ (number((j / 10) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    shiftOut(dataPin, clockPin, 65535 ^ (number((j) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    digitalWrite(latchPin, 1);
    delay(10);
  }
  */


}

//void writeBinNumber(unsigned long num) {
//    shiftOut(dataPin, clockPin, 65535 ^ (number(num / 100000000))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
//    shiftOut(dataPin, clockPin, 65535 ^ (number((num / 1000000) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
//    shiftOut(dataPin, clockPin, 65535 ^ (number((num / 10000) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
//    shiftOut(dataPin, clockPin, 65535 ^ (number((num / 100) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
//    shiftOut(dataPin, clockPin, 65535 ^ (number((num) % 100))); // | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
//}

void shiftOut(int myDataPin, int myClockPin, int myDataOut) {
  // This shifts 8 bits out MSB first, 
  //on the rising edge of the clock,
  //clock idles low

  //internal function setup
  int i=0;
  int pinState;
  pinMode(myClockPin, OUTPUT);
  pinMode(myDataPin, OUTPUT);

  //clear everything out just in case to
  //prepare shift register for bit shifting
  digitalWrite(myDataPin, 0);
  digitalWrite(myClockPin, 0);

  //for each bit in the byte myDataOut�
  //NOTICE THAT WE ARE COUNTING DOWN in our for loop
  //This means that %00000001 or "1" will go through such
  //that it will be pin Q0 that lights. 
  for (i=15; i>=0; i--)  {
    digitalWrite(myClockPin, 0);

    //if the value passed to myDataOut and a bitmask result 
    // true then... so if we are at i=6 and our value is
    // %11010100 it would the code compares it to %01000000 
    // and proceeds to set pinState to 1.
    if ( myDataOut & (1<<i) ) {
      pinState= 1;
    }
    else {	
      pinState= 0;
    }

    //Sets the pin to HIGH or LOW depending on pinState
    digitalWrite(myDataPin, pinState);
    //register shifts bits on upstroke of clock pin  
    digitalWrite(myClockPin, 1);
    //zero the data pin after shift to prevent bleed through
    digitalWrite(myDataPin, 0);
  }

  //stop shifting
  digitalWrite(myClockPin, 0);
}

//int number(int num) {
//  return leftDigits[num / 10] | rightDigits[num % 10];
//}



