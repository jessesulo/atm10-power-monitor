local monitor = peripheral.find("monitor")
local monitorX, monitorY = monitor.getSize()

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

local startLine = 4
local offset = monitorY-4

function monitorInit()
    monitor.clear()
    monitor.setTextScale(1)
    monitor.setTextColor(colors.black)
    monitor.setBackgroundColor(colors.yellow)
    clearMonitor()
end

function clearMonitor()
    for i = 1, monitorY do
        for j = 1, monitorX do
            monitor.setCursorPos(j, i)
            monitor.write(" ")
        end
    end
end

function drawLine(y)
    for i = 1, monitorX do
        monitor.setCursorPos(i, y)
        monitor.write("-")
    end
end

function centerText(text, y)
    local x = math.ceil((monitorX - string.len(text)) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

function parseNumber(number)
    local formatted = number
    number = tonumber(number)

    if number > 1000000000000000 then
        formatted = string.format("%.2f", number / 1000000000000) .. "G"
    elseif number > 1000000000000 then
        formatted = string.format("%.2f", number / 1000000000000) .. "T"
    elseif number > 1000000000 then
        formatted = string.format("%.2f", number / 1000000000) .. "B"
    elseif number > 1000000 then
        formatted = string.format("%.2f", number / 1000000) .. "M"
    elseif number > 1000 then
        formatted = string.format("%.2f", number / 1000) .. "K"
    end
    
    return formatted
end

function updateDisplay(nodes, start, endL)
    clearMonitor()
    monitor.setCursorPos(1, 2)
    centerText("Storage Monitor", 2)

    local pageNumber = start / offset
    local xoffset = monitorX - (string.len(tostring(pageNumber)) + string.len(tostring(#nodes/offset)) + 6)
    monitor.setCursorPos(xoffset, 2)
    monitor.write("Page " .. math.ceil(pageNumber) .. "/" .. math.ceil(#nodes/offset))

    drawLine(3)

    if #nodes == 0 then
        centerText("No items found", startLine+1)
        return
    else
        monitor.setCursorPos(1, startLine+1)
        monitor.write("                             ")
    end

    local lineTrack = startLine
    for i=start,endL do
        if(nodes[i] == nil) then
            break
        end
        
        local countString = parseNumber(nodes[i].count)
        local outString = i .. ". " .. nodes[i].name .. " - " .. countString
        monitor.setCursorPos(1, lineTrack)
        monitor.write(outString)
        
        local differenceStr = ""
        if nodes[i].difference > 0 then
            monitor.setTextColor(colors.green)
            differenceStr = "+"
        elseif nodes[i].difference < 0 then
            monitor.setTextColor(colors.red)
        end

        monitor.setCursorPos(string.len(outString) + 2, lineTrack)
        monitor.write("(" .. differenceStr .. parseNumber(nodes[i].difference) .. ")")

        monitor.setTextColor(colors.black)

        lineTrack = lineTrack + 1
    end
end

local nodes = {}

monitorInit()
updateDisplay(nodes, 1, offset)

while true do
    local id, message = rednet.receive("storageTransmission")

    table.sort(message, function(a, b) return a.count > b.count end)

    local cursor = 1
    while cursor < #message do
        updateDisplay(message, cursor, cursor + offset - 1)
        cursor = cursor + offset
        sleep(7)
    end
end
