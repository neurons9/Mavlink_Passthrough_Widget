# Mavlink_Passthrough_Widget
Lua Script to get telemetry values from Ardupilot Mavlink to Frsky Passthrough protocol.<br>
This script is a proof of concept for the following project:<br>
https://github.com/zendrones/Horus-Mavlink-Telemetry


after long research and try and error i found this important information of how to get the bytes:
http://www.craftandtheoryllc.com/forums/topic/a-diy-script-to-rediscover-more-telem-sensors-with-or-without-flightdeck/

Bugs and to-do:
1. vdop seems to get no values
2. change text color in widget options does not work, change the color in line 32 { "COLOR", COLOR, WHITE }

<img src="https://github.com/zendrones/Mavlink_Passthrough_Widget/blob/master/mavlink_passthrough.jpg">

Use a whole telemetry widget screen and turn off trim

