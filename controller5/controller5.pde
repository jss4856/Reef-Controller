/*
//brown A0 - FAN
//green 2 - LEDGDRID
//yellow A3 - HEATER
//orange 4 - Pump???
LIGHTS DIMMED TO 200 out of 255

*/

//INFO - Powerhead relays are pins 4, and 2
//TEMP INPUT WILL BE ON PIN 6 PWM
//BLUE LEDs on pin 3
//WHITE LEDs on pin 5 PWM PINSSSS
//SET DATE THEN REMOVE SET DATE CALL
//FAN ON A0
#include <LiquidCrystal.h>
#include "Wire.h" 
#define DS1307_I2C_ADDRESS 0x68 //set rtc
#include <OneWire.h>
#include <DallasTemperature.h> 
#define ONE_WIRE_BUS 6 //Define the pin of the DS18B20 
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  T E M P   P I N  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
OneWire oneWire(ONE_WIRE_BUS); 
DallasTemperature sensors(&oneWire);


#include "Wire.h" 
#define DS1307_I2C_ADDRESS 0x68 //set rtc
#include <LiquidCrystal.h> // initialize the library with the numbers of the interface pins
#include <OneWire.h>


/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  T E M P   P I N  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
OneWire ds(6);
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  T E M P   P I N  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/


/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  R E L A Y   P A R T  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  S I M P L E   O N   A N D   O F F   F E A T U R E |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/



const int ledPin1 =  A1;          // pin number for relay 1
const int ledPin2 =  2;          // pin number for relay 2

// TEMP CONTROL
int fan = 4;
int heat = 13;
int ledgrid = 116;
int toocold = 81; // Too difficult to maintain exact temp?....
int toohot = 82;
// FAN CONTROL


int ledState1 = LOW;             
int ledState2 = LOW; 
long previousMillis1 = 0;        
long previousMillis2 = 0;
long interval1 = 43200000;          // interval ,at which to blink (milliseconds) for RELAY1
long interval2 = 43200000;  	 // interval at which to blink (milliseconds) for RELAY2


/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L E D   D I M M I N G   P A R T  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  F A D E S   I N   A N D   O U T  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/



int blueramptime = 15 ;    // time for blue LEDs to dim on and off in minutes
int whiteramptime = 15 ;  // time for white LEDs to dim on and off in minutes
int bluemin = 0 ;          // minimmum dimming value of blue LEDs, range of 0-255
int bluemax = 150 ;        // maximum dimming value of blue LEDs, range of 0-255
int whitemin = 0 ;         // minimum dimming value of white LEDs, range of 0-255
int whitemax = 150 ;       // maximum dimming value of white LEDs, range of 0-255
int photoperiod = 570 ;    // amount of time array is on at full power in minutes
int ontime = 10 ;          // time of day (hour, 24h clock) to begin photoperiod fade in
int blue = 3;              // blue LEDs connected to digital pin 3 (pwm)
int white = 5;            // white LEDs connected to digital pin 11 (pwm)
int ledfan = 111;        //this fan is for cooling the LEDs

//int bluepercent[11] = { 0, 1, 2, 5, 8 ,12, 18, 27, 44, 80, 255 };   // this line is needed if you are using meanwell ELN60-48D
//int whitepercent[11] = { 0, 1, 2, 5, 8 ,12, 18, 27, 44, 80, 255 };   // these are the values in 10% increments

int bluepercent[11] = { 0, 35, 65, 90, 107, 120, 129, 137, 143, 146, 149 };   // this line is needed if you are using meanwell ELN60-48P
int whitepercent[11] = { 0, 35, 65, 90, 107, 120, 129, 137, 143, 146, 149 };   // these are the values in 10% increments

LiquidCrystal lcd(7, 8, 9, 10, 11, 12);   // LCD ASSIGNMENT moved from 11 to 13 change this on chip.

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  R T C   C L O C K   D S 1 3 0 7  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

byte decToBcd(byte val)    // Convert normal decimal numbers to binary coded decimal
{
  return ( (val/10*16) + (val%10) );
}

