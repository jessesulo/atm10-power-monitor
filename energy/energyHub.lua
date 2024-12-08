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
    monitor.setTextColor(colors.white)
    monitor.setBackgroundColor(colors.blue)
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

function updateDisplay(nodes)
    monitor.setCursorPos(1, 2)
    centerText("Energy Monitor", 2)
    drawLine(3)

    nodeLength = 0
    for name, energy in pairs(nodes) do
        nodeLength = nodeLength + 1
    end
    oldLength = nodeLength

    if(nodeLength > oldLength) then
        clearMonitor()
    end

    if length == 0 then
        centerText("No nodes found", startLine+1)
        return
    else
        monitor.setCursorPos(1, startLine+1)
        monitor.write("                             ")
    end

    local lineCount = startLine
    for name, energy in pairs(nodes) do
        monitor.setCursorPos(1, lineCount)

        energy = parseNumber(energy)

        monitor.write(" " .. name .. ": " .. energy .. "                        ")

        lineCount = lineCount + 1
    end
end

function updateFooter(nodes, footer)
    updateDisplay(nodes)
    
    footer.input = footer.input:match("^[^.]*")
    footer.input = footer.input:reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()
    
    footer.output = footer.output:match("^[^.]*")
    footer.output = footer.output:reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()

    footer.stored = footer.stored:match("^[^.]*")
    footer.stored = footer.stored:reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()
    
    centerText("Energy Overview", monitorY - 6)
    
    monitor.setCursorPos(1, monitorY - 5)
    drawLine(monitorY - 5)
    
    monitor.setCursorPos(1, monitorY - 4)
    monitor.write(" Total Input: " .. footer.input .. " FE/t              ")
    
    monitor.setCursorPos(1, monitorY - 3)
    monitor.write(" Total Output: " .. footer.output .. " FE/t             ")
    
    monitor.setCursorPos(1, monitorY - 2)
    monitor.write(" Total Stored: " .. footer.stored .. " FE/t             ")

    monitor.setCursorPos(1, monitorY - 1)
    local capacity = string.format("%.2f", footer.capacity * 100)
    monitor.write(" Remaining Capacity: " .. capacity .. "%           ")
end

local nodes = {}

monitorInit()
updateDisplay(nodes)

while true do
    local id, message = rednet.receive("energyTransmission")

    if message.name == "Induction Matrix" then
        local footer = {
            input = message.input,
            output = message.output,
            stored = message.stored,
            capacity = message.capacity
        }

        updateFooter(nodes, footer)
    else
        nodes[message.name] = message.energy
        updateDisplay(nodes)
    end
end
