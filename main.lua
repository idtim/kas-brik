---@diagnostic disable: lowercase-global
--love.graphics.setDefaultFilter("nearest") -- Option pour le Pixel Art
love.window.setMode(1152, 864) -- Dimensions de l'écran
love.window.setTitle("KAS BRIK") -- Nom de la fenetre

-- Icône personnalisé de la fenêtre de jeu
local imgIcon = love.image.newImageData("images/icon.png")
love.window.setIcon(imgIcon)

-- Appel des fichiers
require("functions")

-- Déclarations des variables
screenHeight = love.graphics:getHeight()
screenWidth = love.graphics:getWidth()
rndC = love.math.random(1, 8)
offsetBrickL = 75
offsetBrickT = 50
offsetBallR = 100
offsetBallL = 90
offsetPadR = 225
offsetPadL = 225
nbColLev = 0
nbLinLev = 0
alphaGO = 0
alphaEN = 0
alphaBG = 0
nbLevel = 1
alpha = 0
pause = false
controls = false
piston = false
countPistonDo = 0
countPistonUp = 0
padShake = 0
ballFX = false
ballFXScale = 0

-- Données de la raquette
pad = {}
pad.img = love.graphics.newImage("images/pad.png")
pad.x = 0
pad.y = screenHeight - ((pad.img:getHeight()* 0.8) / 2) - 10

-- Données de la balle
ball = {}
ball.x = 0
ball.y = 0
ball.radius = 21
ball.glue = false
ball.vX = 0
ball.vY = 0
ball.vMax = 500

-- Données pour le niveau
bricks = {img = love.graphics.newImage("images/brik1.png"), img2 = love.graphics.newImage("images/brik2.png")}

function love.load()
    LoadImgSndMus()
    Start()
end

