rednet.open("right")
rednet.CHANNEL_BROADCAST = 1414

term.clear()
term.setCursorPos(1, 1)

print("Transmitting storage data from the controller...")

local inv = peripheral.find("inventory")
local invSize = inv.size()

local lastPayload = {}

while true do
    local itemPayload = {}
    for i = 1, invSize do
        local item = inv.getItemDetail(i)

        if item ~= null then

            local difference = 0
            if(lastPayload[item.displayName] ~= nil) then
                difference = item.count - lastPayload[item.displayName]
            end
            lastPayload[item.displayName] = item.count

            table.insert(itemPayload,{
                name = item.displayName,
                count = item.count,
                difference = difference,
            })
        end
    end
    rednet.broadcast(itemPayload, "storageTransmission")
    sleep(1)
end
