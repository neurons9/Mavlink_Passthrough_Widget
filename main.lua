--    Copyright by Jochen Anglett
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
--    
--    Mavlink Messages are based on the work from kam
--    https://github.com/xkam1x/TelemetryPro
--
--    after long research i found this secrets about getting the passthrough bytes correct:
--    http://www.craftandtheoryllc.com/forums/topic/a-diy-script-to-rediscover-more-telem-sensors-with-or-without-flightdeck/
--
--    the rest is documented here:
--    https://cdn.rawgit.com/ArduPilot/ardupilot_wiki/33cd0c2c/images/FrSky_Passthrough_protocol.xlsx


local options = {
	{ "Color", COLOR, WHITE }
}

-- This function is runned once at the creation of the widget
function create(zone, options)
	local values = {svr=0,msg=0,yaw=0,pit=0,rol=0,mod=0,arm=0,sat=0,alt=0,msl=0,spd=0,dst=0,vol=0,cur=0,drw=0,cap=0,lat=0,lon=0,hdp=0,vdp=0,sat=0,fix=0,mav=0,tmp=0}
	local context = { zone=zone, options=options, values=values }
	
	return context
end

local function update(context, newOptions)
	context.options = newOptions
end



local mavType = {}
mavType[0] = "Generic"
mavType[1] = "Fixed wing aircraft"
mavType[2] = "Quadrotor"
mavType[3] = "Coaxial Helicopter"
mavType[4] = "Helicopter"
mavType[5] = "Antenna Tracker"
mavType[6] = "Ground Station"
mavType[7] = "Airship"
mavType[8] = "Free Balloon"
mavType[9] = "Rocket"
mavType[10] = "Ground Rover"
mavType[11] = "Boat"
mavType[12] = "Submarine"
mavType[13] = "Hexarotor"
mavType[14] = "Octorotor"
mavType[15] = "Tricopter"
mavType[16] = "Flapping Wing"
mavType[17] = "Kite"
mavType[18] = "Companion Computer"
mavType[19] = "Two-rotor VTOL"
mavType[20] = "Quad-rotor VTOL"
mavType[21] = "Tiltrotor VTOL"
mavType[22] = "VTOL"
mavType[23] = "VTOL"
mavType[24] = "VTOL"
mavType[25] = "VTOL"
mavType[26] = "Gimbal"
mavType[27] = "ADSB peripheral"
mavType[28] = "Steerable airfoil"

local flightMode = {}
flightMode[0] = ""
flightMode[1] = "Stabilize"
flightMode[2] = "Acro"
flightMode[3] = "Alt Hold"
flightMode[4] = "Auto"
flightMode[5] = "Guided"
flightMode[6] = "Loiter"
flightMode[7] = "RTL"
flightMode[8] = "Circle"
flightMode[10] = "Land"
flightMode[12] = "Drift"
flightMode[14] = "Sport"
flightMode[15] = "Flip"
flightMode[16] = "Auto-Tune"
flightMode[17] = "Pos Hold"
flightMode[18] = "Brake"
flightMode[19] = "Throw"
flightMode[20] = "ADSB"
flightMode[21] = "Guided No GPS"

local armed = {}
armed[0] = "disarmed"
armed[1] = "armed"

local fixetype = {}
fixetype[0] = "No GPS"
fixetype[1] = "No Fix"
fixetype[2] = "GPS 2D Fix"
fixetype[3] = "GPS 3D Fix"

local msgBuffer    = ""
local messages     = ""
local lastMsgValue = 0
local paramValue   = 0
local paramId      = 0


-- Function to convert the bytes into a string
local function bytesToString(bytesArray)
	local tempString = ""
	for i = 1, 36 do
		if bytesArray[i] == '\0' or bytesArray[i] == nil then
			return tempString
		end
		if bytesArray[i] >= 0x20 and bytesArray[i] <= 0x7f then
			tempString = tempString .. string.char(bytesArray[i])
		end
	end
	return tempString