function love.update(dt)

    if pause == false then
        -- Gestion de l'affichage des controles
        if love.keyboard.isDown("c") then
            controls = true
        else
            controls = false
        end

        -- Déclenchement du piston quand la brique "Aléatoire" de la ligne 4 est supprimée
        if currentScreen == "game" and level[3][rndC] == 0 and offsetBrickT < 500 then
            piston = true
            countPistonDo = countPistonDo + 1
            offsetBrickT = offsetBrickT + dt * 100
        -- Remontée du piston après niveau
        elseif (currentScreen == "victory" or currentScreen == "end" or currentScreen == "gameOver") and offsetBrickT > 50 then
            piston = true
            countPistonUp = countPistonUp - 1
            offsetBrickT = offsetBrickT - dt * 100
            if offsetBrickT <= 50 then
                offsetBrickT = 50
                alpha = 0

                -- Fade du son du Piston
                local volPiston = 1
                while volPiston > 0 do
                    sndPiston:setVolume(volPiston)
                    volPiston = volPiston - (dt/10)
                end 

            end
        else
            piston = false
        end

        if piston and (countPistonDo == 1 or countPistonUp == -2) then SndPiston() end

        -- Gestion des mouvements du pad avec la souris
        if love.mouse.getX() < offsetPadL then
            pad.x = offsetPadL
        elseif love.mouse.getX() > screenWidth - offsetPadR then
            pad.x = screenWidth - offsetPadR
        else
            pad.x = love.mouse.getX()
        end

        -- Gestion de l'état "Glue" de la balle
        if ball.glue == true then
            ball.x = pad.x
            ball.y = pad.y - ((pad.img:getHeight() * 0.8) / 2) - ball.radius
        else
            ball.x = ball.x + ball.vX*dt
            ball.y = ball.y + ball.vY*dt
        end

        -- Gestion des rebonds avec les murs
        if ball.x > screenWidth - offsetBallR then
            ball.vX = ball.vX * -1
            ball.x = screenWidth - offsetBallR
            SndWall()
        elseif ball.x < offsetBallL then
            ball.vX = ball.vX * -1
            ball.x = offsetBallL
            SndWall()
        elseif ball.y < (offsetBrickT + 10) then
            ball.vY = ball.vY * -1
            ball.y = offsetBrickT + 10
            SndWall()
        elseif ball.y > screenHeight then
            ball.glue = true  
            nbLifes = nbLifes - 1              -- Perte du point si la balle tombe
            if currentScreen == "game" then sndFall:play() end
        end

        -- Gestion des rebonds avec la raquette
        rdnD = love.math.random(0, 100)
        if padShake > 0 then 
            padShake = padShake - 2
            ballFXScale = ballFXScale - (dt*2)
        else
            ballFX = false
        end
        
        if (ball.y > pad.y - ((pad.img:getHeight() * 0.8) / 2) - ball.radius) and (ball.x > (pad.x - ((pad.img:getWidth() * 0.8) / 2))) and (ball.x < (pad.x + ((pad.img:getWidth() * 0.8) / 2))) then
            ball.vY = ball.vY * -1
            ball.y = pad.y - ((pad.img:getHeight() * 0.8) / 2) - ball.radius

            local padW = pad.img:getWidth() * 0.8
            local intVel = (ball.vMax / (padW/2))
            local dist = math.dist(ball.x, ball.y, pad.x - ((pad.img:getWidth() * 0.8) / 2), pad.y - ((pad.img:getHeight() * 0.8)/ 2))
            local dirVecX = 1
            if ball.vX < 0 then dirVecX = -1 end

            --Evènement aléatoire
            if rdnD >= 70 then
                dirVecX = dirVecX * -1
                padShake = 50
                ballFX = true
                ballFXScale = 1
                SndPadEvil()
            end

            pad.x = pad.x + padShake

            if dist >= (padW/2) and dist <= (padW) then
                    ball.vX = intVel * (dist - (padW/2)) * dirVecX 
            elseif dist >= 0 and dist <= (padW/2) then
                    ball.vX = intVel * ((padW/2) - dist) * dirVecX 
            end

            SndPad()
        end

        -- Gestion des rebonds avec les briques
            -- Collision avec le dessous
        if ball.vY < 0 then
            local c = math.floor((ball.x - offsetBrickL) / (bricks.img:getWidth() * 0.8) + 1)
            local l = math.floor(((ball.y - ball.radius) - offsetBrickT) / (bricks.img:getHeight() * 0.8) + 1)
            
            if l >= 1 and l <= #level and c >= 1 and c <= nbColLev then
                SndBrick(level[l][c])
                if level[l][c] ~= 0 then
                    ball.vY = ball.vY * -1
                    if level[l][c] == 1 then 
                        level[l][c] = 0 
                        count = count + 1
                    end
                    if count == nbBricks and nbLevel == 2 then
                        currentScreen = "end"
                        MusEN(dt)
                    elseif count == nbBricks then
                        musVI:play()
                        currentScreen = "victory"
                    end
                end
            end
        end

        -- Collision avec le dessus
        if ball.vY > 0 then
            local c = math.floor((ball.x - offsetBrickL) / (bricks.img:getWidth() * 0.8) + 1)
            local l = math.floor(((ball.y + ball.radius) - offsetBrickT) / (bricks.img:getHeight() * 0.8) + 1)
                   
            if l >= 1 and l <= #level and c >= 1 and c <= nbColLev then
                SndBrick(level[l][c])
                if level[l][c] ~= 0 then
                    ball.vY = ball.vY * -1
                    if level[l][c] == 1 then 
                        level[l][c] = 0 
                        count = count + 1
                    end
                    if count == nbBricks and nbLevel == 2 then
                        currentScreen = "end"
                        MusEN(dt)
                    elseif count == nbBricks then
                        musVI:play()
                        currentScreen = "victory"
                    end
                end
            end
        end

        -- Collision avec le côté droit
        if ball.vX < 0 then
            local c = math.floor((ball.x - ball.radius - offsetBrickL) / (bricks.img:getWidth() * 0.8) + 1)
            local l = math.floor((ball.y - offsetBrickT) / (bricks.img:getHeight() * 0.8) + 1)
            
            if l >= 1 and l <= #level and c >= 1 and c <= nbColLev then
                SndBrick(level[l][c])
                if level[l][c] ~= 0 then
                    ball.vX = ball.vX * -1
                    if level[l][c] == 1 then 
                        level[l][c] = 0 
                        count = count + 1
                    end
                    if count == nbBricks and nbLevel == 2 then
                        currentScreen = "end"
                        MusEN(dt)
                    elseif count == nbBricks then
                        musVI:play()
                        currentScreen = "victory"
                    end
                end
            end
        end

        -- Collision avec le côté gauche
        if ball.vX > 0 then
            local c = math.floor((ball.x + ball.radius - offsetBrickL) / (bricks.img:getWidth() * 0.8) + 1)
            local l = math.floor((ball.y - offsetBrickT) / (bricks.img:getHeight() * 0.8) + 1)
            
            if l >= 1 and l <= #level and c >= 1 and c <= nbColLev then
                SndBrick(level[l][c])
                if level[l][c] ~= 0 then
                    ball.vX = ball.vX * -1
                    if level[l][c] == 1 then 
                        level[l][c] = 0 
                        count = count + 1
                    end
                        if count == nbBricks and nbLevel == 2 then
                            currentScreen = "end"
                            MusEN(dt)
                        elseif count == nbBricks then
                            musVI:play()
                            currentScreen = "victory"
                        end
                end
            end
        end

        -- Déclenche le "Game over"
        if nbLifes == 0 and currentScreen == "game" then
            MusGO(dt)
            currentScreen = "gameOver"
            alphaGO = 0
        end

        -- Gestion des fades In
        if alpha < 1 then alpha = alpha + dt end
        if alphaBG < 1 then alphaBG = alphaBG + dt*2 end
        if currentScreen == "end" and alphaEN < 1 then alphaEN = alphaEN + dt end
        if currentScreen == "gameOver" and alphaGO < 1 then alphaGO = alphaGO + dt end

        -- Gestion des musiques
        if currentScreen == "menu" then musIN:play() end
        if currentScreen == "game" then 
            musGA:setVolume(1)
            musGA:play()

            local volume = 1
            while volume > 0 do
                musIN:setVolume(volume)
                volume = volume - (dt/10)
            end
        end
    end
