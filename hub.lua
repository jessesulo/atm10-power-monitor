local monitor
local monitorX, monitorY

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

local startLine = 4

local nodeLength = 0
local oldLength = 0

function monitorInit()
    monitor = peripheral.find("monitor")
    monitorX, monitorY = monitor.getSize()

    monitor.clear()
    monitor.setTextScale(1)
    monitor.setTextColor(colors.red)
    monitor.setBackgroundColor(colors.cyan)
end

function clearMonitor()
    for i = 1, 25 do
        monitor.setCursorPos(1, i)
        monitor.write("                             ")
    end
end

function updateDisplay(nodes)
    monitor.setCursorPos(1, 2)
    monitor.write("        Energy Monitor        ")
    monitor.setCursorPos(1, 3)
    monitor.write("-----------------------------")

    nodeLength = 0
    for name, energy in pairs(nodes) do
        nodeLength = nodeLength + 1
    end
    oldLength = nodeLength

    if(nodeLength > oldLength) then
        clearMonitor()
    end

    if length == 0 then
        monitor.setCursorPos(1, startLine+1)
        monitor.write("        No nodes found")
        return
    else
        monitor.setCursorPos(1, startLine+1)
        monitor.write("                             ")
    end

    local lineCount = startLine
    for name, energy in pairs(nodes) do
        monitor.setCursorPos(1, lineCount)

        energy = energy:match("^[^.]*")
        energy = energy:reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()

        monitor.write(" " .. name .. ": " .. energy .. " FE/t                       ")

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
    
    monitor.setCursorPos(1, screenY - 5)
    monitor.write("-----------------------------")
    
    monitor.setCursorPos(1, screenY - 4)
    monitor.write(" Total Input: " .. footer.input .. " FE/t              ")
    
    monitor.setCursorPos(1, screenY - 3)
    monitor.write(" Total Output: " .. footer.output .. " FE/t             ")
    
    monitor.setCursorPos(1, screenY - 2)
    monitor.write(" Total Stored: " .. footer.stored .. " FE/t             ")

    monitor.setCursorPos(1, screenY - 1)
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
            fullness = message.fullness
        }

        updateFooter(nodes, footer)
    else
        nodes[message.name] = message.energy
        updateDisplay(nodes)
    end
end
