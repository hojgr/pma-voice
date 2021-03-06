function removePlayerFromCall(source, currentChannel)
    callData[currentChannel] = callData[currentChannel] or {}
    for player, _ in pairs(callData[currentChannel]) do
        TriggerClientEvent('pma-voice:removePlayerFromCall', player, source)
    end
    callData[currentChannel][source] = nil
    voiceData[source].call = 0
end

function addPlayerToCall(source, channel)
    -- check if the channel exists, if it does set the varaible to it
    -- if not create it (basically if not callData make callData)
    callData[channel] = callData[channel] or {}
    callData[channel][source] = false
    voiceData[source].call = channel
    for player, _ in pairs(callData[channel]) do
        TriggerClientEvent('pma-voice:addPlayerToCall', player, source)
    end
    TriggerClientEvent('pma-voice:syncCallData', source, callData[channel])
end

function setPlayerCall(source, callChannel)
    local plyVoice = voiceData[source]
    local callChannel = tonumber(callChannel)

    if callChannel ~= 0 and plyVoice.call == 0 then
        addPlayerToCall(source, callChannel)
    elseif callChannel == 0 then
        removePlayerFromCall(source, plyVoice.call)
    elseif plyVoice.call > 0 then
        removePlayerFromCall(source, plyVoice.call)
        addPlayerToCall(source, callChannel)
    end
end
exports('setPlayerCall', setPlayerCall)

RegisterNetEvent('pma-voice:setPlayerCall')
AddEventHandler('pma-voice:setPlayerCall', function(callChannel)
    setPlayerCall(source, callChannel)
end)

RegisterNetEvent('pma-voice:setTalkingOnCall')
AddEventHandler('pma-voice:setTalkingOnCall', function(talking)
    local plyVoice = voiceData[source]
    local callTbl = callData[plyVoice.call]
    if callTbl then
        for player, _ in pairs(callTbl) do
            if source ~= player then
                TriggerClientEvent('pma-voice:setTalkingOnCall', player, source, talking)
            end
        end
    end
end)