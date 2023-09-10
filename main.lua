local verlet = require("verlet")
local vector = require("vector")
require("color")

local asc = 0
local delta = 0
curtime = 0

local scrw,scrh = love.window.getDesktopDimensions(1)
love.window.setMode( scrw/1.2, scrh/1.2, {
    vsync = 1,
    msaa = 1,
    resizable = 1
})

local function makeExplode(x,y)
    local pos = vector(x,y)
    for i=1, #objects do
        local vel = (objects[i].pos - pos):normalizeInplace()
        local dist = pos.dist(objects[i].pos, pos)

        objects[i]:addVelocity(vel * -dist, delta)
    end
end

local function crtObj(x,y)
    asc = asc + 1
    objects[asc] = verlet.new()
    objects[asc]:setPos(vector(x,y))
    objects[asc].radius = math.floor(math.random(5,15))
    local r,g,b = hsvToRgb(curtime/1000,0.8,1,1)
    objects[asc].color = {r/255,g/255,b/255}
    local pos,radius = verlet.getConstraint()
    --local x1,y1 = love.mouse.getPosition()
    local vel = ((pos + vector(math.sin(curtime/50)*radius,math.cos(curtime/50)*radius)) - pos):normalizeInplace()
    --local vel = (vector(x1,y1) - vector(x,y)):normalizeInplace()
    objects[asc]:setVelocity(vel * 1000, delta)
end

function love.load()
    objects = {}
end

function love.update(dt)
    delta = dt

    if #objects < 600 then
        local w,h = love.graphics.getDimensions()
        crtObj(w/2,(h/2)-150)
    end

    curtime = curtime + 1
    verlet.update(dt,objects)
end

function love.draw()
    verlet.draw(objects)

    love.graphics.print("FPS: " .. love.timer.getFPS() .. " Objects: " .. #objects,5,5)
end