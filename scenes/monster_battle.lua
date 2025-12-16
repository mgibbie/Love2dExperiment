-- Monster Battle Scene
-- Main battle UI for Pokemon battles

local battleState = require('data.monster.battleState')
local pokemonBuilder = require('data.monster.pokemonBuilder')
local monsterAI = require('data.monster.monsterAI')
local types = require('data.monster.types')
local pokemonUI = require('ui.pokemon_ui')
local spriteLoader = require('data.monster.spriteLoader')
local battleAnim = require('ui.battle_anim')

local battle = {}

-- Colors
local colors = {
    background = {0.05, 0.08, 0.12},
    backgroundGrad = {0.1, 0.14, 0.2},
    text = {0.85, 0.9, 0.95},
    panelBg = {0.08, 0.1, 0.14, 0.9}
}

-- State
local state = nil
local phase = 'select_move'
local hoveredMove, hoveredSwitch, hoveredButton = nil, nil, nil
local moveButtons, switchButtons = {}, {}
local actionButtons = {
    fight = { x = 0, y = 0, width = 140, height = 45, label = "Fight" },
    switch = { x = 0, y = 0, width = 140, height = 45, label = "Switch" },
    run = { x = 0, y = 0, width = 140, height = 45, label = "Run" }
}

-- Sprite positions (for animations)
local playerSpriteX, playerSpriteY = 0, 0
local enemySpriteX, enemySpriteY = 0, 0

-- Pending turn data
local pendingPlayerMove = nil
local pendingEnemyMove = nil

function battle.load()
    battleAnim.init()
end

function battle.enter()
    local playerTeam = _G.monsterPlayerTeam
    if not playerTeam then switchScene("monster_menu") return end
    
    local battleNum = _G.monsterBattleNumber or 1
    local enemyLevel = 45 + battleNum * 2
    local enemyTeam = pokemonBuilder.buildRandomTeam(6, enemyLevel)
    
    state = battleState.create(playerTeam, enemyTeam)
    phase = 'select_move'
    hoveredMove, hoveredSwitch, hoveredButton = nil, nil, nil
    pendingPlayerMove = nil
    pendingEnemyMove = nil
    
    battleAnim.reset()
    
    battleState.log(state, "Battle " .. battleNum .. " begins!")
    battleState.log(state, "Enemy sent out " .. state.enemy.active.name .. "!")
    battleState.log(state, "Go, " .. state.player.active.name .. "!")
end

function battle.exit()
    battleAnim.reset()
end

function battle.update(dt)
    battleAnim.update(dt)
end

-- Status effect overlay icons
local statusIcons = {
    paralysis = { symbol = "⚡", color = {0.95, 0.85, 0.2} },
    burn = { symbol = "🔥", color = {0.95, 0.4, 0.2} },
    poison = { symbol = "☠", color = {0.7, 0.3, 0.8} },
    badpoison = { symbol = "☠", color = {0.9, 0.2, 0.9} },
    sleep = { symbol = "💤", color = {0.6, 0.6, 0.8} },
    freeze = { symbol = "❄", color = {0.4, 0.8, 0.95} }
}

-- Draw status effect indicator above Pokemon sprite
function battle.drawStatusOverlay(pokemon, x, y, alpha)
    if not pokemon.status then return end
    
    local statusData = statusIcons[pokemon.status]
    if not statusData then return end
    
    alpha = alpha or 1
    
    -- Pulsing animation
    local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 3)
    
    -- Background circle
    love.graphics.setColor(0, 0, 0, 0.6 * alpha)
    love.graphics.circle('fill', x, y, 14)
    
    -- Colored ring
    love.graphics.setColor(statusData.color[1], statusData.color[2], statusData.color[3], alpha * pulse)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', x, y, 14)
    
    -- Symbol (using text fallback since emoji support varies)
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    love.graphics.setColor(statusData.color[1], statusData.color[2], statusData.color[3], alpha)
    
    -- Simple letter indicators instead of emoji
    local labels = {
        paralysis = "P", burn = "B", poison = "X", badpoison = "TX", sleep = "Z", freeze = "F"
    }
    local label = labels[pokemon.status] or "?"
    local tw = font:getWidth(label)
    love.graphics.print(label, x - tw/2, y - 6)
end

