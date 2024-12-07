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
    local induction_matrix = peripheral.find('inductionPort')

    local input = induction_matrix.getLastInput()
    local output = induction_matrix.getLastOutput()
    local fullness = induction_matrix.getEnergyFilledPercentage()

    local payload = {
        name = name,
        input = tostring(input),
        output = tostring(output),
        fullness = tostring(fullness)
    }

    rednet.broadcast(payload, "energyTransmission")

    sleep(0)
end
