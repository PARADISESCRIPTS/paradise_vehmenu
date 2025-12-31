local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

local function isPlayerInVehicle()
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  return vehicle and vehicle ~= 0
end

local lastSeatSwitch = 0
local isOnCooldown = false

local function handleVehicleDoor(controlId, state)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if not vehicle or vehicle == 0 then return end

  local doorIndex = Config.DoorControls[controlId]
  if doorIndex then
    if state then
      SetVehicleDoorOpen(vehicle, doorIndex, false, false)
    else
      SetVehicleDoorShut(vehicle, doorIndex, false)
    end
  end
end

local function handleVehicleWindow(controlId, state)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if not vehicle or vehicle == 0 then return end

  local windowIndex = Config.WindowControls[controlId]
  if windowIndex then
    if state then
      RollDownWindow(vehicle, windowIndex)
    else
      RollUpWindow(vehicle, windowIndex)
    end
  end
end

local function handleVehicleSeat(controlId)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if not vehicle or vehicle == 0 then return end

  local currentTime = GetGameTimer()
  if isOnCooldown and (currentTime - lastSeatSwitch) < (Config.SeatSwitchCooldown * 1000) then
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.seatCooldown,
      type = 'error'
    })
    return
  end

  local seatIndex = Config.SeatControls[controlId]
  if seatIndex then
    local isSeatOccupied = IsVehicleSeatFree(vehicle, seatIndex)
    if isSeatOccupied then
      TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
      lastSeatSwitch = currentTime
      isOnCooldown = true
      SetTimeout(Config.SeatSwitchCooldown * 1000, function()
        isOnCooldown = false
      end)
      SendReactMessage('seatChanged', {
        newSeat = controlId,
        oldSeat = GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and 'driver_seat' or
                 GetPedInVehicleSeat(vehicle, 0) == PlayerPedId() and 'passenger_seat' or
                 GetPedInVehicleSeat(vehicle, 1) == PlayerPedId() and 'rear_left_seat' or
                 GetPedInVehicleSeat(vehicle, 2) == PlayerPedId() and 'rear_right_seat' or
                 GetPedInVehicleSeat(vehicle, 3) == PlayerPedId() and 'rear_middle_seat' or
                 GetPedInVehicleSeat(vehicle, 4) == PlayerPedId() and 'rear_extra_seat' or nil
      })
    else
      lib.notify({
        title = 'Vehicle',
        description = Config.Notifications.seatOccupied,
        type = 'error'
      })
    end
  end
end

local function handleEngineControl(state)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if not vehicle or vehicle == 0 then return end

  if state then
    -- Check if engine can start (simple health-based check)
    local vehicleHealth = GetVehicleEngineHealth(vehicle)
    local failureChance = 0
    
    -- Calculate failure chance based on vehicle health (0-1000 scale)
    if vehicleHealth < 300 then
      failureChance = math.min(50, (300 - vehicleHealth) / 300 * 50) -- Max 50% failure chance
    end
    
    -- Random chance for engine failure
    if math.random(100) <= failureChance then
      lib.notify({
        title = 'Vehicle',
        description = Config.Notifications.engineFailed,
        type = 'error'
      })
      return
    end
    
    SetVehicleEngineOn(vehicle, true, true, true)
    if Config.EngineStartSound then
      PlaySoundFrontend(-1, "Remote_Control_Fob", "PI_Menu_Sounds", true)
    end
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.engineStarted,
      type = 'success'
    })
  else
    SetVehicleEngineOn(vehicle, false, true, true)
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.engineTurnedOff,
      type = 'inform'
    })
  end
end