function battle.draw()
    if not state then return end
    local w, h = love.graphics.getDimensions()
    
    -- Background
    for i = 0, h do
        local t = i / h
        love.graphics.setColor(
            colors.background[1] + (colors.backgroundGrad[1] - colors.background[1]) * t,
            colors.background[2] + (colors.backgroundGrad[2] - colors.background[2]) * t,
            colors.background[3] + (colors.backgroundGrad[3] - colors.background[3]) * t
        )
        love.graphics.line(0, i, w, i)
    end
    
    -- Battle number
    local titleFont = love.graphics.newFont(18)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
    love.graphics.print("Battle " .. (_G.monsterBattleNumber or 1) .. " / 10", 20, 15)
    
    -- Calculate sprite positions
    local fieldCenterX = w / 2
    enemySpriteX = fieldCenterX + 120
    enemySpriteY = 130
    playerSpriteX = fieldCenterX - 120
    playerSpriteY = h - 350
    
    -- Get animation offsets
    local playerOffX, playerOffY = battleAnim.getAttackerOffset(true)
    local enemyOffX, enemyOffY = battleAnim.getAttackerOffset(false)
    local playerShakeX, playerShakeY = battleAnim.getDefenderShake(true)
    local enemyShakeX, enemyShakeY = battleAnim.getDefenderShake(false)
    
    -- Get switch animation offsets
    local playerSwitchX, playerSwitchY, playerAlpha = battleAnim.getSwitchOffset(true)
    local enemySwitchX, enemySwitchY, enemyAlpha = battleAnim.getSwitchOffset(false)
    
    -- Apply offsets
    local pX = playerSpriteX + playerOffX + playerShakeX + playerSwitchX
    local pY = playerSpriteY + playerOffY + playerShakeY + playerSwitchY
    local eX = enemySpriteX + enemyOffX + enemyShakeX + enemySwitchX
    local eY = enemySpriteY + enemyOffY + enemyShakeY + enemySwitchY
    
    -- Enemy Pokemon sprite (top right area)
    local enemyTypeColor = types.colors[state.enemy.active.types[1]] or {0.5, 0.5, 0.5}
    love.graphics.setColor(enemyTypeColor[1], enemyTypeColor[2], enemyTypeColor[3], 0.15 * enemyAlpha)
    love.graphics.circle('fill', eX, eY, 70)
    love.graphics.setColor(enemyTypeColor[1], enemyTypeColor[2], enemyTypeColor[3], 0.4 * enemyAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', eX, eY, 70)
    spriteLoader.drawSprite(state.enemy.active, eX, eY, 1.0, {maxSize = 120, alpha = enemyAlpha})
    battle.drawStatusOverlay(state.enemy.active, eX, eY - 70, enemyAlpha)
    
    -- Player Pokemon sprite (bottom left area) - uses back sprite
    local playerTypeColor = types.colors[state.player.active.types[1]] or {0.5, 0.5, 0.5}
    love.graphics.setColor(playerTypeColor[1], playerTypeColor[2], playerTypeColor[3], 0.15 * playerAlpha)
    love.graphics.circle('fill', pX, pY, 80)
    love.graphics.setColor(playerTypeColor[1], playerTypeColor[2], playerTypeColor[3], 0.4 * playerAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', pX, pY, 80)
    spriteLoader.drawSprite(state.player.active, pX, pY, 1.0, {maxSize = 140, back = true, alpha = playerAlpha})
    battle.drawStatusOverlay(state.player.active, pX, pY - 85, playerAlpha)
    
    -- Draw animations (boom effects)
    battleAnim.draw()
    
    -- Pokemon statuses
    pokemonUI.drawPokemonStatus(state.enemy.active, w - 320, 50, 300)
    pokemonUI.drawTeamBar(state.enemy.team, w - 310, 145, state.enemy.activeIndex)
    pokemonUI.drawPokemonStatus(state.player.active, 20, h - 280, 300)
    pokemonUI.drawTeamBar(state.player.team, 30, h - 195, state.player.activeIndex)
    
    -- Battle log
    pokemonUI.drawBattleLog(state.log, 20, 180, 300, h - 480)
    
    -- Action panel (hide during animations)
    local panelY = h - 170
    love.graphics.setColor(colors.panelBg)
    love.graphics.rectangle('fill', 340, panelY, w - 360, 160, 8, 8)
    love.graphics.setColor(pokemonUI.colors.buttonBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 340, panelY, w - 360, 160, 8, 8)
    
    if battleAnim.isAnimating() then
        -- Show "animating" message
        love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
        local animFont = love.graphics.newFont(16)
        love.graphics.setFont(animFont)
        love.graphics.print("...", 360, panelY + 70)
    elseif phase == 'select_move' then
        battle.drawMoveSelection(panelY, w)
    elseif phase == 'select_switch' or phase == 'forced_switch' then
        battle.drawSwitchSelection(panelY, w, phase == 'forced_switch')
    end
    
    -- Victory/Defeat overlay
    if state.phase == battleState.PHASES.PLAYER_WIN or state.phase == battleState.PHASES.ENEMY_WIN then
        battle.drawGameOver(w, h)
    end
end

function battle.drawMoveSelection(panelY, w)
    local moveWidth, moveHeight = 200, 60
    local startX, startY = 360, panelY + 20
    
    moveButtons = {}
    for i, move in ipairs(state.player.active.moves) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local mx = startX + col * (moveWidth + 15)
        local my = startY + row * (moveHeight + 10)
        
        moveButtons[i] = { x = mx, y = my, width = moveWidth, height = moveHeight, move = move }
        pokemonUI.drawMoveButton(move, mx, my, moveWidth, moveHeight, hoveredMove == i, move.pp == 0)
    end
    
    actionButtons.switch.x = w - 170
    actionButtons.switch.y = panelY + 30
    pokemonUI.drawActionButton(actionButtons.switch, hoveredButton == 'switch')
    
    actionButtons.run.x = w - 170
    actionButtons.run.y = panelY + 90
    pokemonUI.drawActionButton(actionButtons.run, hoveredButton == 'run')
end

function battle.drawSwitchSelection(panelY, w, isForced)
    love.graphics.setColor(colors.text)
    love.graphics.setFont(love.graphics.newFont(16))
    local prompt = isForced and "Choose a Pokemon to send out:" or "Choose a Pokemon:"
    love.graphics.print(prompt, 360, panelY + 10)
    
    switchButtons = {}
    local btnW, btnH, startX, startY = 180, 50, 360, panelY + 40
    
    for i, pokemon in ipairs(state.player.team) do
        if not pokemon.fainted and pokemon ~= state.player.active then
            local col, row = #switchButtons % 4, math.floor(#switchButtons / 4)
            local bx, by = startX + col * 190, startY + row * 60
            table.insert(switchButtons, {x=bx, y=by, width=btnW, height=btnH, index=i, pokemon=pokemon})
            local hov = hoveredSwitch == #switchButtons
            local tc = types.colors[pokemon.types[1]] or pokemonUI.colors.buttonBorder
            love.graphics.setColor(hov and pokemonUI.colors.buttonHover or pokemonUI.colors.buttonBg)
            love.graphics.rectangle('fill', bx, by, btnW, btnH, 6, 6)
            love.graphics.setColor(hov and tc or pokemonUI.colors.buttonBorder)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle('line', bx, by, btnW, btnH, 6, 6)
            love.graphics.setColor(colors.text)
            love.graphics.setFont(love.graphics.newFont(13))
            love.graphics.print(pokemon.name, bx + 10, by + 8)
            love.graphics.setColor(pokemonUI.getHPColor(pokemon.currentHP, pokemon.maxHP))
            love.graphics.rectangle('fill', bx+10, by+30, (btnW-20)*pokemon.currentHP/pokemon.maxHP, 10, 3, 3)
        end
    end
    
    -- Only show Back button if not forced
    if not isForced then
        actionButtons.fight.x, actionButtons.fight.y, actionButtons.fight.label = w-170, panelY+90, "Back"
        pokemonUI.drawActionButton(actionButtons.fight, hoveredButton == 'back')
    end
end

function battle.drawGameOver(w, h)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 0, 0, w, h)
    local isWin = state.phase == battleState.PHASES.PLAYER_WIN
    local resultFont = love.graphics.newFont(48)
    love.graphics.setFont(resultFont)
    love.graphics.setColor(isWin and pokemonUI.colors.hpGreen or pokemonUI.colors.hpRed)
    local text = isWin and "VICTORY!" or "DEFEAT"
    love.graphics.print(text, (w - resultFont:getWidth(text)) / 2, h / 2 - 80)
    local btnX, btnY, btnLabel = (w-200)/2, h/2+20, isWin and 'continue' or 'retry'
    love.graphics.setColor(hoveredButton==btnLabel and pokemonUI.colors.buttonHover or pokemonUI.colors.buttonBg)
    love.graphics.rectangle('fill', btnX, btnY, 200, 50, 8, 8)
    love.graphics.setColor(pokemonUI.colors.accent)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', btnX, btnY, 200, 50, 8, 8)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(colors.text)
    local btnText = isWin and "Continue" or "Try Again"
    love.graphics.print(btnText, btnX + (200 - love.graphics.getFont():getWidth(btnText)) / 2, btnY + 12)
    actionButtons[btnLabel] = { x = btnX, y = btnY, width = 200, height = 50 }
end

-- Execute turn with animations (sequential attacks)
function battle.executeAnimatedTurn(playerMove, enemyMove)
    state.turnCount = state.turnCount + 1
    battleState.log(state, "--- Turn " .. state.turnCount .. " ---")
    
    local playerPokemon = state.player.active
    local enemyPokemon = state.enemy.active
    
    -- Determine turn order
    local playerPriority = playerMove.priority or 0
    local enemyPriority = enemyMove.priority or 0
    local playerFirst = false
    
    if playerPriority > enemyPriority then
        playerFirst = true
    elseif playerPriority < enemyPriority then
        playerFirst = false
    else
        local damageCalc = require('data.monster.damageCalc')
        local playerSpeed = damageCalc.getEffectiveStat(playerPokemon, 'spe')
        local enemySpeed = damageCalc.getEffectiveStat(enemyPokemon, 'spe')
        playerFirst = playerSpeed >= enemySpeed or (playerSpeed == enemySpeed and math.random(1, 2) == 1)
    end
    
    -- Store moves for animation callbacks
    pendingPlayerMove = playerMove
    pendingEnemyMove = enemyMove
    
    -- Queue first attack
    if playerFirst then
        battle.queuePlayerAttack(function()
            -- After player attack, queue enemy attack if not fainted
            if not state.enemy.active.fainted then
                battle.queueEnemyAttack(function()
                    battle.onTurnComplete()
                end)
            else
                battle.onTurnComplete()
            end
        end)
    else
        battle.queueEnemyAttack(function()
            -- After enemy attack, queue player attack if not fainted
            if not state.player.active.fainted then
                battle.queuePlayerAttack(function()
                    battle.onTurnComplete()
                end)
            else
                battle.onTurnComplete()
            end
        end)
    end
end

function battle.queuePlayerAttack(onComplete)
    battleAnim.queueAction({
        type = "attack",
        isPlayer = true,
        attackerX = playerSpriteX,
        attackerY = playerSpriteY,
        defenderX = enemySpriteX,
        defenderY = enemySpriteY,
        onExecute = function()
            battleState.executeMove(state, state.player.active, state.enemy.active, pendingPlayerMove, true)
        end,
        onComplete = onComplete
    })
end

function battle.queueEnemyAttack(onComplete)
    battleAnim.queueAction({
        type = "attack",
        isPlayer = false,
        attackerX = enemySpriteX,
        attackerY = enemySpriteY,
        defenderX = playerSpriteX,
        defenderY = playerSpriteY,
        onExecute = function()
            battleState.executeMove(state, state.enemy.active, state.player.active, pendingEnemyMove, false)
        end,
        onComplete = onComplete
    })
end

-- Execute animated switch (player switches, then enemy attacks)
function battle.executeAnimatedSwitch(newIndex)
    state.turnCount = state.turnCount + 1
    battleState.log(state, "--- Turn " .. state.turnCount .. " ---")
    
    -- Get enemy's move before switching
    local aiAction = monsterAI.getAction(state)
    pendingEnemyMove = aiAction.move
    
    -- Queue switch out animation
    battleAnim.queueAction({
        type = "switch_out",
        isPlayer = true,
        onExecute = function()
            -- Actually perform the switch after exit animation
            battleState.switchPokemon(state, true, newIndex)
        end,
        onComplete = function()
            -- Queue switch in animation
            battleAnim.queueAction({
                type = "switch_in",
                isPlayer = true,
                onComplete = function()
                    -- After switch completes, enemy attacks
                    if pendingEnemyMove and not state.player.active.fainted then
                        battle.queueEnemyAttack(function()
                            battle.onTurnComplete()
                        end)
                    else
                        battle.onTurnComplete()
                    end
                end
            })
        end
    })
end

function battle.onTurnComplete()
    pendingPlayerMove = nil
    pendingEnemyMove = nil
    
    -- Process end-of-turn effects (burn, poison damage)
    if state.phase == battleState.PHASES.SELECT_ACTION then
        battleState.processEndOfTurn(state)
    end
    
    -- Check for required switches (after faint from status damage or attacks)
    if state.phase == battleState.PHASES.SWITCH_POKEMON then
        phase = 'forced_switch'  -- Different phase for forced switch (no enemy attack after)
    elseif state.phase == battleState.PHASES.ENEMY_SWITCHING then
        -- Enemy Pokemon fainted, play switch-in animation for next enemy
        battle.executeEnemySwitchIn()
    elseif state.phase == battleState.PHASES.SELECT_ACTION then
        phase = 'select_move'
    end
end

-- Execute enemy switch-in animation after their Pokemon faints
function battle.executeEnemySwitchIn()
    local newIndex = state.pendingEnemySwitch
    if not newIndex then
        state.phase = battleState.PHASES.SELECT_ACTION
        phase = 'select_move'
        return
    end
    
    -- Perform the actual switch
    battleState.switchPokemon(state, false, newIndex)
    state.pendingEnemySwitch = nil
    
    -- Queue switch-in animation for enemy
    battleAnim.queueAction({
        type = "switch_in",
        isPlayer = false,
        onComplete = function()
            state.phase = battleState.PHASES.SELECT_ACTION
            phase = 'select_move'
        end
    })
end

-- Execute forced switch after faint (no enemy attack)
function battle.executeForcedSwitch(newIndex)
    -- Queue switch in animation (old Pokemon already fainted, no switch out needed)
    battleState.switchPokemon(state, true, newIndex)
    
    battleAnim.queueAction({
        type = "switch_in",
        isPlayer = true,
        onComplete = function()
            state.phase = battleState.PHASES.SELECT_ACTION
            phase = 'select_move'
        end
    })
end

function battle.mousemoved(x, y)
    if not state or battleAnim.isAnimating() then return end
    hoveredMove, hoveredSwitch, hoveredButton = nil, nil, nil
    local w, h = love.graphics.getDimensions()
    
    -- Game over buttons
    if state.phase == battleState.PHASES.PLAYER_WIN then
        local btn = actionButtons.continue
        if btn and x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            hoveredButton = 'continue'
        end
        return
    elseif state.phase == battleState.PHASES.ENEMY_WIN then
        local btn = actionButtons.retry
        if btn and x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            hoveredButton = 'retry'
        end
        return
    end
    
    if phase == 'select_move' then
        for i, btn in ipairs(moveButtons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                hoveredMove = i
                break
            end
        end
        for _, name in ipairs({'switch', 'run'}) do
            local btn = actionButtons[name]
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                hoveredButton = name
            end
        end
    elseif phase == 'select_switch' or phase == 'forced_switch' then
        for i, btn in ipairs(switchButtons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                hoveredSwitch = i
                break
            end
        end
        -- Only check back button if not forced
        if phase == 'select_switch' then
            local backBtn = actionButtons.fight
            if x >= backBtn.x and x <= backBtn.x + backBtn.width and y >= backBtn.y and y <= backBtn.y + backBtn.height then
                hoveredButton = 'back'
            end
        end
    end
end

function battle.mousepressed(x, y, button) end

function battle.mousereleased(x, y, button)
    if not state or button ~= 1 or battleAnim.isAnimating() then return end
    
    -- Game over buttons
    if state.phase == battleState.PHASES.PLAYER_WIN and hoveredButton == 'continue' then
        local battleNum = _G.monsterBattleNumber or 1
        if battleNum >= 10 then
            switchScene("monster_menu")
        else
            _G.monsterBattleNumber = battleNum + 1
            switchScene("monster_heal")
        end
        return
    end
    if state.phase == battleState.PHASES.ENEMY_WIN and hoveredButton == 'retry' then
        switchScene("monster_menu")
        return
    end
    
    if phase == 'select_move' then
        if hoveredMove and moveButtons[hoveredMove] then
            local move = moveButtons[hoveredMove].move
            if move.pp > 0 then
                local aiAction = monsterAI.getAction(state)
                if aiAction.move then
                    -- Use animated turn execution
                    battle.executeAnimatedTurn(move, aiAction.move)
                end
            end
        end
        if hoveredButton == 'switch' then phase = 'select_switch' end
        if hoveredButton == 'run' then switchScene("monster_menu") end
    elseif phase == 'select_switch' then
        if hoveredSwitch and switchButtons[hoveredSwitch] then
            local switchData = switchButtons[hoveredSwitch]
            battle.executeAnimatedSwitch(switchData.index)
        end
        if hoveredButton == 'back' then
            phase = 'select_move'
            actionButtons.fight.label = "Fight"
        end
    elseif phase == 'forced_switch' then
        if hoveredSwitch and switchButtons[hoveredSwitch] then
            local switchData = switchButtons[hoveredSwitch]
            battle.executeForcedSwitch(switchData.index)
        end
    end
end

function battle.keypressed(key) if key == "escape" then switchScene("monster_menu") end end
function battle.resize() end
return battle
