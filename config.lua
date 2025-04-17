Config = {}

-- Command settings
Config.Command = 'vehmenu' -- Command to open the vehicle menu

-- Vehicle control settings
Config.DoorControls = {
    left_door = 0,
    right_door = 1,
    rear_left_door = 2,
    rear_right_door = 3
}

Config.WindowControls = {
    left_window = 0,
    right_window = 1,
    rear_left_window = 2,
    rear_right_window = 3
}

Config.SeatControls = {
    driver_seat = -1,
    passenger_seat = 0,
    rear_left_seat = 1,
    rear_right_seat = 2,
    rear_middle_seat = 3,
    rear_extra_seat = 4
}

Config.SeatSwitchCooldown = 2 -- Cooldown in seconds between seat switches

Config.OtherControls = {
    trunk = 5,
    hood = 4
}

-- Engine start settings
Config.EngineStartDelay = 2 -- Delay in seconds before engine starts
Config.EngineStartSound = true -- Play engine start sound

-- Radio settings
Config.RadioCommand = 'carradio' -- Command to toggle radio

-- Key settings
Config.KeyCommand = 'givekeys' -- Command to give keys to another player
Config.KeyDistance = 5.0 -- Maximum distance to give keys to another player

-- Notification settings
Config.Notifications = {
    engineStarted = 'Engine started successfully',
    engineFailed = 'Failed to start engine',
    radioOn = 'Radio turned on',
    radioOff = 'Radio turned off',
    keysGiven = 'Keys given to player',
    keysReceived = 'You received vehicle keys',
    seatOccupied = 'This seat is occupied!',
    seatCooldown = 'Please wait before switching seats again'
} 