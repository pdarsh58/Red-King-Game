-- Everythiong visuals of the game

Visual = Class{}
function Visual:init(parameters)
    self.apperance = parameters.apperance
    self.structureworks = parameters.structureworks or {}
    self.intermission = parameters.intermission or 0.05
    self.timeframe = 0
    self.latestFrame = 1
end
function Visual:getCurrentFrame()
    return self.structureworks[self.latestFrame]
end
function Visual:restart()
    self.timeframe = 0
    self.latestFrame = 1
end
function Visual:update(dit)
    self.timeframe = self.timeframe + dit
    -- get the timeframe
    while self.timeframe > self.intermission do
        self.timeframe = self.timeframe - self.intermission
        self.latestFrame = (self.latestFrame + 1) % #self.structureworks
        if self.latestFrame == 0 then self.latestFrame = 1 end
    end
end