byte bcdToDec(byte val)    // Convert binary coded decimal to normal decimal numbers
{
  return ( (val/16*10) + (val%16) );
}

// 1) Sets the date and time on the ds1307
// 2) Starts the clock
// 3) Sets hour mode to 24 hour clock
// Assumes you're passing in valid numbers
void setDateDs1307(byte second, // 0-59
byte minute, // 0-59
byte hour, // 1-23
byte dayOfWeek, // 1-7
byte dayOfMonth, // 1-28/29/30/31
byte month, // 1-12
byte year) // 0-99
{
  Wire.beginTransmission(DS1307_I2C_ADDRESS);
  Wire.send(0);
  Wire.send(decToBcd(second)); // 0 to bit 7 starts the clock
  Wire.send(decToBcd(minute));
  Wire.send(decToBcd(hour));   // If you want 12 hour am/pm you need to set
  // bit 6 (also need to change readDateDs1307)
  Wire.send(decToBcd(dayOfWeek));
  Wire.send(decToBcd(dayOfMonth));
  Wire.send(decToBcd(month));
  Wire.send(decToBcd(year));
  Wire.endTransmission();
}

// Gets the date and time from the ds1307
void getDateDs1307(byte *second,
byte *minute,
byte *hour,
byte *dayOfWeek,
byte *dayOfMonth,
byte *month,
byte *year)
{
  // Reset the register pointer
  Wire.beginTransmission(DS1307_I2C_ADDRESS);
  Wire.send(0);
  Wire.endTransmission();

  Wire.requestFrom(DS1307_I2C_ADDRESS, 7);

  // A few of these need masks because certain bits are control bits
  *second = bcdToDec(Wire.receive() & 0x7f);
  *minute = bcdToDec(Wire.receive());
  *hour = bcdToDec(Wire.receive() & 0x3f); // Need to change this if 12 hour am/pm
  *dayOfWeek = bcdToDec(Wire.receive());
  *dayOfMonth = bcdToDec(Wire.receive());
  *month = bcdToDec(Wire.receive());
  *year = bcdToDec(Wire.receive());
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  O N E S E C O N D |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

void onesecond() //function that runs once per second while program is running
{
  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;
  getDateDs1307(&second, &minute, &hour, &dayOfWeek, &dayOfMonth, &month, &year);
  lcd.setCursor(0, 0);
  if(hour>0)
  {
    if(hour<=12)
    {
      lcd.print(hour, DEC);
    }
    else
    {
      lcd.print(hour-12, DEC);
    }
  }
  else
  {
    lcd.print("12");
  }
  lcd.print(":");
  if (minute < 10) {
    lcd.print("0");
  }
  lcd.print(minute, DEC);
  lcd.print(":");
  if (second < 10) {
    lcd.print("0");
  }
  lcd.print(second, DEC);
  if(hour<12)
  {
    lcd.print("am");
  }
  else
  {
    lcd.print("pm");
  }
  lcd.print(" ");
  delay(1000);
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  L E D  G R I D  O N |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void ledgridon()
{digitalWrite(ledgrid, HIGH);
}
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  L E D  G R I D  O F F |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void ledgridoff()
{
  digitalWrite(ledgrid, LOW);
}
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  F A N S  O N |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void fanon()
{
  digitalWrite(fan, HIGH);  
  lcd.setCursor(9, 3);
  lcd.print("Fan On ");
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  F A N S   O F F |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void fanoff()
{
  digitalWrite(fan, LOW);
  lcd.setCursor(9, 3);
  lcd.print("Fan Off");
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  H E A T   O N |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void heaton()
{
  digitalWrite(heat, HIGH);
  lcd.setCursor(0, 3);
  lcd.print("Heat On ");
}
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  H E A T   OFF |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/
void heatoff()
{
  digitalWrite(heat, LOW);
  lcd.setCursor(0, 3);
  lcd.print("Heat Off");
}
/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  R E L A Y 1 |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

void relay1()  //FUNCTION TO TURN ON AND OFF RELAY 1.
{ 
  unsigned long currentMillis = millis();

  if(currentMillis - previousMillis1 > interval1) 
  { 
    previousMillis1 = currentMillis;   
    if (ledState1 == LOW)
      ledState1 = HIGH;
    else
      ledState1 = LOW;
    digitalWrite(ledPin1, ledState1);
  }
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  D E F I N E  :  R E L A Y 2 |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

void relay2()
{
  unsigned long currentMillis2 = millis();

  if(currentMillis2 - previousMillis2 > interval2) 
  {
    previousMillis2 = currentMillis2;   
    if (ledState2 == LOW)
      ledState2 = HIGH;
    else
      ledState2 = LOW;
    digitalWrite(ledPin2, ledState2);

  }
}

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  S E T U P  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

void setup() {
 pinMode(ledPin1, OUTPUT);    // set the digital pin as output:
  pinMode(ledPin2, OUTPUT);    // set the digital pin as output:
  pinMode(heat, OUTPUT);
  pinMode(fan, OUTPUT);
  digitalWrite(heat, HIGH); //if mechanical relays start LOW when the arduino boots the devices will all turn on
  digitalWrite(fan, HIGH);     // Set analog pin 1 as a output
 // pinMode(ledgrid, OUTPUT);
  /*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  S E T U P - D I S P L A Y |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;
  Wire.begin();

  // Change these values to what you want to set your clock to.
  // You probably only want to set your clock once and then remove
  // the setDateDs1307 call.
  second = 3;
  minute = 18;
  hour = 20;
  dayOfWeek = 4;  // Sunday is 0
  dayOfMonth = 21;
  month = 2;
  year = 11;
  //setDateDs1307(second, minute, hour, dayOfWeek, dayOfMonth, month, year);

  analogWrite(blue, bluemin);
  analogWrite(white, whitemin);
  lcd.begin(20, 4); // set up the LCD's number of rows and columns: 
  //  lcd.print("12:00 80.6"); // Print a message to the LCD.
  //  lcd.print(char(223));
  lcd.setCursor(0, 1);
  lcd.print("blue:");
  lcd.print(33*bluemin/85);
  lcd.setCursor(8, 1);
  lcd.print("white:");
  lcd.print(33*whitemin/85);  
}
void temperature() 
{ 
  sensors.requestTemperatures(); // Send the command to get temperatures 
  delay(1500); 
  float temp2=0; 
  lcd.setCursor(14, 0); 
  temp2= sensors.getTempFByIndex(0); 
  lcd.print(sensors.getTempFByIndex(0));  
  lcd.print((char)223); 

  if(temp2>toohot) return fanon(),heatoff(); //these work, but cause a constant state of either relay being ON
  if(temp2<toocold) return heaton(),fanoff();


//if (temp2 > toohot){fanon();}  
  //else {fanoff();}
  
//if (temp2<toocold){heaton();}
 // else {heatoff();}
    

} 


/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L O O P |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

void loop()
{
  
  onesecond();
  relay2();
  relay1();
            temperature();


 
// TEMP ADDITION $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

/* could POSSIBLY work without all the serial.printing */


  
 //FAN CONTROL BELOW ##########################

//#############################################

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

  /*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L O O P - D I M   F U N C T I O N |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;
  getDateDs1307(&second, &minute, &hour, &dayOfWeek, &dayOfMonth, &month, &year);
  int daybyminute = ((hour * 60) + minute); //converts time of day to a single value in minutes
      

  int bluerampup;
     if (daybyminute >= (ontime*60)) 
       bluerampup = (((ontime*60) + blueramptime) - daybyminute);
     else
       bluerampup = blueramptime;
       
  int whiterampup;
    if (daybyminute >= (ontime*60 + blueramptime)) 
       whiterampup = (((ontime*60) + blueramptime + whiteramptime) - daybyminute);
     else
       whiterampup = whiteramptime;

  int whiterampdown;
    if (((ontime * 60) + photoperiod + blueramptime + whiteramptime) <= daybyminute)
      whiterampdown = (((ontime*60) + photoperiod + blueramptime + 2*whiteramptime) - daybyminute);
    else
      whiterampdown = whiteramptime;
      
  int bluerampdown;
    if (((ontime * 60) + photoperiod + blueramptime + 2*whiteramptime) <= daybyminute)
      bluerampdown = (((ontime*60) + photoperiod + 2*blueramptime + 2*whiteramptime) - daybyminute);
    else
      bluerampdown = blueramptime;

  /*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L O O P - F A D E  I N |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

 if (daybyminute >= (ontime*60))
  { 
    if (daybyminute <= ((ontime*60) + blueramptime + (whiteramptime/10*9))) //if time is in range of fade in, start fading in + (whiteramptime/10*9)
    {
      // fade blue LEDs in from min to max.
      for (int i = 1; i <= 10; i++) // setting ib value for 10% increment. Start with 0% 
      { 
        analogWrite(blue, bluepercent[i]); 
        lcd.setCursor(5, 1);
        lcd.print(i);
        lcd.print(" "); 
      
        int countdown = ((bluerampup*60)/10); // calculates seconds to next step
        while (countdown>0)
          {
          onesecond(); // updates clock once per second
          countdown--;
          
          relay2();
          relay1();
          temperature();

        }
      }      

      // fade white LEDs in from min to max.
      for (int i = 1; i <= 10; i++) // setting i value for 10% increment. Start with 0%
      { 
        analogWrite(white, whitepercent[i]); 
       // digitalWrite(ledgrid, HIGH);
        lcd.setCursor(14, 1);
        lcd.print(i);
        lcd.print(" "); 

        int countdown = ((whiterampup*60)/10); // calculates seconds to next step
        while (countdown>0)
        {
          onesecond(); // updates clock once per second
          countdown--;
                  temperature();
        }
      } 
    }
  }

  /*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L O O P - M A X  V A L U E |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

 if (daybyminute >= ((ontime * 60) + blueramptime + whiteramptime)) 
  { 
    if ( daybyminute < ((ontime * 60) + blueramptime + whiteramptime + photoperiod)) // if time is in range of photoperiod, turn lights on to maximum fade value
    {
      analogWrite(blue, 255);
        lcd.setCursor(5, 1);
        lcd.print(10);
        lcd.print(" ");
      analogWrite(white, 255); 
      //digitalWrite(ledgrid, HIGH);
      lcd.setCursor(14, 1);
        lcd.print(10);
        lcd.print(" "); 
          temperature();
      
        
      
    }
 
  }

  /*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  L O O P - F A D E  O U T |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

  if (((ontime * 60) + photoperiod + blueramptime + whiteramptime) <= daybyminute)
  { 
    if (((ontime * 60) + photoperiod + whiteramptime + 2*blueramptime + (blueramptime/10*9)) >= daybyminute)
    {
      // fade white LEDs out from max to min in increments of 1 point:
      for (int i = 10; i >= 0; i--) // setting i value for 10% increment. Start with 10%
      { 
        analogWrite(blue, 255);
        lcd.setCursor(5, 1);
        lcd.print(10);
        lcd.print(" "); 
        
        analogWrite(white, whitepercent[i]); 

        lcd.setCursor(14, 1);
        lcd.print(i);
        lcd.print(" ");


        int countdown = ((whiterampdown*60)/10); // calculates seconds to next step
        while (countdown>0)
        {
          onesecond(); // updates clock once per second
          countdown--;
          relay2();
          relay1();
           temperature();

        }

      } 

      // fade blue LEDs out from max to min in increments of 1 point:
      for (int i = 10; i >= 0; i--) // setting i value for 10% increment. Start with 10%
      { 
        analogWrite(blue, bluepercent[i]);
        lcd.setCursor(5, 1);
        lcd.print(i);
        lcd.print(" "); 

        int countdown = ((bluerampdown*60)/10); // calculates seconds to next step
        while (countdown>0)
        {
          onesecond(); // updates clock once per second
          countdown--;
          relay2();
          relay1();
          temperature();


        }
      }

    }
  }
 



 
 //if (daybyminute > fan_on_time*60) return fanon();
 //if (daybyminute > (fan_on_time*60 + photoperiod + whiteramptime)) return fanoff();
 
 
 
 // Fancontrol for LED Fan
 


}  // END LOOP