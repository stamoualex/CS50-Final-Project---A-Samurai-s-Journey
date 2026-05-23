-- A Samurai's Journey {FINAL WORKING COPY :)}

local TILE_SIZE = 32
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local SPIKE_H = 10 
local TOMB_CEILING_H = 60 

local GRAVITY = 800
local JUMP_VELOCITY = -450
local MOVE_SPEED = 200

local SPRITE_ROOT_FOLDER = 'Samurai/' 
local FRAME_W_SHEET = 768         
local FRAME_H_SHEET = 128         
local FRAME_W_SINGLE = 59
local FRAME_H_SINGLE = 76 
local FRAME_INDEX_X = 0
local FRAME_INDEX_Y = 55 
local SPRITE_SCALE = 0.65 

local DRAWN_W = FRAME_W_SINGLE * SPRITE_SCALE
local DRAWN_H = FRAME_H_SINGLE * SPRITE_SCALE
local HITBOX_W = DRAWN_W - 5
local HITBOX_H = DRAWN_H
local OFFSET_X = (DRAWN_W - HITBOX_W) / 2
local OFFSET_Y = 0 

local ANIMATION_FILENAMES = {
    idle = 'Idle.png', 
    run = 'Run.png'    
}

local player = { x = 0, y = 0, vx = 0, vy = 0, isGrounded = false, w = HITBOX_W, h = HITBOX_H }
local platforms = {}
local attempts = 0
local currentLevel = 1
local currentLevelStartX = 1
local currentLevelStartY = WINDOW_HEIGHT - (TILE_SIZE + HITBOX_H) 
local levelExit = nil
local messages = nil
local isNewLevelLoad = true 
local gameFinished = false
local currentAltar = nil -- NEW: Dedicated reference for the Level 8 Altar

local animations = {}
local currentAnimation = 'idle' 
local spriteQuad = nil 
local mainFont = nil 
local winFont = nil  

local floor_color = {0.35, 0.35, 0.35} 
local lava_color = {0.8, 0.2, 0.1}     
local platform_color = {0.6, 0.6, 0.6} 
local tomb_floor_color = {0.1, 0.1, 0.1} 
local tomb_bg_color = {0.25, 0.2, 0.1} 
local spike_color = {0.5, 0.5, 0.5}      
local pedestal_color = {0.15, 0.15, 0.15} 
local altar_color = {0.7, 0.5, 0.1} 

local function checkOverlap(a_x,a_y,a_w,a_h,b_x,b_y,b_w,b_h)
    return a_x < b_x + b_w and a_x + a_w > b_x and a_y < b_y + b_h and a_y + a_h > b_y
end

local function checkSpikeOverlap(a_x, a_y, a_w, a_h, s_x, s_y, s_w, s_h)
    local SPIKE_TIP_HEIGHT = SPIKE_H 
    if a_x < s_x + s_w and a_x + a_w > s_x then
        if a_y + a_h > s_y and a_y < s_y + SPIKE_TIP_HEIGHT then
            return true
        end
    end
    return false
end

