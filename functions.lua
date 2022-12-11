---@diagnostic disable: undefined-global, lowercase-global

function LoadImgSndMus()
    imgBg = love.graphics.newImage("images/bg.png")
    imgWalls = love.graphics.newImage("images/walls.png")
    imgTop = love.graphics.newImage("images/top.png")
    imgStart = love.graphics.newImage("images/start.png")
    imgRestart = love.graphics.newImage("images/restart.png")
    imgLight = love.graphics.newImage("images/light.png")
    imgTitle = love.graphics.newImage("images/title.png")
    imgBall = love.graphics.newImage("images/ball.png")
    imgBallFX = love.graphics.newImage("images/ballFX.png")
    imgGO = love.graphics.newImage("images/gameover.png")
    imgVictory = love.graphics.newImage("images/victory.png")
    imgLevel1 = love.graphics.newImage("images/level_1.png")
    imgLevel2 = love.graphics.newImage("images/level_2.png")
    imgPause = love.graphics.newImage("images/pause.png")
    imgControls = love.graphics.newImage("images/controls.png")

    sndC = love.audio.newSource("sounds/c.wav","static")
    sndSpace = love.audio.newSource("sounds/space.wav","static")
    sndBallStart = love.audio.newSource("sounds/ballStart.wav","static")
    sndBrick1 = love.audio.newSource("sounds/brick.wav","static")
    sndBrick2 = love.audio.newSource("sounds/metal3.wav","static")
    sndPad = love.audio.newSource("sounds/metal1.wav","static")
    sndPadEvil = love.audio.newSource("sounds/spell.wav","static")
    sndWall = love.audio.newSource("sounds/metal2.wav","static")
    sndFall = love.audio.newSource("sounds/fall.wav","static")
    sndStop = love.audio.newSource("sounds/stop.wav","static")
    sndPiston = love.audio.newSource("sounds/piston.wav","static")
 
    musGO = love.audio.newSource("musics/gameover.wav","stream")
    musVI = love.audio.newSource("musics/victory.wav","stream")
    musIN = love.audio.newSource("musics/intro.mp3","stream")
    musGA = love.audio.newSource("musics/game.mp3","stream")
    musEN = love.audio.newSource("musics/end.wav","stream")
end

function SndBrick(pBrickType)
    if currentScreen == "game" then
        if pBrickType == 1 then
            sndBrick1:stop()
            sndBrick1:play()
        elseif pBrickType == 2 then
            sndBrick2:stop()
            sndBrick2:play()
        end
    end
end

function SndPad()
    if currentScreen == "game" then
        sndPad:stop()
        sndPad:play()
    end
end

function SndPadEvil()
    if currentScreen == "game" then
        sndPadEvil:stop()
        sndPadEvil:play()
    end
end

function SndWall()
    if currentScreen == "game" then
        sndWall:stop()
        sndWall:play()
    end
end

function SndPiston()
    sndPiston:stop()
    sndPiston:play()
end

function MusGO(pDt)
    musGO:play()
    local volume = 1
    while volume > 0 do
        musGA:setVolume(volume)
        volume = volume - (pDt/10)
    end
end

function MusEN(pDt)
    musEN:setLooping(true)
    musEN:play()
    local volume = 1
    while volume > 0 do
        musGA:setVolume(volume)
        volume = volume - (pDt/10)
    end
end

function Start()
    ball.glue = true
    nbLevelImg = true
    nbLifes = 2
    count = 0
    currentScreen = "menu"
    level = {}
    level.draw = false
    countPistonDo = 0
    countPistonUp = 0
    sndPiston:setVolume(1)


    if nbLevel == 1 then
        Level1()
    elseif nbLevel == 2 then
        Level2()
    end
end

function Level1()
    nbColLev = 8
    nbLinLev = 4
    nbBricks = 28

    level = {
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {1,0,0,1,1,0,0,1},
            }
end

function Level2()
    nbColLev = 8
    nbLinLev = 6
    nbBricks = 34

    level = {
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {0,1,1,2,2,1,1,0},
                {0,0,1,1,1,1,0,0},
                {0,0,0,1,1,0,0,0},
            }
end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end