local function handleVehicleOther(controlId, state)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if not vehicle or vehicle == 0 then return end

  if controlId == "trunk" then
    local trunkIndex = Config.OtherControls.trunk
    if state then
      SetVehicleDoorOpen(vehicle, trunkIndex, false, true)
      SetVehicleDoorOpen(vehicle, trunkIndex, false, true)
    else
      SetVehicleDoorShut(vehicle, trunkIndex, false)
      SetVehicleDoorShut(vehicle, trunkIndex, false)
    end
  elseif controlId == "hood" then
    local hoodIndex = Config.OtherControls.hood
    if state then
      SetVehicleDoorOpen(vehicle, hoodIndex, false, true)
      SetVehicleDoorOpen(vehicle, hoodIndex, false, true)
    else
      SetVehicleDoorShut(vehicle, hoodIndex, false)
      SetVehicleDoorShut(vehicle, hoodIndex, false)
    end
  elseif controlId == "music" then
    if state then
      SetVehicleRadioEnabled(vehicle, true)
      lib.notify({
        title = 'Vehicle',
        description = Config.Notifications.radioOn,
        type = 'success'
      })
    else
      SetVehicleRadioEnabled(vehicle, false)
      lib.notify({
        title = 'Vehicle',
        description = Config.Notifications.radioOff,
        type = 'inform'
      })
    end
  elseif controlId == "keys" then
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local players = GetActivePlayers()
    
    for _, player in ipairs(players) do
      local targetPed = GetPlayerPed(player)
      if targetPed ~= playerPed then
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.KeyDistance then
          local vehicle = GetVehiclePedIsIn(playerPed, false)
          if vehicle and vehicle ~= 0 then
            SetVehicleDoorsLocked(vehicle, 1)
            lib.notify({
              title = 'Vehicle',
              description = Config.Notifications.keysGiven,
              type = 'success'
            })
            break
          end
        end
      end
    end
  elseif controlId == "engine" then
    handleEngineControl(state)
  end
end

local function getVehicleSeatingCapacity(vehicle)
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    return maxSeats + 1
end

RegisterCommand(Config.Command, function()
  if not isPlayerInVehicle() then
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.notInVehicle,
      type = 'error'
    })
    return
  end
  toggleNuiFrame(true)
  debugPrint('Show NUI frame')
end)

RegisterCommand(Config.RadioCommand, function()
  if not isPlayerInVehicle() then
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.notInVehicle,
      type = 'error'
    })
    return
  end
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if vehicle and vehicle ~= 0 then
    local isRadioEnabled = IsVehicleRadioEnabled(vehicle)
    SetVehicleRadioEnabled(vehicle, not isRadioEnabled)
    lib.notify({
      title = 'Vehicle',
      description = isRadioEnabled and Config.Notifications.radioOff or Config.Notifications.radioOn,
      type = isRadioEnabled and 'inform' or 'success'
    })
  end
end)

RegisterCommand(Config.KeyCommand, function()
  if not isPlayerInVehicle() then
    lib.notify({
      title = 'Vehicle',
      description = Config.Notifications.notInVehicle,
      type = 'error'
    })
    return
  end
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  local players = GetActivePlayers()
  
  for _, player in ipairs(players) do
    local targetPed = GetPlayerPed(player)
    if targetPed ~= playerPed then
      local targetCoords = GetEntityCoords(targetPed)
      local distance = #(coords - targetCoords)
      
      if distance <= Config.KeyDistance then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle and vehicle ~= 0 then
          SetVehicleDoorsLocked(vehicle, 1)
          lib.notify({
            title = 'Vehicle',
            description = Config.Notifications.keysGiven,
            type = 'success'
          })
          break
        end
      end
    end
  end
end)

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  debugPrint('Hide NUI frame')
  cb({})
end)

RegisterNUICallback('vehicleControl', function(data, cb)
  debugPrint('Vehicle control request:', json.encode(data))
  
  if data.controlId and data.state ~= nil then
    if string.find(data.controlId, "door") then
      handleVehicleDoor(data.controlId, data.state)
    elseif string.find(data.controlId, "window") then
      handleVehicleWindow(data.controlId, data.state)
    elseif string.find(data.controlId, "seat") then
      handleVehicleSeat(data.controlId)
    else
      handleVehicleOther(data.controlId, data.state)
    end
  end
  
  cb({ success = true })
end)

RegisterNUICallback('getClientData', function(data, cb)
  debugPrint('Data sent by React', json.encode(data))

  local curCoords = GetEntityCoords(PlayerPedId())
  local retData = { x = curCoords.x, y = curCoords.y, z = curCoords.z }
  cb(retData)
end)

RegisterNUICallback('getVehicleInfo', function(_, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or vehicle == 0 then
        cb({ success = false })
        return
    end

    local seatingCapacity = getVehicleSeatingCapacity(vehicle)
    cb({ 
        success = true,
        seatingCapacity = seatingCapacity
    })
end)

RegisterKeyMapping(Config.Command, 'Open Vehicle Menu', 'keyboard', Config.Keybind)
