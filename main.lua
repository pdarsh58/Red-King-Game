--MODIFIED VERSION OF SUPER MARIO BROS
-- NOTE SOME OF THE CODE IS TAKEN FROM CS50x distribution code @https://cs50.harvard.edu/x/2020/tracks/games/mario/
--BECAUSE THATS THE BASIC FUNCTIONS THAT NEEDS TO SETUP THE GAME
--OTHER THAN EVERYTHING ELSE IS MY ORIGINAL CODE

Class = require 'section'
push = require 'push'
require 'Visual'
require 'Map'
require 'Character'

VIRTUAL_XCOORD = 430
VIRTUAL_YCOORD = 240

-- window resolution
WIND_XCOORD = 1280
WIND_YCOORD = 720

math.randomseed(os.time())

-- less blury visuals
love.graphics.setDefaultFilter('nearest', 'nearest')

map = Map()

function love.load()
    love.graphics.setFont(love.graphics.newFont('font.ttf', 9))
    push:setupScreen(VIRTUAL_XCOORD, VIRTUAL_YCOORD, WIND_XCOORD, WIND_YCOORD, {
        fullscreen = false,
        resizable = true
    })
    love.window.setTitle('THE RED KING by Darshil Patel (2021)')
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end
function love.resize(w, h)
    push:resize(w, h)
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.update(dit)
    map:update(dit)

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.draw()
    push:apply('start')
    love.graphics.clear(95/132, 108/140, 255/255, 255/255)
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    map:render()
    push:apply('end')
end
