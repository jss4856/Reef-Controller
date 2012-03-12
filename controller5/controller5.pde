//INCLUDES##################################################################################### 
#include <OneWire.h> 
#include "Wire.h" 
#include <Time.h> 
#include <TimeAlarms.h> 
#include <DS1307RTC.h>  // a basic DS1307 library that returns time as a time_t 
#include <LiquidCrystal.h> 
#include <DallasTemperature.h> 
#define ONE_WIRE_BUS 6 //Define the pin of the DS18B20 
//VARIABLE##################################################################################### 
LiquidCrystal lcd(7, 8, 9, 10, 11, 12); 
//circulation control 
//powerhead 1 is for waves, should be used with a solid state relay 
//powerhead 2 is for tidal surge 2x per day 
int powerhead1 = -100; 
int powerhead2 = -100; 
int powerhead1state = LOW; 

long previousMillis1 = 0;         
long interval1 = 3000; // wave interval for powerhead1 

void wavemaker()  //relay is based off interval1 
{  
  unsigned long currentMillis = millis(); 

  if(currentMillis - previousMillis1 > interval1)  
  {  
    previousMillis1 = currentMillis;    
    if (powerhead1state == LOW) 
      powerhead1state = HIGH; 
    else 
      powerhead1state = LOW; 
    digitalWrite(powerhead1, powerhead1state); 
  } 
} 

/////////////////////////////// 
//temperature control 
//mechanical relays are fine here 
OneWire oneWire(ONE_WIRE_BUS); 
DallasTemperature sensors(&oneWire); 

int fan = A0; 
int heat = 4; 
//temperature tolerances 
int toohot = 82; 
int toocold = 80; 

void fanon() 
{digitalWrite(fan,HIGH);} 

void fanoff() 
{digitalWrite(fan,LOW);} 

void heaton() 
{digitalWrite(heat,HIGH);} 

void heatoff() 
{digitalWrite(heat,LOW);} 

//////////////////////////////// 
//secondary lighting 
int ledmatrix = A1; 
int refugium = 2; 
/////////////////////////////// 
//primary Lighting 
int mainlights = 3;    // LED connected to digital pin 3 
int fadetime = (/*minutes to fade here-> */((60)/*<-minutes to fade*/*60000)/255); 


//////////////////////////////// 
//weather patterns 
long randNumber; 



//############################################################################################# 
void temperature() 
{ 
  sensors.requestTemperatures(); // Send the command to get temperatures 
  delay(1000); 
  float temp2=0; 
  lcd.setCursor(14, 0); 
  temp2= sensors.getTempFByIndex(0); 
  lcd.print(sensors.getTempFByIndex(0));  
  lcd.print((char)223); 

  if(temp2>toohot) return fanon(),heatoff(),lcd.setCursor(16,3), lcd.print("Cool"); 
  if(temp2<toocold) return heaton(),fanoff(),lcd.setCursor(16,3), lcd.print("Heat"); 
} 
//############################################################################################# 
void digitalClockDisplay() 
{  
  lcd.setCursor(0,0); 
  lcd.print(hour()); 
  lcd.print(":"); 
  if (minute()<10) lcd.print("0"); 
  lcd.print(minute()); 
  delay(1000); 
} 
//############################################################################################# 

void sunrise() 
{ 
  lcd.setCursor(7,1); 
  lcd.print("Morning"); 
  delay(500); 
   
  digitalWrite(refugium,LOW); 
   
    // fade in from min to max in increments of 1 points: 
    //starting at 20 with the meanwell eln-p driver gives a nice moon light effect.
    //values below 26 don't process correctly with this driver?
    for(int fadeValue = 20 ; fadeValue <= 255; fadeValue +=1) {  
    // sets the value (range from 0 to 255): 
    analogWrite(mainlights, fadeValue);          
    delay(fadetime); 
  } 
} 
   
//############################################################################################# 
void noon() 
{ 
  lcd.setCursor(7,1); 
  lcd.print("Sunny  "); 
  digitalWrite(refugium,LOW); 
  digitalWrite(ledmatrix,HIGH); 
    
   
}   
   
//#############################################################################################   

void sunset() 
{ 
    lcd.setCursor(7,1); 
  lcd.print("Night  "); 
   
  digitalWrite(refugium,HIGH); 
  digitalWrite(ledmatrix,LOW); 
   
    // fade out from max to min in increments of 1 points: 
    for(int fadeValue = 255 ; fadeValue >= 20; fadeValue -=1) {  
    // sets the value (range from 0 to 255): 
    analogWrite(mainlights, fadeValue);          
    delay(fadetime);   
  } 
} 
/////////////////////////////////////////////////////////////////////////////////////////// 

void setup() 
{ 

 // digitalWrite(refugium, LOW); 
 // digitalWrite(ledmatrix, LOW); 
  analogWrite(mainlights, 0); //starts lights as 'off' 
  pinMode(heat, OUTPUT); 
  pinMode(fan, OUTPUT); 
  pinMode(powerhead1, OUTPUT); 
  pinMode(powerhead2,OUTPUT); 
  pinMode(ledmatrix, OUTPUT); 
  pinMode(refugium, OUTPUT); 

  lcd.begin(20, 4);  // sets LCD screen 
  sensors.begin();  // starts temp sensor 
  Wire.begin(); //starts onewire communication 
  Serial.begin(9600); //possibly unnecessary 

  byte second, minute, hour; 


  setSyncProvider(RTC.get);   //get the time from the RTC 


  ///@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2.2 
  ///////////Lighting cycle 
  Alarm.alarmRepeat(8,30,00,sunrise); 
  Alarm.alarmRepeat(9,30,00,noon); 
  Alarm.alarmRepeat(19,30,00,sunset); 


} 


void  loop() 
{ 
  Alarm.delay(1000); // service the alarm timers once per second 
  digitalClockDisplay(); 
  temperature(); 
  wavemaker(); 
}  