end

function love.draw()
    love.graphics.scale(1,1) -- Ajuste l'échelle

    -- Affichage du décor
    love.graphics.setColor(1, 1, 1, alphaBG)
    love.graphics.draw(imgBg, 0, 0, 0, 0.8, 0.8) -- BG
    love.graphics.draw(imgWalls, 0, 0, 0, 0.8, 0.8) -- Walls
    love.graphics.draw(imgTop, 0, offsetBrickT, 0, 0.8, 0.8, 0, 755) -- Piston

    if currentScreen == "menu" then
        if controls then
            love.graphics.draw(imgControls) 
        else
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(imgTitle, 0, -60, 0, 0.8, 0.8)   -- Affichage titre du jeu
            love.graphics.draw(imgStart, 0, 0)      -- Affichage message Press Space
        end
    elseif currentScreen == "gameOver" then
        love.graphics.setColor(1, 1, 1, alphaGO)
        love.graphics.draw(imgGO, 0, 0)     -- Affichage titre du GameOver
        if offsetBrickT == 50 then
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(imgRestart, 0, 0)    -- Affichage message Press Space
        end
    elseif currentScreen == "victory" then
        if offsetBrickT == 50 then
            nbLevel = nbLevel + 1
            Start()
            currentScreen = "game"
        end
    elseif currentScreen == "end" then
        love.graphics.setColor(1, 1, 1, alphaEN)
        love.graphics.draw(imgVictory, 0, 0)    -- Affichage titre de la victoire
    else
        -- Affichage des briques
        local l, c
        bX, bY = 0, 0

        for l = 1, nbLinLev do
            bX = 0
            for c = 1, nbColLev do
                if level[l][c] == 1 then
                    love.graphics.draw(bricks.img, bX + offsetBrickL + 1, bY + offsetBrickT + 1, 0, 0.8, 0.7) 
                elseif level[l][c] == 2 then
                    love.graphics.draw(bricks.img2, bX + offsetBrickL + 1, bY + offsetBrickT + 1, 0, 0.8, 0.7) 
                end
                bX = bX + bricks.img:getWidth() * 0.82
            end
            bY = bY + bricks.img:getHeight() * 0.82
            level.draw = true
        end

        love.graphics.draw(pad.img, pad.x - ((pad.img:getWidth() * 0.8) / 2), pad.y - ((pad.img:getHeight() * 0.8)/ 2), 0, 0.8, 0.8)    -- Affichage de la raquette
        love.graphics.draw(imgBall, ball.x, ball.y, 0, 0.65, 0.65, imgBall:getWidth() / 2, imgBall:getHeight() / 2)    -- Affichage de la balle

        if ballFX then love.graphics.draw(imgBallFX, ball.x, ball.y, 0, ballFXScale, ballFXScale, imgBallFX:getWidth() / 2, imgBallFX:getHeight() / 2) end    -- Affichage de l'FX sur la balle


        -- Affichage des titres des niveaux
        love.graphics.setColor(1, 1, 1, alpha)
        if nbLevelImg and nbLevel == 1 then
            love.graphics.draw(imgLevel1)
        elseif nbLevelImg and nbLevel == 2 then
            love.graphics.draw(imgLevel2)
        end

        -- Affichage des vies
        local v = 0
        local offsetLifes = 0
        for v = 1, nbLifes do
            love.graphics.draw(imgLight, pad.x - 137 + offsetLifes, pad.y - 21, 0, 0.8, 0.8)
            offsetLifes = offsetLifes + 28
        end
    end

    if pause and currentScreen == "game" then love.graphics.draw(imgPause) end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end -- Touche "ESCAPE" = Fin du jeu
    if key == "space" and currentScreen == "menu" then 
        sndSpace:play()
        alpha = 0
        currentScreen = "game"
    end
    if key == "space" and currentScreen == "gameOver" and offsetBrickT == 50 then
        sndSpace:play()
        alpha = 0
        nbLevel = 1
        Start()
        currentScreen = "game"
    end
    if key == "return" and currentScreen == "game" then pause = not pause end
    if key == "c" then sndC:play() end

end

function love.mousepressed(x, y, n)
    -- Lance la balle lorsqu'on clique sur la souris
    if ball.glue == true and currentScreen == "game" then
        sndBallStart:play()
        nbLevelImg = false
        ball.glue = false
        local d = love.math.random(1,2)

        if d == 1 then
            v = -1
        else
            v = 1
        end

        ball.vX = love.math.random(1, ball.vMax) * v
        ball.vY = -ball.vMax
    end
end