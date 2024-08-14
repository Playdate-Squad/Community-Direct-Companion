--[[
    Author: PossiblyAxolotl
    Created: April 25, 2024
    Modified: June 12, 2024
--]]

import "CoreLibs/ui"
import "CoreLibs/graphics"
import "CoreLibs/qrcode"

local gfx <const> = playdate.graphics

local imgBackground = gfx.image.new("assets/backgrounds/BackgroundAppClosed")
local imgHead = gfx.image.new("assets/backgrounds/headbar")
local tabAppIcon = gfx.imagetable.new("assets/buttons/app")

local qrTimer

local frameCount = 1

-- font stuff
local font = gfx.font.new("DirectFont")
local dFont = gfx.getFont()
gfx.setFont(font)

-- set up app grid
local appgrid = playdate.ui.gridview.new(32,32)
appgrid:setNumberOfColumns(6)
appgrid:setNumberOfRows(6)
appgrid:setCellPadding(16,16,4,16)

local games = playdate.file.listFiles("games/2024.1") -- load names of all games
local truefalse <const> = {[true]=2,[false]=1} -- used later in appgrid:drawCell

data = {}
images = {}
gifs = {}
scroll = 0
maxScroll = 0
local selection = ""
local topImage = gfx.image.new(400, 240, gfx.kColorWhite)

-- draw app icons and text
function appgrid:drawCell(section, row, column, selected, x, y, width, height)
    local appID = column + (row-1) * 6

    if appID > #games then
        return
    end

    if selected then
        selection = games[appID]
        print(selection)
        print(appID)
    end

    local text = games[appID]
    text = string.sub(string.gsub( text,"/", ""), 4) -- sub starts string at char 4, gsub replaces / with nothing

    tabAppIcon[truefalse[selected]]:draw(x,y)
    gfx.drawTextInRect(text,x-16,y+34, 64, 24, 0, "...", kTextAlignment.center)
end

function MainUpdate()
    gfx.clear()

    -- menu x
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        appgrid:selectNextColumn()
        local _s, _y, _x = appgrid:getSelection()
        local appID = _x + (_y-1) * 6

        if appID > #games then
            appgrid:selectPreviousColumn(false)
        end

    elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
        appgrid:selectPreviousColumn(false)

    -- menu y
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        appgrid:selectNextRow(false,true)
        local _s, _y, _x = appgrid:getSelection()
        local appID = _x + (_y-1) * 6

        if appID > #games then
            appgrid:selectPreviousRow(false,true)
        end

        
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        appgrid:selectPreviousRow(false,true)

    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        scroll = 0
        data = json.decodeFile("games/2024.1/"..selection.."data.json")

        local imageList = playdate.file.listFiles("games/2024.1/"..selection.."images")

        maxScroll = 0 -- gonna go eepy on this code real quic- zzzzzzzzz
        for fileID = 1, #imageList do

            print(imageList[fileID])

            if string.match(imageList[fileID], "pdt") or string.match(imageList[fileID], "-table") then
                local newImg = gfx.imagetable.new("games/2024.1/"..selection.."images/"..imageList[fileID])
                gifs[#gifs+1] = newImg
                maxScroll += newImg[1].height + 12
            else
                local newImg = gfx.image.new("games/2024.1/"..selection.."images/"..imageList[fileID])
                images[#images+1] = newImg
                maxScroll += newImg.height + 12
            end
        end

        qrTimer = gfx.generateQRCode(data.URL, 128, qrUpdate)

        gfx.pushContext(topImage)
        gfx.clear()

        imgHead:draw(0,0) -- make metadata image asdasfsdf
        gfx.drawTextAligned(data.Title, 200, 5, kTextAlignment.center)
        gfx.drawTextAligned("Loading QR...", 300, 120, kTextAlignment.center)
        gfx.drawTextAligned("Release: "..data.Release, 200, 228)
        gfx.drawTextAligned("Developer: "..data.Developer, 200, 218)

        gfx.setFont(dFont)
        gfx.drawTextInRect(data.Description, 6, 23, 188, 211)

        gfx.popContext()
        
        playdate.update = OpenUpdate
    end

    -- draw bg and app grid
    imgBackground:draw(0,0)
    appgrid:drawInRect(6,33,387,196)

    playdate.timer:updateTimers()
end

-- I'm giving up lol, fix this code if you want
qr = gfx.image.new(128,128)

function qrUpdate(qrImg, err) 
    qr = qrImg
end
-- I need to sleep
function OpenUpdate()
    gfx.clear()

    topImage:draw(0,-scroll)

    qr:drawCentered(300,120-scroll)

    local imgTop = 246
    for imageID = 1, #images do
        local image = images[imageID]
        image:drawCentered(200,(imgTop+image.height/2)-scroll)
        imgTop += image.height + 6
    end

    for imageID = 1, #gifs do
        local image = gifs[imageID]
        image[math.floor(frameCount) % #image + 1]:drawCentered(200,(imgTop+image[1].height/2)-scroll)
        imgTop += image[1].height + 6
    end

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        scroll -= 10
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        scroll += 10
    end

    local change, acceleratedChange = playdate.getCrankChange()
    scroll += acceleratedChange

    if scroll > maxScroll then scroll = maxScroll end
    if scroll < 0 then scroll = 0 end

    frameCount += 1

    if playdate.buttonJustPressed(playdate.kButtonB) or playdate.buttonJustPressed(playdate.kButtonA) then
        playdate.update = MainUpdate
        qrTimer:remove()
        qr = gfx.image.new(128,128)
        gfx.setFont(font)
        images = {} -- hopefully garbage collection finds the old images
        gifs = {}
        frameCount = 1
    end

    playdate.timer:updateTimers()
end

playdate.update = MainUpdate