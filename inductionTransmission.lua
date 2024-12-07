local name = "Induction Matrix"

print("Enter the side of the energy cell: ")
local cell = io.read("*l")

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

term.clear()
term.setCursorPos(1, 1)

print("Transmitting energy data from the induction matrix...")

local totalEnergy = 0
local count = 1

local mysteryMultiple = 2.5 -- This is a mystery number that is used to convert the energy values to the correct format. Gotten from the (displayed energy / real energy)

while true do
    local induction_matrix = peripheral.find('inductionPort')

    local input = induction_matrix.getLastInput()
    local output = induction_matrix.getLastOutput()
    local capacity = induction_matrix.getEnergyFilledPercentage()
    local stored = induction_matrix.getEnergy()

    local payload = {
        name = name,
        input = tostring(input / mysteryMultiple),
        output = tostring(output / mysteryMultiple),
        capacity = tostring(1 - capacity / mysteryMultiple)
        stored = tostring(stored / mysteryMultiple)
    }

    rednet.broadcast(payload, "energyTransmission")

    sleep(0)
end
