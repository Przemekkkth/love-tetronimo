-- constants
FPS = 25
WINDOWWIDTH = 640
WINDOWHEIGHT = 480
BOXSIZE = 20
BOARDWIDTH = 10
BOARDHEIGHT = 20
BLANK = '.'
TITLE = 'Tetronimo'

MOVESIDEWAYSFREQ = 0.15
MOVEDOWNFREQ = 0.1

XMARGIN = math.floor((WINDOWWIDTH - BOARDWIDTH * BOXSIZE) / 2)
TOPMARGIN = WINDOWHEIGHT - (BOARDHEIGHT * BOXSIZE) - 5

--               R    G    B
WHITE       = {1.0, 1.0, 1.0} -- (255, 255, 255)
GRAY        = {.72, .72, .72} -- (185, 185, 185)
BLACK       = { .0,  .0,  .0} -- (  0,   0,   0)
RED         = {.61,  .0,  .0} -- (155,   0,   0)
LIGHTRED    = {.69,  .1,  .1} -- (175,  20,  20)
GREEN       = { .0, .61,  .0} -- (  0, 155,   0)
LIGHTGREEN  = { .1, .69,  .1} -- ( 20, 175,  20)
BLUE        = { .0,  .0, .61} -- (  0,   0, 155)
LIGHTBLUE   = { .1,  .1, .69} -- ( 20,  20, 175)
YELLOW      = {.61, .61,  .0} -- (155, 155,   0)
LIGHTYELLOW = {.69, .69,  .1} -- (175, 175,  20)


BORDERCOLOR = BLUE
BGCOLOR = BLACK
TEXTCOLOR = WHITE
TEXTSHADOWCOLOR = GRAY
COLORS      = {     BLUE,      GREEN,      RED,      YELLOW}
LIGHTCOLORS = {LIGHTBLUE, LIGHTGREEN, LIGHTRED, LIGHTYELLOW}

