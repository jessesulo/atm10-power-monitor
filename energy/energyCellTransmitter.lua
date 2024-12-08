print("Enter the name of the energy cell: ")
local name = io.read("*l")

print("Enter the side of the energy cell: ")
local cell = io.read("*l")

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

term.clear()
term.setCursorPos(1, 1)

print("Transmitting energy data from " .. name .. "...")

local totalEnergy = 0
local count = 1

while true do
    local energy = peripheral.call(cell, "getEnergy")

    if count == 10 then
        local payload = {
            name = name,
            energy = totalEnergy/10
        }

        print("Transmitting data:")

        rednet.broadcast(payload, "energyTransmission")
        count = 0
        totalEnergy = 0
    else
        totalEnergy = math.abs(energy) + totalEnergy
        count = count + 1
    end

    sleep(0)
end
