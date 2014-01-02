import serial
import time

#connect to the arduino
ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)
ser.open()
time.sleep(2)

#run through the following steps forever
while True:

#actiavte the 'tide' pump based on time
#the arduino 'holds' the last command sent
#so we only need to check four different times

   if float(time.strftime("%H")) == 0.0 or float(time.strftime("%H")) == 12.0:
      ser.write("(tides):tideon;\n")
   time.sleep(5)
   if  float(time.strftime("%H")) == 6.0 or float(time.strftime("%H")) == 18.0:
      ser.write("(tides):tideoff;\n")
   time.sleep(5)

#calling temprequest also tells the arduino
#to correct the temp if needed   

   ser.write("(templog):temprequest;\n")
   temp = ser.readline()
   tempfile = open('/home/pi/logs/templog.txt', 'a')
   tempfile.write(temp)
   tempfile.close

   time.sleep(1)
#calling getlevel also tells the arduino
#to correct the level if needed
   ser.write("(levellog):getlevel;\n")
   

   time.sleep(1)

#activate the light
#   ser.write("(lighting):lightson;\n")
   if 7.0 < float(time.strftime("%H")) < 15.0:
      ser.write("(lighting):lightson;\n")
   if 15.0 < float(time.strftime("%H")) < 7.0:
      ser.write("(lighting):lightsoff;\n")

   time.sleep(1)
