local verlet = {}

verlet.vector = require("vector")
verlet.gravity = verlet.vector(0,1000)

function verlet.NextPosition(pos,vel)
    return pos + vel
end

function verlet.new()
    local obj = {
        pos = verlet.vector(0,0),
        posold = verlet.vector(0,0),
        acceleration = verlet.vector(0,0),
        radius = 10,
        color = {1,1,1},
    }

    function obj:setPos(pos)
        self.pos = pos
        self.posold = pos
    end

    function obj:setVelocity(vel, dt)
        self.posold = self.pos - (vel * dt)
    end

    function obj:addVelocity(vel, dt)
        self.posold = self.posold - vel * dt
    end

    function obj:updatePosition(dt)
        local velocity = self.pos - self.posold
        -- Save current position
        self.posold = self.pos
        -- Perform verlet integration
        self.pos = self.pos + velocity + self.acceleration * (dt * dt)
        -- Reset acceleration
        self.acceleration = verlet.vector(0,0)
    end

    function obj:accelerate(acc)
        self.acceleration = self.acceleration + acc
    end

    return obj
end

function verlet.getConstraint()
    local w,h = love.graphics.getDimensions()
    local pos = verlet.vector(w/2,h/2)
    local radius = 400

    return pos,radius
end

function verlet.applyConstraint(object)
    local pos,radius = verlet.getConstraint()

    local toobj = object.pos - pos
    local dist = toobj:len()
    if dist > (radius - object.radius) then
        local n = toobj / dist
        object.pos = pos + n * (radius - object.radius)
    end
end

function verlet.solveCollisions(objects)
    for i=1, #objects do
        for i2=i+1, #objects do
            local collision_axis = objects[i].pos - objects[i2].pos
            local dist = collision_axis:len()
            local min_dist = objects[i].radius + objects[i2].radius
            if dist < min_dist then
                local n = collision_axis / dist
                local delta = min_dist - dist
                objects[i].pos = objects[i].pos + 0.5 * delta * n
                objects[i2].pos = objects[i2].pos - 0.5 * delta * n
            end
        end
    end
end

function verlet.update(dt,objects)
    -- 8 substeps very laggy on 600~ objects
    -- this need grid perfomance
    local substeps = 2
    local subdt = dt / substeps
    for i=1, substeps do
        for i=1, #objects do
            objects[i]:accelerate(verlet.gravity)
            verlet.applyConstraint(objects[i])
            objects[i]:updatePosition(subdt)
        end
        verlet.solveCollisions(objects)
    end
end

function verlet.draw(objects)
    local pos,radius = verlet.getConstraint()
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.circle("fill", pos.x, pos.y, radius)
    for i=1, #objects do
        local pos = objects[i].pos
        local color = objects[i].color

        love.graphics.setColor(color[1],color[2],color[3],1)
        love.graphics.circle("fill", pos.x, pos.y, objects[i].radius)
    end
end

return verlet