assert(#COLORS == #LIGHTCOLORS, "each color must have light color")


TEMPLATEWIDTH = 5
TEMPLATEHEIGHT = 5

S_SHAPE_TEMPLATE = {{'.....',
                     '.....',
                     '..OO.',
                     '.OO..',
                     '.....'},
                    {'.....',
                     '..O..',
                     '..OO.',
                     '...O.',
                     '.....'}}

Z_SHAPE_TEMPLATE = {{'.....',
                     '.....',
                     '.OO..',
                     '..OO.',
                     '.....'},
                    {'.....',
                     '..O..',
                     '.OO..',
                     '.O...',
                     '.....'}}

I_SHAPE_TEMPLATE = {{'..O..',
                     '..O..',
                     '..O..',
                     '..O..',
                     '.....'},
                    {'.....',
                     '.....',
                     'OOOO.',
                     '.....',
                     '.....'}}

O_SHAPE_TEMPLATE = {{'.....',
                     '.....',
                     '.OO..',
                     '.OO..',
                     '.....'}}

J_SHAPE_TEMPLATE = {{'.....',
                     '.O...',
                     '.OOO.',
                     '.....',
                     '.....'},
                    {'.....',
                     '..OO.',
                     '..O..',
                     '..O..',
                     '.....'},
                    {'.....',
                     '.....',
                     '.OOO.',
                     '...O.',
                     '.....'},
                    {'.....',
                     '..O..',
                     '..O..',
                     '.OO..',
                     '.....'}}

L_SHAPE_TEMPLATE = {{'.....',
                     '...O.',
                     '.OOO.',
                     '.....',
                     '.....'},
                    {'.....',
                     '..O..',
                     '..O..',
                     '..OO.',
                     '.....'},
                    {'.....',
                     '.....',
                     '.OOO.',
                     '.O...',
                     '.....'},
                    {'.....',
                     '.OO..',
                     '..O..',
                     '..O..',
                     '.....'}}

T_SHAPE_TEMPLATE = {{'.....',
                     '..O..',
                     '.OOO.',
                     '.....',
                     '.....'},
                    {'.....',
                     '..O..',
                     '..OO.',
                     '..O..',
                     '.....'},
                    {'.....',
                     '.....',
                     '.OOO.',
                     '..O..',
                     '.....'},
                    {'.....',
                     '..O..',
                     '.OO..',
                     '..O..',
                     '.....'}}

PIECES = {}
PIECES["S"] = S_SHAPE_TEMPLATE
PIECES["Z"] = Z_SHAPE_TEMPLATE
PIECES["J"] = J_SHAPE_TEMPLATE         
PIECES["L"] = L_SHAPE_TEMPLATE         
PIECES["I"] = I_SHAPE_TEMPLATE         
PIECES["O"] = O_SHAPE_TEMPLATE         
PIECES["T"] = T_SHAPE_TEMPLATE         

-- initialization
function love.load()
    love.window.setTitle(TITLE)
    love.window.setMode(WINDOWWIDTH, WINDOWHEIGHT)
    -- Set a seed for reproducibility (optional)
    love.math.setRandomSeed(os.time())

    BASICFONT = love.graphics.newFont('/assets/fonts/freesansbold.ttf', 18)
    BIGFONT   = love.graphics.newFont('/assets/fonts/freesansbold.ttf', 100)

    love.graphics.setBackgroundColor(BLACK)
    state = "MENU" -- Game/Pause/GameOver
    sounds = {}

    accumulatedTime = 0
    timePerFrame = 1 / FPS
end

function love.keypressed(key)
    if state == "GAME" then
        if fallingPiece == nil then
            return
        end

        if (key == "left" or key == "a") and isValidPosition(board, fallingPiece, -1, 0) then
            fallingPiece["x"] = fallingPiece["x"] - 1
            movingLeft = true
            movingRight = false
            lastMoveSidewaysTime = love.timer.getTime()
        elseif (key == "right" or key == "d") and isValidPosition(board, fallingPiece, 1, 0) then
            fallingPiece["x"] = fallingPiece["x"] + 1
            movingLeft = false
            movingRight = true
            lastMoveSidewaysTime = love.timer.getTime()

        elseif key == "up" or key == "w" then
            local currentRotation = fallingPiece["rotation"]
            fallingPiece["rotation"] = fallingPiece["rotation"] + 1
            if fallingPiece["rotation"] > #PIECES[fallingPiece["shape"]] then
                fallingPiece["rotation"] = 1
            end
            if not isValidPosition(board, fallingPiece,0,0) then
                fallingPiece["rotation"] = currentRotation
            end
        elseif key == "q" then
            local currentRotation = fallingPiece["rotation"]
            fallingPiece["rotation"] = fallingPiece["rotation"] - 1
            if fallingPiece["rotation"] < 1 then
                fallingPiece["rotation"] = #PIECES[fallingPiece["shape"]]
            end
            if not isValidPosition(board, fallingPiece, 0, 0) then
                fallingPiece['rotation'] = currentRotation
            end
        elseif key == "down" or key == "s" then
            movingDown = True
            if isValidPosition(board, fallingPiece, 0, 1) then
                fallingPiece['y'] = fallingPiece['y'] + 1
                lastMoveDownTime = love.timer.getTime()
            end
        elseif key == "space" then
            movingDown = false
            movingLeft = false
            movingRight = false
            for i = 1, BOARDHEIGHT do
                if not isValidPosition(board, fallingPiece, 0, i) then
                    break
                end
                fallingPiece['y'] = fallingPiece['y'] + (i - 1)
            end

        end
    end
end

function love.keyreleased(key)
    if state == "MENU" then
        state = "GAME"
        -- Generate a random value between 0 and 1
        local randomValue = love.math.random()
        if randomValue > 0.5 then
            sounds.music = love.audio.newSource("assets/sounds/tetrisb.mid", "stream")
        else 
            sounds.music = love.audio.newSource("assets/sounds/tetrisc.mid", "stream")
        end
        sounds.music:setLooping(true)
        sounds.music:setVolume(0.05)
        sounds.music:play()
        
        board = getBlankBoard()

        lastMoveDownTime = love.timer.getTime()
        lastMoveSidewaysTime = love.timer.getTime()
        lastFallTime = love.timer.getTime()
        movingDown = false -- note: there is no movingUp variable
        movingLeft = false
        movingRight = false
        score = 0
        level, fallFreq = calculateLevelAndFallFreq(score)

        fallingPiece = getNewPiece()
        nextPiece = getNewPiece()

        accumulatedTime = 0
    elseif state == "GAME" then
        if key == "p" then
            state = "PAUSED"
            sounds.music:stop();
        elseif key == "left" or key == "a" then
            movingLeft = false
        elseif key == "right" or key == "d" then
            movingRight = false
        elseif key == "down" or key == "s" then
            movingDown = false  
        end
    elseif state == "PAUSED" then
        if key == "p" then
            state = "GAME"
            sounds.music:play();
            lastFallTime =         love.timer.getTime()
            lastMoveDownTime =     love.timer.getTime()
            lastMoveSidewaysTime = love.timer.getTime()
            accumulatedTime = 0
        end
    elseif state == "GAMEOVER" then
        state = "MENU"
    end

    if key == "escape" then
       love.event.quit()
    end
 end

function love.update(dt)
    if state == "GAME" then
        accumulatedTime = accumulatedTime + dt
        if accumulatedTime >= timePerFrame then
            accumulatedTime = accumulatedTime - timePerFrame
        
            if fallingPiece == nil then
                -- No falling piece in play, so start a new piece at the top
                fallingPiece = nextPiece
                nextPiece = getNewPiece()
                lastFallTime = love.timer.getTime() -- reset lastFallTime
            end


            if not isValidPosition(board, fallingPiece, 0, 0) then
                state = "GAMEOVER"
                
                --return -- can't fit a new piece on the board, so game over
            end
            -- handle moving the piece because of user input
            if (movingLeft or movingRight) and love.timer.getTime() - lastMoveSidewaysTime > MOVESIDEWAYSFREQ then
                if movingLeft and isValidPosition(board, fallingPiece, -1, 0) then
                    fallingPiece['x'] = fallingPiece['x'] - 1
                elseif movingRight and isValidPosition(board, fallingPiece, 1, 0) then
                    fallingPiece['x'] = fallingPiece['x'] + 1
                end
                lastMoveSidewaysTime = love.timer.getTime()
            end

            if movingDown and love.timer.getTime() - lastMoveDownTime > MOVEDOWNFREQ and isValidPosition(board, fallingPiece, 0, 1) then
                fallingPiece['y'] = fallingPiece['y'] + 1
                lastMoveDownTime = love.timer.getTime()
            end

            -- let the piece fall if it is time to fall
            if love.timer.getTime() - lastFallTime > fallFreq then
                -- see if the piece has landed
                if not isValidPosition(board, fallingPiece, 0, 1) then
                    -- falling piece has landed, set it on the board
                    addToBoard(board, fallingPiece)
                    score = score + removeCompleteLines(board)
                    level, fallFreq = calculateLevelAndFallFreq(score)
                    fallingPiece = nil
                else
                    -- piece did not land, just move the piece down
                    fallingPiece['y'] = fallingPiece['y'] + 1
                    lastFallTime = love.timer.getTime()
                end
            end
        end
    end
end

function love.draw()
    if state == "MENU" then
        showTextScreen("Tetromino", "Press a key to play.")
    elseif state == "GAME" then
        drawBoard(board)
        drawStatus(score ,level)
        drawNextPiece(nextPiece)
        if fallingPiece ~= nil then
            drawPiece(fallingPiece)
        end
    elseif state == "PAUSED" then
        showTextScreen("PAUSED", "Press \'p\' key to play.")
    elseif state == "GAMEOVER" then
        showTextScreen("GAMEOVER", "     Your score: "..tostring(score)..
                                   "\nPress a key to play.")
    end
end

function showTextScreen(titleText, hintText)
    love.graphics.setFont(BIGFONT)
    love.graphics.setColor(TEXTSHADOWCOLOR)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(titleText)
    local textHeight = font:getHeight()
    love.graphics.print(titleText, WINDOWWIDTH/2, WINDOWHEIGHT/2, 0, 1, 1, textWidth/2, textHeight/2)

    love.graphics.setColor(TEXTCOLOR)
    love.graphics.print(titleText, WINDOWWIDTH/2-3, WINDOWHEIGHT/2-3, 0, 1, 1, textWidth/2, textHeight/2)

    love.graphics.setFont(BASICFONT)
    local font = love.graphics.getFont()

    textWidth = font:getWidth(hintText)
    love.graphics.print(hintText, WINDOWWIDTH/2, WINDOWHEIGHT/2+100, 0, 1, 1, textWidth/2, textHeight/2)
end

function getBlankBoard()
    local board = {}

    for i = 1, BOARDWIDTH do
        board[i] = {}

        for j = 1, BOARDHEIGHT do
            board[i][j] = BLANK
        end
    end

    return board
end

function calculateLevelAndFallFreq(score)
    local level = math.floor(score / 10) + 1
    local fallFreq = 0.27 - (level * 0.02)
    return level, fallFreq
end

function getNewPiece()
    local keys = {"S", "Z", "J", "L", "I", "O", "T"}
    local randomValue = love.math.random(1, #keys)
    local randomKey = keys[randomValue]
    local newPiece = {}
    newPiece["shape"] = randomKey
    newPiece["rotation"] = love.math.random(1, #PIECES[newPiece["shape"]])
    newPiece["x"] = math.floor(BOARDWIDTH/2) - math.floor(TEMPLATEWIDTH/2)
    newPiece["y"] = -2
    newPiece["color"] = love.math.random(1, #COLORS)

    return newPiece
end

function isOnBoard(x, y)
    return x >= 1 and x <= BOARDWIDTH and y <= BOARDHEIGHT
end

function isValidPosition(board, piece, adjX, adjY)
    if piece == nil then
        return
    end
    local shape = PIECES[piece["shape"]][piece["rotation"]]
    for x = 1, TEMPLATEWIDTH do
        for y = 1, TEMPLATEHEIGHT do
            local isAboveBoard = y + piece["y"] + adjY < 1
            if isAboveBoard or string.sub(shape[y], x, x) == BLANK then
                goto continue
            end
            if not isOnBoard(x + piece["x"] + adjX, y + piece["y"] + adjY) then
                return false
            end
            if board[x + piece["x"] + adjX][y + piece["y"] + adjY] ~= BLANK then
                return false

            end
            ::continue::
        end
    end

    return true
end

function printTable(table, name)
    print(name)
    for key, value in pairs(table) do
        print(key, value)
    end
end

function drawBoard(board)
    love.graphics.setColor(BORDERCOLOR)
    love.graphics.rectangle("line", XMARGIN - 3, TOPMARGIN - 7, (BOARDWIDTH * BOXSIZE) + 8, (BOARDHEIGHT * BOXSIZE) + 8, 5)
    
    love.graphics.setColor(BGCOLOR)
    love.graphics.rectangle("fill", XMARGIN, TOPMARGIN, BOXSIZE * BOARDWIDTH, BOXSIZE * BOARDHEIGHT)

    for x = 1, BOARDWIDTH do
        for y = 1, BOARDHEIGHT do
            drawBox(x-1, y-1, board[x][y], nil, nil)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function drawBox(boxx, boxy, color, pixelx, pixely)
    if color == BLANK then
        return
    end

    if pixelx == nil and pixely == nil then
        pixelx, pixely = convertToPixelCoords(boxx, boxy)
    end

    love.graphics.setColor(COLORS[color])
    love.graphics.rectangle("fill", pixelx + 1, pixely + 1, BOXSIZE - 1, BOXSIZE - 1)

    love.graphics.setColor(LIGHTCOLORS[color])
    love.graphics.rectangle("fill", pixelx + 1, pixely + 1, BOXSIZE - 4, BOXSIZE - 4)
    love.graphics.setColor(1, 1, 1)
end

function drawStatus(score, level)
    love.graphics.setFont(BASICFONT)
    love.graphics.setColor(TEXTCOLOR)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth("Score: " .. score)
    local textHeight = font:getHeight()
    love.graphics.print("Score: " .. score, WINDOWWIDTH - 150, 20)

    local textWidth = font:getWidth("Level: " .. level)
    love.graphics.print("Level: " .. level, WINDOWWIDTH - 150, 50)
    love.graphics.setColor(1, 1, 1)
end

function drawNextPiece(piece)
    love.graphics.setColor(TEXTCOLOR)
    love.graphics.setFont(BASICFONT)
    
    love.graphics.print("Next: ", WINDOWWIDTH - 120, 80)

    drawPiece(piece, WINDOWWIDTH-120, 100)
    love.graphics.setColor(1, 1, 1)
end

function drawPiece(piece, pixelx, pixely)
    local shapeToDraw = PIECES[piece["shape"]][piece["rotation"]]
    if pixelx == nil and pixely == nil then
        pixelx, pixely = convertToPixelCoords(piece["x"], piece["y"])
    end
    for x = 1, TEMPLATEWIDTH do
       for y = 1, TEMPLATEHEIGHT do
        if string.sub(shapeToDraw[y],x,x) ~= BLANK then
            drawBox(nil, nil, piece["color"], pixelx + ((x-1) * BOXSIZE), pixely + ((y-1) * BOXSIZE))
        end
       end
    end
end

function convertToPixelCoords(boxx, boxy) 
    return (XMARGIN + (boxx * BOXSIZE)), (TOPMARGIN + (boxy * BOXSIZE))
end

function addToBoard(board, piece) 
    local shape = PIECES[piece["shape"]][piece["rotation"]]
   -- fill in the board based on piece's location, shape, and rotation
   for x = 1, TEMPLATEWIDTH do
    for y = 1, TEMPLATEHEIGHT do
        if string.sub(shape[y],x,x) ~= BLANK then
            board[x+piece["x"]][y + piece["y"]] = piece["color"]
        end
    end
   end
end

function removeCompleteLines(board) 
    -- Remove any completed lines on the board, move everything above them down, and return the number of complete lines.
    numLinesRemoved = 0
    y = BOARDHEIGHT -- start y at the bottom of the board
    while y >= 1 do
        if isCompleteLine(board, y) then
            -- Remove the line and pull boxes down by one line.
            for pullDownY = y, 1, -1 do
                for x = 1, BOARDWIDTH do
                    board[x][pullDownY] = board[x][pullDownY-1]
                end
            end
            -- Set very top line to blank.
            for x = 1, BOARDWIDTH do
                board[x][1] = BLANK
            end
            numLinesRemoved = numLinesRemoved + 1
            -- Note on the next iteration of the loop, y is the same.
            -- This is so that if the line that was pulled down is also
            -- complete, it will be removed.
        else
            y = y - 1 -- move on to check next row up
        end
    end

    return numLinesRemoved
end

function isCompleteLine(board, y)
    -- Return true if the line filled with boxes with no gaps.
    for x = 1, BOARDWIDTH do
        if board[x][y] == BLANK then
            return false
        end
    end
    return true
end