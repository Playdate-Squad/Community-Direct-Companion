--[[
    Author: PossiblyAxolotl
    Created: April 25, 2024
    Modified: April 25, 2024
    Description: Draws a tv static-like image, could be cool to have slightly visible in the seams between scrolling images
--]]

local gfx <const> = playdate.graphics

local imgStatic <const> = gfx.image.new("assets/viewer/static")
assert(imgStatic)

function drawStatic()
    imgStatic:vcrPauseFilterImage():draw(0,0)
end