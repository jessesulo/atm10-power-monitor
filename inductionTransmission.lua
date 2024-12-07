local name = "Induction Matrix"

print("Enter the side of the energy cell: ")
local cell = io.read("*l")

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

term.clear()

print("Transmitting energy data...")

local totalEnergy = 0
local count = 1

while true do
    local input = peripheral.call(cell, "getLastInput")
    local output = peripheral.call(cell, "getLastOutput")
    local fullness = peripheral.call(cell, "getEnergyFilledPercentage")

    local payload = {
        name = name,
        input = tostring(input),
        output = tostring(output),
        fullness = tostring(fullness)
    }

    print("Transmitting data:")
    print(textutils.serialize(payload))

    rednet.broadcast(payload, "energyTransmission")

    sleep(0)
end