local LEVEL_DATA = {
    [1] = { 
        startX = 20,
        startY = WINDOW_HEIGHT - (TILE_SIZE + 250),
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 2 },
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=spike_color, isSpike=true }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=20, color=floor_color }, 
            { x=1, y=WINDOW_HEIGHT-180, w=120, h=12, color=platform_color },
            { x=100, y=WINDOW_HEIGHT-180, w=120, h=12, color=platform_color },
            { x=260, y=WINDOW_HEIGHT-240, w=120, h=12, color=platform_color },
            { x=420, y=WINDOW_HEIGHT-300, w=120, h=12, color=platform_color },
            { x=580, y=WINDOW_HEIGHT-360, w=120, h=12, color=platform_color },
            { x=720, y=WINDOW_HEIGHT-420, w=80, h=12, color=platform_color },
        }   
    },
    [2] = { 
        startX = 1,
        startY = WINDOW_HEIGHT - (TILE_SIZE + 200),
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 3 },
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=spike_color, isSpike=true }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=20, color=floor_color }, 
            { x=1, y=WINDOW_HEIGHT-190, w=90, h=10, color=platform_color },
            { x=1, y=WINDOW_HEIGHT-290, w=90, h=10, color=platform_color },
            { x=1, y=WINDOW_HEIGHT-390, w=90, h=10, color=platform_color },
            { x=165, y=WINDOW_HEIGHT-460, w=40, h=10, color=platform_color },
            { x=324, y=WINDOW_HEIGHT-460, w=40, h=10, color=platform_color }, 
            { x=485, y=WINDOW_HEIGHT-460, w=40, h=10, color=platform_color },
            { x=644, y=WINDOW_HEIGHT-460, w=200, h=10, color=platform_color }, 
        }
    },
    [3] = { 
        startX = 50,
        startY = WINDOW_HEIGHT - 150 - HITBOX_H, 
        exit = nil, 
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color={0.7, 0.3, 0.05}, isSpike=true }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=20, color=floor_color }, 
            { x=0, y=WINDOW_HEIGHT-150, w=150, h=40, color=platform_color }, 
            { x=WINDOW_WIDTH - 150, y=WINDOW_HEIGHT-150, w=150, h=40, color=platform_color },
        }
    },
    [4] = { 
        startX = 20, 
        startY = WINDOW_HEIGHT - 150 - HITBOX_H, 
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 5 }, 
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=lava_color, isSpike=true }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=20, color=floor_color }, 
            { x=0, y=WINDOW_HEIGHT-150, w=120, h=20, color=platform_color }, 
            { x=200, y=WINDOW_HEIGHT-250, w=80, h=15, color=platform_color },
            { x=380, y=WINDOW_HEIGHT-350, w=80, h=15, color=platform_color },
            { x=580, y=WINDOW_HEIGHT-420, w=80, h=15, color=platform_color }, 
        } 
    },
    [5] = { 
        startX = 50, 
        startY = WINDOW_HEIGHT - TILE_SIZE - 50 - HITBOX_H, 
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 6 }, 
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=lava_color, isSpike=true }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=20, color=tomb_floor_color }, 
            
            { x=0, y=WINDOW_HEIGHT - TILE_SIZE - 50, w=150, h=20, color=platform_color },
            { x=180, y=WINDOW_HEIGHT - TILE_SIZE - 150, w=80, h=20, color=platform_color },
            { x=350, y=WINDOW_HEIGHT - TILE_SIZE - 250, w=80, h=20, color=platform_color },
            { x=500, y=WINDOW_HEIGHT - TILE_SIZE - 350, w=300, h=20, color=pedestal_color },
        } 
    },
    [6] = { 
        startX = 50, 
        startY = WINDOW_HEIGHT - TILE_SIZE - HITBOX_H, 
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 7 },
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=tomb_floor_color, isSpike=false }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=TOMB_CEILING_H, color=tomb_floor_color }, 
            
            { x=150, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=80, h=10, color=tomb_floor_color, isSpike=true }, 
            { x=300, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=60, h=10, color=tomb_floor_color, isSpike=true },
            { x=500, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=120, h=10, color=tomb_floor_color, isSpike=true },
        } 
    },
    [7] = { 
        startX = 50, 
        startY = WINDOW_HEIGHT - TILE_SIZE - HITBOX_H, 
        exit = { x = WINDOW_WIDTH - 40, y = 0, w = 40, h = WINDOW_HEIGHT, target = 8 },
        platforms = {
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=tomb_floor_color, isSpike=false }, 
            { x=0, y=0, w=WINDOW_WIDTH, h=TOMB_CEILING_H, color=tomb_floor_color }, 
            
            { x=100, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=50, h=10, color=tomb_floor_color, isSpike=true },
            { x=250, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=100, h=10, color=tomb_floor_color, isSpike=true },
            { x=480, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=80, h=10, color=tomb_floor_color, isSpike=true },
            { x=650, y=WINDOW_HEIGHT - TILE_SIZE - 10, w=50, h=10, color=tomb_floor_color, isSpike=true },
        } 
    },
    [8] = { 
        startX = TILE_SIZE * 2 + 20, 
        startY = WINDOW_HEIGHT - TILE_SIZE - HITBOX_H, 
        exit = nil, 
        platforms = {
            
            { x=0, y=WINDOW_HEIGHT-TILE_SIZE, w=WINDOW_WIDTH, h=TILE_SIZE, color=tomb_floor_color, isSpike=false }, 
            
            { x=0, y=0, w=WINDOW_WIDTH, h=TOMB_CEILING_H, color=tomb_floor_color }, 
            
            
            { x=0, y=TOMB_CEILING_H, w=TILE_SIZE * 2, h=WINDOW_HEIGHT - TOMB_CEILING_H - TILE_SIZE, color=tomb_floor_color, isSpike=false },
            
            { x=WINDOW_WIDTH-TILE_SIZE * 2, y=TOMB_CEILING_H, w=TILE_SIZE * 2, h=WINDOW_HEIGHT - TOMB_CEILING_H - TILE_SIZE, color=tomb_floor_color, isSpike=false },
            
            
            { x=WINDOW_WIDTH - TILE_SIZE * 2 - 40, y=WINDOW_HEIGHT - TILE_SIZE - 60, w=40, h=60, color=altar_color, isAltar=true, isSpike=false },
        } 
    } 
}

