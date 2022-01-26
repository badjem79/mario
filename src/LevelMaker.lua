--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}
    
    local tmpBlocks = {}
    
    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 then

                -- jump block
                local block = GameObject {
                    texture = 'jump-blocks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = math.random(#JUMP_BLOCKS),
                    collidable = true,
                    hit = false,
                    solid = true,

                    -- collision function takes itself
                    onCollide = function(obj)

                        -- spawn a gem if we haven't already hit the block
                        if not obj.hit then

                            -- chance to spawn gem, not guaranteed
                            if math.random(3) == 1 then

                                -- maintain reference so we can set it to nil
                                local gem = GameObject {
                                    texture = 'gems',
                                    x = (x - 1) * TILE_SIZE,
                                    y = (blockHeight - 1) * TILE_SIZE - 4,
                                    width = 16,
                                    height = 16,
                                    frame = math.random(#GEMS),
                                    collidable = true,
                                    consumable = true,
                                    solid = false,

                                    -- gem has its own function to add to the player's score
                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        player.score = player.score + 100
                                    end
                                }
                                
                                -- make the gem move up from the block and play a sound
                                Timer.tween(0.1, {
                                    [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                })
                                gSounds['powerup-reveal']:play()

                                table.insert(objects, gem)
                            end

                            obj.hit = true
                        end

                        gSounds['empty-block']:play()
                    end
                }
            
                table.insert(tmpBlocks, block)
                table.insert(objects, block)
            end
        end
    end

    -- add a key spawner to one random block
    local randomBlock = tmpBlocks[math.random( #tmpBlocks )];
    randomBlock.onCollide = function(obj)
        -- spawn a key if we haven't already hit the block
        if not obj.hit then
            local key = GameObject {
                texture = 'keys',
                x = randomBlock.x,
                y = randomBlock.y - 4,
                width = 16,
                height = 16,
                frame = math.random(#KEYS),
                collidable = true,
                consumable = true,
                solid = false,

                -- key has its own function to add to the player's inventory
                onConsume = function(player, object)
                    gSounds['pickup']:play()
                    
                    -- set position to top
                    object.x = (VIRTUAL_WIDTH / 4)
                    object.y = 4
                    player.key = object
                end
            }
            
            -- make the key move up from the block and play a sound
            Timer.tween(0.2, {
                [key] = {y = randomBlock.y - TILE_SIZE}
            })
            gSounds['powerup-reveal']:play()

            table.insert(objects, key)
            obj.hit = true
        end
    end

---[[
    local xposition = 0
    local yposition = 0
    for x = width - 9, width do
        local isEmpty = true
        for y = 1, height do
            if tiles[y][x].id ~= TILE_ID_EMPTY then
                isEmpty = false
                yposition = y - 1
                break
            end
        end
        if not isEmpty then
            xposition = x - 1;
            break
        end
    end
--]]
    -- ADD a LOCK block near the ground
    table.insert(objects,
        GameObject {
            texture = 'locks',
            x = xposition * TILE_SIZE,
            y = (yposition - 3) * TILE_SIZE,
            width = 16,
            height = 16,
            frame = math.random(#LOCKS),
            collidable = true,
            consumable = false,
            solid = true,
            hit = false,
            onCollide = function(obj, player)
                if obj.hit == false then
                    if player.key then

                        local xposition = 0
                        local yposition = 0
                        for x = width-2, 0, -1 do
                            local isEmpty = true
                            for y = 1, height do
                                if tiles[y][x].id ~= TILE_ID_EMPTY then
                                    isEmpty = false
                                    yposition = y - 1
                                    break
                                end
                            end
                            if not isEmpty then
                                xposition = x - 1;
                                break
                            end
                        end

                        local pole = GameObject {
                            texture = 'poles',
                            x = xposition * TILE_SIZE,
                            y = yposition * TILE_SIZE,
                            width = 16, 
                            height = 48,
                            frame = math.random(#POLES),
                            collidable = true,
                            consumable = true,
                            solid = false,
                            notRemovable = true,
                            onConsume = function(player, obj)
                                gStateMachine:change('win', {
                                    levelN = gStateMachine.current.levelN,
                                    score = player.score,
                                    camX = gStateMachine.current.camX,
                                    camY = gStateMachine.current.camY,
                                    level = gStateMachine.current.level,
                                    background = gStateMachine.current.background,
                                    backgroundX = gStateMachine.current.backgroundX
                                })
                            end
                        }
                        local flag = GameObject {
                            texture = 'flags',
                            x = xposition * TILE_SIZE + (TILE_SIZE/2),
                            y = yposition * TILE_SIZE,
                            width = 16,
                            height = 16,
                            frame = math.random(#FLAGS),
                            collidable = true,
                            consumable = true,
                            solid = false,
                            notRemovable = true,
                            onConsume = function(player, obj)
                                gStateMachine:change('win', {
                                    levelN = gStateMachine.current.levelN,
                                    score = player.score,
                                    camX = gStateMachine.current.camX,
                                    camY = gStateMachine.current.camY,
                                    level = gStateMachine.current.level,
                                    background = gStateMachine.current.background,
                                    backgroundX = gStateMachine.current.backgroundX
                                })
                            end
                        }
                        
                        Timer.tween(0.2, {
                            [pole] = {y = (yposition - 3) * TILE_SIZE},
                            [flag] = {y = (yposition - 3) * TILE_SIZE}
                        })

                        -- add pole and flag
                        table.insert(objects, pole)
                        table.insert(objects, flag)

                        player.key = nil
                        obj.hit = true
                        gSounds['pickup']:play()
                    else
                        gSounds['empty-block']:play()
                    end
                end
            end
        }
    )

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end