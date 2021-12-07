--REPRESSENTS OUR CHARACTER

Character = Class{}
local WALK_SPEED = 175
local JUMP_SPEED = 450
function Character:init(map)
    self.x = 0
    self.y = 0
    self.width = 17
    self.height = 21
    self.xOffset = 7
    self.yOffset = 9
    self.map = map
    self.apperance = love.graphics.newImage('graphics/the_red_king.png')
    -- music
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/4.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/3.wav', 'static'),
        ['1'] = love.audio.newSource('sounds/1.wav', 'static')
    }
    self.structureworks = {}
    self.latestFrame = nil
    self.state = 'steady'
    self.direction = 'left'
    self.dx = 0
    self.dy = 0
    -- positions 
    self.y = map.tileY * ((map.mapY - 2) / 2) - self.height
    self.x = map.tileX * 10
    -- player visuals
    self.visuals = {
        ['steady'] = Visual({
            apperance = self.apperance,
            structureworks = {
                love.graphics.newQuad(0, 0, 16, 20, self.apperance:getDimensions())
            }
        }),
        ['walks'] = Visual({
            apperance = self.apperance,
            structureworks = {
                love.graphics.newQuad(128, 0, 16, 20, self.apperance:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.apperance:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.apperance:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.apperance:getDimensions()),
            },
            intermission = 0.15
        }),
        ['jumps'] = Visual({
            apperance = self.apperance,
            structureworks = {
                love.graphics.newQuad(32, 0, 16, 20, self.apperance:getDimensions())
            }
        })
    }

    self.visual = self.visuals['steady']
    self.latestFrame = self.visual:getCurrentFrame()

    -- behaviour of player
    self.behave_of_char = {
        ['steady'] = function(dit)
            
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_SPEED
                self.state = 'jumps'
                self.visual = self.visuals['jumps']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALK_SPEED
                self.state = 'walks'
                self.visuals['walks']:restart()
                self.visual = self.visuals['walks']
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALK_SPEED
                self.state = 'walks'
                self.visuals['walks']:restart()
                self.visual = self.visuals['walks']
            else
                self.dx = 0
            end
        end,
        ['walks'] = function(dit)
            --tracks the movements
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_SPEED
                self.state = 'jumps'
                self.visual = self.visuals['jumps']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALK_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALK_SPEED
            else
                self.dx = 0
                self.state = 'steady'
                self.visual = self.visuals['steady']
            end

            -- checks for collisions
            self:checkforrightCollision()
            self:checkforleftCollision()

            -- check for tiles
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- reset the velocity
                self.state = 'jumps'
                self.visual = self.visuals['jumps']
            end
        end,
        ['jumps'] = function(dit)
            -- intermission if go too fast
            if self.y > 300 then
                return
            end
            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -WALK_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = WALK_SPEED
            end
            -- check gravity
            self.dy = self.dy + self.map.gravity
            -- check for tiles
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- reset velocity
                self.dy = 0
                self.state = 'steady'
                self.visual = self.visuals['steady']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileY - self.height
            end

            -- collisions
            self:checkforrightCollision()
            self:checkforleftCollision()
        end
    }
end

function Character:update(dit)
    self.behave_of_char[self.state](dit)
    self.visual:update(dit)
    self.latestFrame = self.visual:getCurrentFrame()
    self.x = self.x + self.dx * dit

    self:calJumps()
    -- speed
    self.y = self.y + self.dy * dit
end

function Character:calJumps()
    -- negatuves
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y).id ~= EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y).id ~= EMPTY then
            -- reset y velocity
            self.dy = 0

            -- change block to different block
            local play1 = false
            local playHit = false
            if self.map:tileAt(self.x, self.y).id == JUMP_TILE then
                self.map:setTile(math.floor(self.x / self.map.tileX) + 1,
                    math.floor(self.y / self.map.tileY) + 1, FOR_JUMP)
                play1 = true
            else
                playHit = true
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_TILE then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileX) + 1,
                    math.floor(self.y / self.map.tileY) + 1, FOR_JUMP)
                play1 = true
            else
                playHit = true
            end

            if play1 then
                self.sounds['1']:play()
            elseif playHit then
                self.sounds['hit']:play()
            end
        end
    end
end

-- checks two tiles to our left to see if a collision occurred
function Character:checkforleftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileX
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Character:checkforrightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileX - self.width
        end
    end
end

function Character:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.apperance, self.latestFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
end
