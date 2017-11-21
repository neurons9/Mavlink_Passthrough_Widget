# Mavlink_Passthrough_Widget
Lua Script to get telemetry values vom Ardupilot Mavlink to Frsky Passthrough protocol

after long research and try and error i found the folling important information of how to get the bytes:
http://www.craftandtheoryllc.com/forums/topic/a-diy-script-to-rediscover-more-telem-sensors-with-or-without-flightdeck/

Bugs and to-do:
1. offset of packet 5007 is wrong in excel-sheet:
https://cdn.rawgit.com/ArduPilot/ardupilot_wiki/33cd0c2c/images/FrSky_Passthrough_protocol.xlsx
source:
https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_Frsky_Telem/AP_Frsky_Telem.cpp

2. vdop seems to get no values

3. change text color in widget options does not work, change the color in line 32 { "COLOR", COLOR, WHITE }



