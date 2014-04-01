Lunar Trails serial port protocol
---------------------------------

# From LunarGraph Arduino to Processing App: 

***ready:nn***

Informs you that the LunarGraph has completed a command. nn is the number of commands it still has to process. 

When the LunarGraph restarts it sends the following information : 

***RESTARTING -----------------------------***

It then sends the following set up values : 

***pagewidth:*nn
*pageheight:*nn**

Sends the page width/height where nn a value in steps

***stepspermil:nn.nn***

The number of steps per mm - floating point number to 20 decimal places

***pagetop:*nn**

The page top position in steps. Not really sure what this is for.


***CHANGE STATE:*n**

Where n is the state based on : 

*0 : Waiting
1 : Error 
2 : Resetting 
3 : Calibrating 
4 : Drawing*

***buttons:*b**

Notification on a switch state change as a list of bits. From most to least significant : 

LH end stop minimum (top)
LH end stop maximum (bottom)
RH end stop minimum (top)
RH end stop maximum (bottom)
LH calibration switch
RH calibration switch

Heartbeat

***\****
The LunarGraph sends a single "\*" on its own line every 5 seconds to show that it's happy. 

***CLOCK RESETTING -----------------------***

After the LunarGraph has been running for a while its internal clock will reset back to zero. This is how it tells you. 

***ERROR:*error**

If a motor error or endstop hit occurs the LunarGraph will report it using this command. Note that you don't have to read this, as the change state command will also occur. This is just extra info. 

***NEXT COMMAND* num cmd p1 p2**

Reporting the command that it's executing

#From Processing app to LunarGraph Arduino



##Thoughts about improvements 

Get rid of heartbeat - instead Arduino sends through current position every 100(?)ms Along with a yes or no to send more commands through. 

Processing then doesn't care how many commands Arduino can handle, only a yes or no to send more commands. 

When a command is sent through the Arduino can confirm that it has received the command. 
