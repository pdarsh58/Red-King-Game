require 'Supports'

Map = Class{}

--Bricks
BRICK = 1
EMPTY = -1
-- clouds
FIRST_CLOUD = 6
SEC_CLOUD = 7
-- bushes
FIRST_BUSH = 2
SEC_BUSH = 3
-- mushrooms
TOP_MUSH = 10
BOTT_MUSH = 11
-- jump blocks
JUMP_TILE = 5
FOR_JUMP = 9
-- flags
FLAG = 14
POLE_TOP = 8
POLE_MIDDLE = 12

-- scrolling speed
local SCROLL_SPEED = 55

-- builds map
function Map:init()

    self.new_spritesheet = love.graphics.newImage('graphics/graphicssheet.png')
    self.graphics = generateQuads(self.new_spritesheet, 16, 16)
    self.sounds = love.audio.newSource('sounds/music.wav', 'static')
    self.tileX = 16
    self.tileY = 16
    self.mapX = 100
    self.mapY = 24
    self.tiles = {}
    self.gravity = 15
    self.character = Character(self)
    self.camX = 0
    self.camY = -3
    -- pixel xcoord and y coord
    self.mapXPixels = self.mapX * self.tileX
    self.mapYPixels = self.mapY * self.tileY
    -- fills empty winodw
    for y = 1, self.mapY do
        for x = 1, self.mapX do
            self:setTile(x, y, EMPTY)
        end
    end
    
    -- some local variables
    local P1 = self.mapX - 23
    local P2 = self.mapX - 18
    local P3 = self.mapY / 2 - 1
    local P4 = self.mapY / 2 - 1


    for x = P1, P2, 1 do
        for y = P4, P3, -1 do
            self:setTile(x, y, BRICK)
        end
        P3 = P3 - 1
    end
      
    -- Generates a uniform ground 
    for x = self.mapX - 11, self.mapX do
        for y = self.mapY / 2, self.mapY do
            self:setTile(x, y, BRICK)
        end
    end

    -- generates flag pole
    for y = self.mapY / 2 - 7, self.mapY / 2 - 2 do
        self:setTile(self.mapX - 6, y, POLE_TOP)
    end
    self:setTile(self.mapX - 6, self.mapY / 2 - 8, FLAG)
    self:setTile(self.mapX - 6, self.mapY / 2 - 1, POLE_MIDDLE)


    -- generates other stuffs like cluds, mushrooms, empty_brick
    local x = 1
    while x <=  self.mapX - 23 do

        -- generates clouds
        if x < self.mapX - 2 then
            if math.random(15) == 1 then
                
                local cloudStart = math.random(self.mapY / 2 - 6)

                self:setTile(x, cloudStart, FIRST_CLOUD)
                self:setTile(x + 1, cloudStart, SEC_CLOUD)
            end
        end
    
        --generates mushrooms
        if math.random(19) == 1 then
            -- left side of pipe
            self:setTile(x, self.mapY / 2 - 2, TOP_MUSH)
            self:setTile(x, self.mapY / 2 - 1, BOTT_MUSH)
            for y = self.mapY / 2, self.mapY do
                self:setTile(x, y, BRICK)
            end
            x = x + 1

        -- creates gaps
        elseif math.random(30) ~= 1 then
            for y = self.mapY / 2, self.mapY do
                self:setTile(x, y, BRICK)
            end
            -- chance to create a block for Mario to hit
            if math.random(5) == 1 then
                self:setTile(x, self.mapY / 2 - 4, JUMP_TILE)
                x = x + 1
                self:setTile(x, self.mapY / 2 - 4, JUMP_TILE)
            end
            if math.random(5) == 1 then
                self:setTile(x, self.mapY / 2 - 8, JUMP_TILE)
                x = x + 1
                self:setTile(x, self.mapY / 2 - 8, JUMP_TILE)          
            end
            x = x + 1
        end
    end
    self.sounds:setLooping(true) --sounds
    self.sounds:play()
end

-- checks if colliable tile
function Map:collides(tile)
    local jumpables = {
        BRICK, JUMP_TILE, FOR_JUMP,
        TOP_MUSH, BOTT_MUSH
    }
    for _, v in ipairs(jumpables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

-- it updates camera
function Map:update(dit)
    self.character:update(dit)
    self.camX = math.max(0, math.min(self.character.x - VIRTUAL_XCOORD / 2,
        math.min(self.mapXPixels - VIRTUAL_XCOORD, self.character.x)))
end

-- gives type of brick
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileX) + 1,
        y = math.floor(y / self.tileY) + 1,
        id = self:getTile(math.floor(x / self.tileX) + 1, math.floor(y / self.tileY) + 1)
    }
end

-- gives position
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapX + x]
end

-- sets according to the need
function Map:setTile(x, y, itd)
    self.tiles[(y - 1) * self.mapX + x] = itd
end

-- render the maps
function Map:render()
    for y = 1, self.mapY do
        for x = 1, self.mapX do
            local tile = self:getTile(x, y)
            if tile ~= EMPTY then
                love.graphics.draw(self.new_spritesheet, self.graphics[tile],
                    (x - 1) * self.tileX, (y - 1) * self.tileY)
            end
        end
    end

    self.character:render()
end
