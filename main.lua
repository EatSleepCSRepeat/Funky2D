local notes = {
    {time = 9, type = "left"},
    {time = 10.2, type = "right"},
    {time = 11.4, type = "left"},
    {time = 12.6, type = "right"},
    {time = 13.8, type = "left"},
    {time = 15, type = "right"},
    {time = 16.2, type = "left"},
    {time = 17.4, type = "right"},
    {time = 18.6, type = "up"},
    {time = 19.8, type = "down"},
    {time = 21, type = "up"},
    {time = 22.2, type = "down"},
    {time = 23.4, type = "up"},
    {time = 24.6, type = "down"},
    {time = 25.8, type = "up"},
    {time = 27, type = "down"},
    {time = 28.2, type = "left"},
    {time = 29.4, type = "up"},
    {time = 30.6, type = "down"},
    {time = 31.8, type = "right"},
    {time = 33, type = "left"},
    {time = 34.2, type = "up"},
    {time = 35.4, type = "down"},
    {time = 36.6, type = "right"},
    {time = 37.8, type = "down"},
    {time = 38.4, type = "down"},
    {time = 39, type = "up"},
    {time = 40.1, type = "down"},
    {time = 40.7, type = "down"},
    {time = 41.5, type = "right"},
    {time = 42.6, type = "down"},
    {time = 43.2, type = "down"},
    {time = 43.85, type = "up"},
    {time = 44.95, type = "down"},
    {time = 45.4, type = "down"},
    {time = 45.9, type = "right"},
}

local noteSpeed = 600
local spawnedNotes = {}
local score = 0
local highscore = 0
local currentNoteIndex = 1

-- Colors for the notes
local noteColors = {
    left = {1, 0, 1},    -- Magenta (D)
    down = {0, 1, 1},    -- Cyan (F)
    up = {0, 1, 0},      -- Green (J)
    right = {1, 0, 0}    -- Red (K)
}

-- Hitbox positions for DFJK (left, down, up, right mapped to D, F, J, K)
local hitBoxes = {
    {key = "left", x = 200, y = 450, width = 50, height = 50},
    {key = "down", x = 300, y = 450, width = 50, height = 50},
    {key = "up", x = 400, y = 450, width = 50, height = 50},
    {key = "right", x = 500, y = 450, width = 50, height = 50}
}

-- Key mapping: DFJK to left, down, up, right
local keyMap = {
    d = "left",
    f = "down",
    j = "up",
    k = "right"
}

-- Hold states for DFJK keys
local keyHeld = {d = false, f = false, j = false, k = false}

-- Song length and timers
local songDuration = 67 -- Song length in seconds
local songTime = 0
local songEnded = false
local timeSinceSongEnd = 0

-- Background image
local backgroundImage
local customMousePointer

function love.load()
    
    -- Set window dimensions
    love.window.setMode(800, 600)

    -- Load background image
    backgroundImage = love.graphics.newImage("background.png")

    -- Load custom mouse pointer image
    customMousePointer = love.graphics.newImage("cursor.png")

    -- Debugging output
    if customMousePointer then
        print("Cursor image loaded successfully!")
    else
        print("Failed to load cursor image.")
    end

    -- Load highscore from file (if exists)
    highscore = loadHighScore()

    -- Set the mouse cursor to invisible
    love.mouse.setVisible(false)

    song = love.audio.newSource("song.mp3", "stream") -- Use "static" for shorter sounds
    song:setVolume(0.5) -- Set the volume (0 to 1)
    song:play() -- Play the song
end


-- Function to spawn notes based on time
function spawnNoteAtTime()
    if currentNoteIndex <= #notes then
        local nextNote = notes[currentNoteIndex]
        if songTime >= nextNote.time then
            local xPosition = 0

            if nextNote.type == "left" then
                xPosition = 200
            elseif nextNote.type == "down" then
                xPosition = 300
            elseif nextNote.type == "up" then
                xPosition = 400
            elseif nextNote.type == "right" then
                xPosition = 500
            end

            -- Add the note to the spawnedNotes table
            table.insert(spawnedNotes, {x = xPosition, y = 0, type = nextNote.type})
            currentNoteIndex = currentNoteIndex + 1
        end
    end
end

-- Check if the player hit the correct note
function checkNoteHit(note, key)
    if key == note.type then
        return math.abs(note.y - 450) < 50 -- Check if note is within the hitbox (450 is the hit zone)
    end
    return false
end

function love.update(dt)
    if not songEnded then
        -- Update song time
        songTime = songTime + dt

        -- Spawn notes based on their specific time
        spawnNoteAtTime()

        -- Update note positions
        for i = #spawnedNotes, 1, -1 do
            local note = spawnedNotes[i]
            note.y = note.y + noteSpeed * dt

            -- Remove notes that have gone off screen
            if note.y > love.graphics.getHeight() then
                table.remove(spawnedNotes, i)
            end
        end

        -- Check if the song has ended
        if songTime >= songDuration then
            songEnded = true
            timeSinceSongEnd = 0
        end
    else
        -- Once the song ends, stop updating further notes
        timeSinceSongEnd = timeSinceSongEnd + dt

        -- Remove any remaining notes on the screen
        if #spawnedNotes > 0 then
            spawnedNotes = {}
        end

        -- After 3.5 seconds, save highscore and close
        if timeSinceSongEnd >= 1 then
            if score > highscore then
                saveHighScore(score)
            end
            love.event.quit() -- Close the game window
        end
    end
end

function love.draw()
    -- Draw the background image
    love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())

    -- Draw the hitboxes
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color
    for _, hitBox in ipairs(hitBoxes) do
        love.graphics.rectangle("fill", hitBox.x, hitBox.y, hitBox.width, hitBox.height)
    end

    -- Draw the notes
    for _, note in ipairs(spawnedNotes) do
        local color = noteColors[note.type]

        -- Apply glow effect if holding the corresponding key
        if keyHeld[keyMap[note.type]] then
            love.graphics.setColor(color[1], color[2], color[3], 1) -- Full brightness
            -- Draw glow as a border
            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", note.x, note.y, 50, 50)
        else
            love.graphics.setColor(color[1], color[2], color[3], 0.7) -- Normal color
        end

        love.graphics.rectangle("fill", note.x, note.y, 50, 50)
    end

    -- Draw the score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Highscore: " .. highscore, 10, 30)

    -- Draw custom mouse pointer with scaling
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.draw(customMousePointer, mouseX, mouseY, 0, 16 / 512, 16 / 512) -- Scale to 16x16
end


-- Key press handler
function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- Close the game window
    elseif keyMap[key] then
        keyHeld[key] = true
        for i = #spawnedNotes, 1, -1 do
            local note = spawnedNotes[i]
            if checkNoteHit(note, keyMap[key]) then
                table.remove(spawnedNotes, i)
                score = score + 1 -- Increment score on hit
                break
            end
        end
    end
end

-- Key release handler
function love.keyreleased(key)
    if keyMap[key] then
        keyHeld[key] = false
    end
end

-- Highscore loading/saving functions
function loadHighScore()
    local file = io.open("score.txt", "r")
    if file then
        local savedScore = tonumber(file:read("*all"))
        file:close()
        return savedScore or 0
    end
    return 0
end

function saveHighScore(newScore)
    local file = io.open("score.txt", "w")
    file:write(tostring(newScore))
    file:close()
end