end



local function drawTxt(context)
	lcd.setColor(CUSTOM_COLOR, context.options.Color)
	local FLAGS = SMLSIZE + LEFT + CUSTOM_COLOR
	
	lcd.drawText(10,50,"FrSky Mavlink Passthrough", 0 + LEFT + CUSTOM_COLOR)
	lcd.drawLine(10, 70, 470, 70, DOTTED, CUSTOM_COLOR)
	
	lcd.drawText(  10,80, "Msg ASCII:",      FLAGS)
	lcd.drawText(  10,95, "IMU Temp:",       FLAGS)
	lcd.drawText(  10,110,"Mode:",           FLAGS)
	lcd.drawText(  10,125,"Arm:",   	     FLAGS)
	
	lcd.drawText(  10,150,"Volt:",   	     FLAGS)
	lcd.drawText(  10,165,"Currrent:",       FLAGS)
	lcd.drawText(  10,180,"Cur. draw:",      FLAGS)
	lcd.drawText(  10,195,"Capacity:",       FLAGS)
	
	lcd.drawText(  10,220,"Yaw:",   	 	 FLAGS)
	lcd.drawText(  10,235,"Pitch:", 	     FLAGS)
	lcd.drawText(  10,250,"Roll:",  	     FLAGS)
		
	
	lcd.drawText(120,80, messages,           FLAGS)
	
	if context.values.tmp < 20 then
		lcd.drawText(120,95, "to cold",      FLAGS)
	else
		lcd.drawText(120,95, context.values.tmp .. " dg",    FLAGS)
	end
	
	lcd.drawText(120,110,flightMode[context.values.mod], FLAGS)
	lcd.drawText(120,125,armed[context.values.arm], 	 FLAGS)
	
	lcd.drawText(120,150,context.values.vol .. "V", 	 FLAGS)
	lcd.drawText(120,165,context.values.cur .. "A", 	 FLAGS)
	lcd.drawText(120,180,context.values.drw .. "mAh", 	 FLAGS)
	lcd.drawText(120,195,context.values.cap .. "mAh", 	 FLAGS)		
	
	lcd.drawText(120,220,context.values.yaw .. " dg",    FLAGS)
	lcd.drawText(120,235,context.values.pit .. " dg",    FLAGS)
	lcd.drawText(120,250,context.values.rol .. " dg",    FLAGS)
	
	-- second column
	lcd.drawText(  240,95,"Mav Type:",   FLAGS)
	
	lcd.drawText(  240,120,"Alt:",       FLAGS)
	lcd.drawText(  240,135,"Speed:",     FLAGS)
	lcd.drawText(  240,150,"Distance:",  FLAGS)
	
	lcd.drawText(  240,175,"Lat:",   	 FLAGS)
	lcd.drawText(  240,190,"Lon:",   	 FLAGS)
	lcd.drawText(  240,205,"Hdop:",   	 FLAGS)
	lcd.drawText(  240,220,"Vdop:",   	 FLAGS)
	lcd.drawText(  240,235,"Sat count:", FLAGS)
	lcd.drawText(  240,250,"Fix Type:",  FLAGS)
	
	lcd.drawText(350,95,mavType[context.values.mav],	 FLAGS)
	
	lcd.drawText(350,120,context.values.alt .. "m " .. " MSL: " .. context.values.msl .. "m",   	 FLAGS)
	lcd.drawText(350,135,context.values.spd .. "m/s",   FLAGS)
	lcd.drawText(350,150,context.values.dst .. "m",     FLAGS)
	
	lcd.drawText(350,175,context.values.lat,        	 FLAGS)
	lcd.drawText(350,190,context.values.lon, 			 FLAGS)
	lcd.drawText(350,205,context.values.hdp .. "m",  	 FLAGS)
	lcd.drawText(350,220,context.values.vdp .. "m",  	 FLAGS)
	lcd.drawText(350,235,context.values.sat,  			 FLAGS)
	lcd.drawText(350,250,fixetype[context.values.fix],  FLAGS)
	