local function loadLevel(idx)
    currentLevel = idx or 1
    platforms = {}
    levelExit = nil
    gameFinished = false
    currentAltar = nil 
    
    local data = LEVEL_DATA[currentLevel]
    if not data then
        currentLevel = 1
        data = LEVEL_DATA[1]
    end

    currentLevelStartX = data.startX
    currentLevelStartY = data.startY
    isNewLevelLoad = false 
    
    levelExit = data.exit
    
    for _, p in ipairs(data.platforms) do
        table.insert(platforms, p)
        if p.isAltar then
            currentAltar = p 
        end
    end
    
    if currentLevel >= 6 then 
        love.graphics.setBackgroundColor(tomb_bg_color) 
    elseif currentLevel >= 3 then 
        love.graphics.setBackgroundColor(0.1, 0.0, 0.0) 
    else
        love.graphics.setBackgroundColor(0.53,0.81,0.98) 
    end
end


local function resetToStart(mode)
    if mode == true then
        attempts = 1
    elseif mode ~= 'preserve' then 
        attempts = attempts + 1
        loadLevel(currentLevel) 
    end
    
    player.x = currentLevelStartX or 0
    player.y = currentLevelStartY or 0
    player.vx = 0
    player.vy = 0
    player.isGrounded = false
    
    currentAnimation = 'idle'
end


local function resolveCollisions(dt)
    player.isGrounded = false

    
    local next_x = player.x + (player.vx or 0) * dt
    
    for _, p in ipairs(platforms) do
        
        if p.isSpike then
            if checkSpikeOverlap(next_x, player.y, player.w, player.h, p.x, p.y, p.w, p.h) then
                resetToStart(); return 
            end
        end

        
        if checkOverlap(next_x, player.y, player.w, player.h, p.x, p.y, p.w, p.h) then
            if not p.isSpike then 
                if player.vx < 0 then next_x = p.x + p.w elseif player.vx > 0 then next_x = p.x - player.w end
                player.vx = 0
            end
        end
    end
    player.x = next_x


    
    local next_y = player.y + (player.vy or 0) * dt
    
    for _, p in ipairs(platforms) do
        
        if p.isSpike then
            if checkSpikeOverlap(player.x, next_y, player.w, player.h, p.x, p.y, p.w, p.h) then
                
                
                if currentLevel == 3 and p == platforms[1] then
                    isNewLevelLoad = true 
                    loadLevel(4)
                    resetToStart('preserve')
                    return 
                end

                
                resetToStart(); return 
            end
        end

        
        if checkOverlap(player.x, next_y, player.w, player.h, p.x, p.y, p.w, p.h) then
            if not p.isSpike then
                if player.vy > 0 then
                    
                    
                    next_y = p.y - player.h
                    player.vy = 0
                    player.isGrounded = true
                    
                elseif player.vy < 0 then
                    
                    next_y = p.y + p.h
                    player.vy = 0
                end
            end
        end
    end
    player.y = next_y

    
    if player.x < 0 then player.x = 0 end
    if player.x + player.w > WINDOW_WIDTH then player.x = WINDOW_WIDTH - player.w end
