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

local noteColors = {
    left = {1, 0, 1},    
    down = {0, 1, 1},   
    up = {0, 1, 0},      
    right = {1, 0, 0}    
}

local hitBoxes = {
    {key = "left", x = 200, y = 450, width = 50, height = 50},
    {key = "down", x = 300, y = 450, width = 50, height = 50},
    {key = "up", x = 400, y = 450, width = 50, height = 50},
    {key = "right", x = 500, y = 450, width = 50, height = 50}
}

local keyMap = {
    d = "left",
    f = "down",
    j = "up",
    k = "right"
}

local keyHeld = {d = false, f = false, j = false, k = false}

local songDuration = 67
local songTime = 0
local songEnded = false
local timeSinceSongEnd = 0

local backgroundImage
local customMousePointer

function love.load()
    
    love.window.setMode(800, 600)

    backgroundImage = love.graphics.newImage("background.png")

    customMousePointer = love.graphics.newImage("cursor.png")

    if customMousePointer then
        print("Cursor image loaded successfully!")
    else
        print("Failed to load cursor image.")
    end

    highscore = loadHighScore()

    love.mouse.setVisible(false)

    song = love.audio.newSource("song.mp3", "stream") 
    song:setVolume(0.5))
    song:play()
end


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

            table.insert(spawnedNotes, {x = xPosition, y = 0, type = nextNote.type})
            currentNoteIndex = currentNoteIndex + 1
        end
    end
end

function checkNoteHit(note, key)
    if key == note.type then
        return math.abs(note.y - 450) < 50 -
    end
    return false
end

function love.update(dt)
    if not songEnded then
        songTime = songTime + dt

        spawnNoteAtTime()

        for i = #spawnedNotes, 1, -1 do
            local note = spawnedNotes[i]
            note.y = note.y + noteSpeed * dt

            if note.y > love.graphics.getHeight() then
                table.remove(spawnedNotes, i)
            end
        end

        if songTime >= songDuration then
            songEnded = true
            timeSinceSongEnd = 0
        end
    else
        timeSinceSongEnd = timeSinceSongEnd + dt

        if #spawnedNotes > 0 then
            spawnedNotes = {}
        end

        if timeSinceSongEnd >= 1 then
            if score > highscore then
                saveHighScore(score)
            end
            love.event.quit()
        end
    end
end

function love.draw()
    love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())

    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, hitBox in ipairs(hitBoxes) do
        love.graphics.rectangle("fill", hitBox.x, hitBox.y, hitBox.width, hitBox.height)
    end

    -- Draw the notes
    for _, note in ipairs(spawnedNotes) do
        local color = noteColors[note.type]

        if keyHeld[keyMap[note.type]] then
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", note.x, note.y, 50, 50)
        else
            love.graphics.setColor(color[1], color[2], color[3], 0.7)
        end

        love.graphics.rectangle("fill", note.x, note.y, 50, 50)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Highscore: " .. highscore, 10, 30)

    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.draw(customMousePointer, mouseX, mouseY, 0, 16 / 512, 16 / 512)
end


-- Key press handler
function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -
    elseif keyMap[key] then
        keyHeld[key] = true
        for i = #spawnedNotes, 1, -1 do
            local note = spawnedNotes[i]
            if checkNoteHit(note, keyMap[key]) then
                table.remove(spawnedNotes, i)
                score = score + 1 
                break
            end
        end
    end
end

function love.keyreleased(key)
    if keyMap[key] then
        keyHeld[key] = false
    end
end

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