end

function refresh(context)
	local iterator=0
	local i0,i1,i2,v = sportTelemetryPop()
	lcd.setColor(CUSTOM_COLOR, context.options.Color)
	local FLAGS = SMLSIZE + LEFT + CUSTOM_COLOR
	
	-- GPS ID is outside passthrough
	gpsLatLon = getValue("GPS")
	if (type(gpsLatLon) == "table") then
		context.values.lat = gpsLatLon["lat"]
		context.values.lon = gpsLatLon["lon"]
	end
	
	-- unpack 5000 packet
	if i2 == 20480 then
      	if (v ~= lastMsgValue) then
        	lastMsgValue = v
        	c1 = bit32.extract(v,0,7)
        	c2 = bit32.extract(v,8,7)
        	c3 = bit32.extract(v,16,7)
        	c4 = bit32.extract(v,24,7)
        	msgBuffer = msgBuffer .. string.char(c4)
        	msgBuffer = msgBuffer .. string.char(c3)
        	msgBuffer = msgBuffer .. string.char(c2)
        	msgBuffer = msgBuffer .. string.char(c1)
        	if (c1 == 0 or c2 == 0 or c3 == 0 or c4 == 0) then
          		messages = msgBuffer
          		msgBuffer = ""
       		end
    	end
    end
	
	-- unpack 5001 packet
	if i2 == 20481 then
	
		--flightMode = bit32.extract(VALUE,0,5)
      	--simpleMode = bit32.extract(VALUE,5,2)
      	--landComplete = bit32.extract(VALUE,7,1)
      	--statusArmed = bit32.extract(VALUE,8,1)
      	--battFailsafe = bit32.extract(VALUE,9,1)
      	--ekfFailsafe = bit32.extract(VALUE,10,2)
	
		context.values.mod = bit32.extract(v,0,5)
		context.values.arm = bit32.extract(v,8,1)

      	context.values.tmp = bit32.extract(v,25,6) + 19
      
	end
	
	-- unpack 5002 packet
	if i2 == 20482 then
		context.values.sat = bit32.extract(v,0,4)
		context.values.fix = bit32.extract(v,4,2)
		context.values.hdp = bit32.extract(v,6,8)/10
		context.values.vdp = bit32.extract(v,14,8)/10
		context.values.msl = bit32.extract(v,22,9)
		if context.values.fix > 3 then context.values.fix = 3 end
	end
	
	-- unpack 5003 packet
	if i2 == 20483 then
		context.values.vol = bit32.extract(v,0,9)/10
		context.values.cur = bit32.extract(v,9,8)/10
		context.values.drw = bit32.extract(v,17,15)
	end
	
	-- unpack 5004 packet
	if i2 == 20484 then
		context.values.dst = bit32.extract(v,0,12)
		context.values.alt = bit32.extract(v,19,12)/10
	end
	
	-- unpack 5005 packet
	if i2 == 20485 then
		context.values.spd = bit32.extract(v,9,8) * 0.2
		context.values.yaw = bit32.extract(v,17,11) * 0.2
	end
	
	-- unpack 5006 packet
	if i2 == 20486 then
		context.values.rol = (bit32.extract(v,0,11) -900) * 0.2
		context.values.pit = (bit32.extract(v,11,10 ) -450) * 0.2
	end
	
	-- unpack 5007 packet
	if i2 == 20487 then
		paramId = bit32.extract(v,24,4)
		paramValue = bit32.extract(v,0,24)
		if paramId == 1 then context.values.mav = paramValue end
		if paramId == 4 then context.values.cap = paramValue end
		--if paramId == 6 then context.values.tmp = paramValue end
	end
	
	drawTxt(context)
end

return { name="MAV-RAW", options=options, create=create, update=update, refresh=refresh }
