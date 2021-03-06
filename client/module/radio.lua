RegisterNetEvent('pma-voice:syncRadioData')
AddEventHandler('pma-voice:syncRadioData', function(radioTable)
    radioData = radioTable
    for tgt, enabled in pairs(radioTable) do
        if tgt ~= playerServerId then
            toggleVoice(tgt, enabled)
            playerTargets(radioData, callData)
        end
    end
end)

RegisterNetEvent('pma-voice:setTalkingOnRadio')
AddEventHandler('pma-voice:setTalkingOnRadio', function(tgt, enabled)
    if tgt ~= playerServerId then
        toggleVoice(tgt, enabled)
        radioData[tgt] = enabled
        playerTargets(radioData, callData)
        playMicClicks(voiceData.radio, enabled)
    end
end)

RegisterNetEvent('pma-voice:addPlayerToRadio')
AddEventHandler('pma-voice:addPlayerToRadio', function(plySource)
    radioData[plySource] = false
    playerTargets(radioData, callData)
end)

RegisterNetEvent('pma-voice:removePlayerFromRadio')
AddEventHandler('pma-voice:removePlayerFromRadio', function(plySource)
    if plySource == playerServerId then 
        radioData = {}
        playerTargets(radioData, callData)
    else
        radioData[plySource] = nil
        playerTargets(radioData, callData)
    end
end)

function setRadioChannel(channel)
    TriggerServerEvent('pma-voice:setPlayerRadio', channel)
    voiceData.radio = channel
end
exports('setRadioChannel', setRadioChannel)
exports('removePlayerFromRadio', function()
    setRadioChannel(0)
end)
exports('addPlayerToRadio', function(radio)
    local radio = tonumber(radio)
    if radio then
        setRadioChannel(radio)
    end
end)

RegisterCommand('+radiotalk', function()
    if exports["esx_ambulancejob"]:isPlayerDead() then return false end

    if not Cfg.radioPressed and Cfg.radioEnabled then
        if voiceData.radio > 0 then
            TriggerServerEvent('pma-voice:setTalkingOnRadio', true)
            Cfg.radioPressed = true
            playMicClicks(voiceData.radio, true)
            Citizen.CreateThread(function()
                TriggerEvent("pma-voice:radioActive", true)
                while Cfg.radioPressed do
                    Citizen.Wait(0)
                    SetControlNormal(0, 249, 1.0)
                    SetControlNormal(1, 249, 1.0)
                    SetControlNormal(2, 249, 1.0)
                end
            end)
        end
    end
end, false)

RegisterCommand('-radiotalk', function()
    if voiceData.radio > 0 or Cfg.radioEnabled then
        Cfg.radioPressed = false
        TriggerEvent("pma-voice:radioActive", false)
        playMicClicks(voiceData.radio, false)
        TriggerServerEvent('pma-voice:setTalkingOnRadio', false)
    end
end, false)
RegisterKeyMapping('+radiotalk', 'Talk over Radio', 'keyboard', 'LMENU')
