//**************************************************************//
//  Name    : shiftOutCode, Dual Binary Counters                 //
//  Author  : Carlyn Maw, Tom Igoe                               //
//  Date    : 25 Oct, 2006                                       //
//  Version : 1.0                                                //
//  Notes   : Code for using a 74HC595 Shift Register            //
//          : to count from 0 to 255                             //
//**************************************************************//

//Pin connected to ST_CP of 74HC595
int latchPin = 8;
//Pin connected to SH_CP of 74HC595
int clockPin = 12;
////Pin connected to DS of 74HC595
//int dataPin0 = 10;
int dataPin = 11;

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
  (1 << 8) * 112 + 14, // 0
  (1 << 8) * 64 + 2,   // 1
  (1 << 8) * 176 + 6,  // 2
  (1 << 8) * 224 + 6,  // 3
  (1 << 8) * 192 + 10,  // 4
  (1 << 8) * 224 + 12,  // 5
  (1 << 8) * 240 + 12,  // 6
  (1 << 8) * 64 + 6,  // 7
  (1 << 8) * 240 + 14,   // 8
  (1 << 8) * 192 + 14,  // 9
};

void setup() {
  //Start Serial for debuging purposes	
  Serial.begin(9600);
  //set pins to output because they are addressed in the main loop
  pinMode(latchPin, OUTPUT);

}

void loop() {
  //count up routine

  for (int j=0; j<=99; j++) {
    digitalWrite(latchPin, 0);
    shiftOut(dataPin, clockPin, 65535 ^ (number(j) | (8 * 256 * ((j/5) % 2)) | (1 * (1 - ((j/5) % 2)))) );
    digitalWrite(latchPin, 1);
    delay(100);
  }



}

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

int number(int num) {
  return leftDigits[num / 10] | rightDigits[num % 10];
}

