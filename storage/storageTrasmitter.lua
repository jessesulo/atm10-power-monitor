print("Enter the side of the energy cell: ")
local amountPer = tonumber(io.read("*l"))

rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

term.clear()
term.setCursorPos(1, 1)

print("Transmitting storage data from the controller...")

local inv = peripheral.find("inventory")
local invSize = inv.size()

while true do
    local listPayload = {}
    for i = 1, invSize do
        local item = inv.getItemDetail(i)

        if item ~= null then
            listPayload.insert({
                name = item.displayName,
                count = item.count
            })
        end
    end
    rednet.broadcast(itemPayload, "storageTransmission")

    sleep(5)
end
