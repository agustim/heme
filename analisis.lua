#!/usr/bin/lua

led1 = "/sys/class/leds/wpj342:green:sig3"
led2 = "/sys/class/leds/wpj342:green:sig4"
led3 = "/sys/class/leds/wpj342:red:sig1"
led4 = "/sys/class/leds/wpj342:yellow:sig2"
LED_OFF = 0
LED_ON = 255
file = "/www/heme/dades.js"

function run(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

function run_array(command)
	local handle = io.popen(command);
	local arr = {}
	for line in handle:lines() do
	    table.insert (arr, line);
	end
	handle:close()
	return(arr)
end
function led_on(led)
	run("echo " .. LED_ON .. " > "..led.."/brightness")
end
function led_off(led)
	run("echo " .. LED_OFF .. " > "..led.."/brightness")
end
function wait_led (seconds)
	seconds = seconds or 3
	for i = 1, seconds do
		led_on(led1)
		led_off(led2)
		run("sleep 1")
		led_off(led1)
		led_on(led2)
		run("sleep 1")
	end
end

function implode(delimiter, list)
  local len = #list
  if len == 0 then
    return ""
  end
  local string = list[1]
  for i = 2, len do
    string = string .. delimiter .. list[i]
  end
  return string
end

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

data = {}
--wireless_hashes = {}
new_data = {}
positions = { "0", "22.5", "45", "67.5", "90", "112.5", "135", "157.5","180", "202.5","225", "247.5","270", "292.5", "315" ,"337.5" }
--positions = { "0", "22.5" }
num_test_by_position = 5
wlandevice = "wlan0"

print ("Content-type: text/html")
print ("")
print("<html><body><pre>")
for i, position in ipairs(positions) do
	print ("Analitzar " .. position .. " Graus.")
	print ("Wait few seconds.")
	wait_led()
	led_off(led1)
	led_off(led2)
	led_on(led3)
	led_on(led4)
	print ("Start...")
	data[i] = {}
	for n = 1, num_test_by_position do
		comando = "iwinfo " .. wlandevice .. " scan|awk -vRS=\"\" -vOFS=',' '$1=$1'"
		arr = run_array(comando)
		for o,line in pairs(arr) do
			string.gsub(line,"Cell,%d+,.-,Address:,(.-),ESSID:,\"(.-)\",Mode:,(.-),Channel:,(.-),Signal:,(.-),dBm,Quality:,(%d+)/(%d+),Encryption:,(.+)",
			function(address, essid, mode, channel, signal, quality, max_qualiti, encryption)
				key = run('echo "'..address .. essid..'"|md5sum|cut -d " " -f 1')
				if ( data[i][key] ~= nil ) then
					c = data[i][key].counter+1
					new_quality = ((data[i][key].quality * (c-1)) + quality) / c 
					data[i][key].quality = new_quality
					data[i][key].counter = c  
				else 
					data[i][key] = { address = address, essid = essid, mode = mode, channel = channel, quality = quality, counter = 1}

				end
			end)
		end
	end
	led_off(led3)
	led_off(led4)
end
for k,v in pairs(data) do
	for j,c in pairs(v) do
		if (new_data[j] ~= nil) then
			new_data[j]['quality'][k] = c.quality
		else
			q = {}
			for i, p in ipairs(positions) do
				q[i] = 0
			end
			new_data[j] = { quality = q, address = c.address, essid = c.essid, mode = c.mode, channel = c.channel }
			new_data[j]['quality'][k] = c.quality
		end
	end
end

local strfile = "var	datasets=[\n";
for k,v in pairs(new_data) do
	strfile = strfile .. "{\n"
	strfile = strfile .. "label: \""..v.address.." "..v.essid.."(Ch."..v.channel..")\",\n"
	strfile = strfile .. "data: ["..implode(",",v.quality).."]"
	strfile = strfile .. "},\n"
end
strfile = strfile .. "]\n"

-- Save file
assert(io.open(file, 'w')):write(strfile)

print("</pre>")
print("<a href='/heme/index.html'>view analysis</a>"); 
print("</body></html>") 