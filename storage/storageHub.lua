local monitor = peripheral.find("monitor")
local monitorX, monitorY = monitor.getSize()

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

local startLine = 4

local nodeLength = 0
local oldLength = 0

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
    local x = math.floor((monitorX - string.len(text)) / 2)
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

function updateDisplay(nodes, start, endL)
    monitor.setCursorPos(1, 2)
    centerText("Storage Monitor", 2)
    drawLine(3)

    if #nodes == 0 then
        centerText("No items found", startLine+1)
        return
    else
        monitor.setCursorPos(1, startLine+1)
        monitor.write("                             ")
    end

    for i=start,endL do
        monitor.setCursorPos(1, startLine+1)
        monitor.write(i .. ". " .. nodes[i].name)
        monitor.setCursorPos(monitorX-#nodes[i].count, startLine+1)
        monitor.write(nodes[i].count)
    end
end

local nodes = {}

monitorInit()


local offset = monitorY-4
updateDisplay(nodes, 1, offset)

while true do
    local id, message = rednet.receive("storageTransmission")

    for i = 1,#message do
        nodes[message[i].name] = message[i].count
    end

    table.sort(nodes, function(a, b) return a.count < b.count end)

    local cursor = 1

    while cursor < #nodes do
        updateDisplay(nodes, cursor, offset)
        cursor = cursor + offset
        sleep(5)
    end
end
