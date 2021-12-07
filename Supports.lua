--some of the needs supports to run the game

function generateQuads(mapping, tileX, tileY)
    local sheetXcoord = mapping:getWidth() / tileX
    local sheetYcoord = mapping:getHeight() / tileY

    local countsheets = 1
    local quads = {}

    for y = 0, sheetYcoord - 1 do
        for x = 0, sheetXcoord - 1 do

            quads[countsheets] =
                love.graphics.newQuad(x * tileX, y * tileY, tileX,
                tileY, mapping:getDimensions())
            countsheets = countsheets + 1
        end
    end
    return quads
end