end

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setDefaultFilter('nearest', 'nearest')
    spriteQuad = love.graphics.newQuad(FRAME_INDEX_X, FRAME_INDEX_Y, FRAME_W_SINGLE, FRAME_H_SINGLE, FRAME_W_SHEET, FRAME_H_SHEET)
    
    local ok, errorMsg = pcall(function()
        for name, filename in pairs(ANIMATION_FILENAMES) do
            local path = 'Sprites/' .. SPRITE_ROOT_FOLDER .. filename
            local ok_img, img = pcall(love.graphics.newImage, path)
            if ok_img then animations[name] = { image = img, isFlipped = false }
            else error("Could not load sprite: " .. path .. " - " .. (img or "Unknown error")) end
        end
    end)
    if not ok then error('Error loading sprites: ' .. errorMsg) end
    
    player.w = HITBOX_W
    player.h = HITBOX_H 

    
    local fallbackFont = love.graphics.newFont(20) 
    
    
    local okf, tempFont = pcall(love.graphics.newFont, 'Fonts/PirataOne-Regular.ttf', 28)
    if okf then 
        mainFont = tempFont
    else 
        mainFont = fallbackFont 
    end
    love.graphics.setFont(mainFont) 
    
    
    local okwf, tempWinFont = pcall(love.graphics.newFont, 'Fonts/PirataOne-Regular.ttf', 40)
    if okwf then 
        winFont = tempWinFont 
    else 
        winFont = fallbackFont 
    end
    
    loadLevel(1)
    resetToStart(true)
    
    
    messages = {
        { text = 'Welcome Samurai...', color = {0.5, 0.35, 0.2} }, 
        { text = 'Press Space to jump and use arrow keys or WASD to move', color = {0.5, 0.35, 0.2} }
    }
    local f = love.graphics.getFont()
    local start_y_offset = 20 + 10 
    for i,m in ipairs(messages) do 
        m.x = f and (WINDOW_WIDTH - f:getWidth(m.text))/2 or 40
        m.y = start_y_offset + (i-1)*28 
    end
end

function love.update(dt)
    
    
    if currentLevel == 8 and currentAltar and not gameFinished then
        
        local margin = 5 
        if checkOverlap(player.x, player.y, player.w, player.h, 
                        currentAltar.x - margin, currentAltar.y - margin, 
                        currentAltar.w + margin*2, currentAltar.h + margin*2) then
            gameFinished = true 
            return
        end
    end

    if gameFinished then return end
    
    if isNewLevelLoad then
        isNewLevelLoad = false
        return 
    end

    
    player.vx = 0
    if love.keyboard.isDown('a','left') then player.vx = -MOVE_SPEED 
    elseif love.keyboard.isDown('d','right') then player.vx = MOVE_SPEED end
    
    
    if (love.keyboard.isDown('space') or love.keyboard.isDown('up')) and player.isGrounded then 
        player.vy = JUMP_VELOCITY 
        player.isGrounded = false 
    end
    
    
    if not player.isGrounded then player.vy = (player.vy or 0) + GRAVITY * dt end
    
    
    if player.vx ~= 0 then
        currentAnimation = 'run'
        if animations[currentAnimation] then
            if player.vx > 0 then animations[currentAnimation].isFlipped = false 
            elseif player.vx < 0 then animations[currentAnimation].isFlipped = true end
        end
    else
        currentAnimation = 'idle'
    end
    
    
    resolveCollisions(dt)
    
    if levelExit and checkOverlap(player.x, player.y, player.w, player.h, levelExit.x, levelExit.y, levelExit.w, levelExit.h) then
        isNewLevelLoad = true 
        loadLevel(levelExit.target)
        resetToStart('preserve')
    end
end

function love.draw()
    
    if gameFinished then
        
        love.graphics.setFont(winFont)
        love.graphics.setColor(1, 1, 1) 
        
        local win_message = "You have found the treasure..." 
        local attempt_message = "Total Attempts: " .. attempts
        
        local win_width = winFont:getWidth(win_message)
        local attempt_width = winFont:getWidth(attempt_message)
        
        local win_x = (WINDOW_WIDTH - win_width) / 2
        local win_y = WINDOW_HEIGHT/2 - 50
        
        local attempt_x = (WINDOW_WIDTH - attempt_width) / 2
        local attempt_y = WINDOW_HEIGHT/2 + 10
        
        love.graphics.print(win_message, win_x, win_y)
        love.graphics.print(attempt_message, attempt_x, attempt_y)
        love.graphics.setBackgroundColor(0, 0, 0) 
        return 
    end
    
    
    for _, p in ipairs(platforms) do 
        
        
        love.graphics.setColor(p.color) 
        love.graphics.rectangle('fill', p.x, p.y, p.w, p.h) 

        
        if p.isSpike then
            
            local isVisuallySpiky = p.color == spike_color or p.color == tomb_floor_color

            if isVisuallySpiky then
                love.graphics.setColor(0.9, 0.9, 0.9) 
                local num_spikes = math.ceil(p.w / 10) 
                
                
                for i=0, num_spikes - 1 do
                    local spike_base_x = p.x + (i * 10)
                    love.graphics.polygon('fill', 
                        spike_base_x, p.y + SPIKE_H, 
                        spike_base_x + 5, p.y,       
                        spike_base_x + 10, p.y + SPIKE_H 
                    )
                end
            end
        end
    end
    
    
    love.graphics.setColor(1,1,1)
    
    local anim = animations[currentAnimation]
    
    if anim and anim.image and spriteQuad then
        local currentImage = anim.image
        local sx = SPRITE_SCALE
        local draw_x = player.x - OFFSET_X
        
        
        if anim.isFlipped then
            sx = -SPRITE_SCALE
            draw_x = player.x + player.w + OFFSET_X 
        end
        
        love.graphics.draw(currentImage, spriteQuad, draw_x, player.y - OFFSET_Y, 0, sx, SPRITE_SCALE, 0, 0) 
        
        
        
        
    else
        love.graphics.setColor(0.7,0.2,0.2) 
        love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
        love.graphics.setColor(1,1,1)
    end
    
    
    love.graphics.setFont(mainFont) 
    
    
    if currentLevel >= 6 then
        love.graphics.setColor(1, 1, 1) 
    else
        love.graphics.setColor(0, 0, 0) 
    end
    
    love.graphics.print('Attempt: '..attempts, 10, 20 + 4) 
    love.graphics.setColor(1,1,1)
    
    if currentLevel == 1 and messages then
        for _, m in ipairs(messages) do 
            love.graphics.setColor(m.color) 
            love.graphics.print(m.text, m.x, m.y) 
        end 
        love.graphics.setColor(1,1,1)
    end

    if currentLevel == 8 and currentAltar then
        
        love.graphics.setColor(1, 0.8, 0.4, 1) 
        local message = "THE SAMURAI'S REST"
        love.graphics.print(message, 10, TOMB_CEILING_H + 10) 
        
        
        local altar_text = "ALTAR"
        love.graphics.setColor(1, 1, 1) 
        
        local text_x = currentAltar.x + (currentAltar.w - mainFont:getWidth(altar_text)) / 2 
        local text_y = currentAltar.y - 28 
        love.graphics.print(altar_text, text_x, text_y)
        
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
end