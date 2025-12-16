-- Battlecards Scene
-- Main battle screen for the card game

local battleState = require('data.battleState')
local battleAI = require('data.battleAI')
local handUI = require('ui.hand')
local boardUI = require('ui.board')
local cardUI = require('ui.card')
local tooltip = require('ui.tooltip')

local battlecards = {}

-- Game state
local state = nil

-- UI state
local hoveredHandCard = nil
local hoveredPlayerCreature = nil
local hoveredEnemyCreature = nil
local hoveredPlayerHero = false
local hoveredEnemyHero = false
local hoveredPlacementSlot = nil
local placingCard = nil
local mouseX, mouseY = 0, 0

-- Colors
local colors = {
    background = {0.06, 0.03, 0.1},
    backgroundGrad = {0.1, 0.05, 0.15},
    text = {0.9, 0.85, 0.75},
    accent = {0.3, 0.85, 0.9},
    divider = {0.2, 0.15, 0.25},
    button = {0.15, 0.1, 0.2},
    buttonHover = {0.25, 0.15, 0.3},
    buttonBorder = {0.5, 0.4, 0.6}
}

-- Buttons
local endTurnButton = { x = 0, y = 0, width = 120, height = 40, hovered = false, pressed = false }
local backButton = { x = 10, y = 10, width = 80, height = 30, hovered = false, pressed = false }
local restartButton = { x = 0, y = 0, width = 140, height = 50, hovered = false, pressed = false }

-- Helper functions
local function isPointInRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.width and y >= rect.y and y <= rect.y + rect.height
end

local function drawButton(btn, text)
    love.graphics.setColor(btn.hovered and colors.buttonHover or colors.button)
    love.graphics.rectangle('fill', btn.x, btn.y, btn.width, btn.height, 6, 6)
    love.graphics.setColor(colors.buttonBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', btn.x, btn.y, btn.width, btn.height, 6, 6)
    love.graphics.setColor(colors.text)
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    local tw = font:getWidth(text)
    love.graphics.print(text, btn.x + (btn.width - tw) / 2, btn.y + (btn.height - font:getHeight()) / 2)
end

local function drawBattleLog()
    local w, h = love.graphics.getDimensions()
    local logX, logY, logW, logH = 10, h/2 - 80, 200, 160
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', logX, logY, logW, logH, 4, 4)
    love.graphics.setColor(0.3, 0.25, 0.35, 0.6)
    love.graphics.rectangle('line', logX, logY, logW, logH, 4, 4)
    
    local font = love.graphics.newFont(10)
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.75, 0.7)
    
    local lineH, maxLines = 12, math.floor((logH - 10) / 12)
    local start = math.max(1, #state.log - maxLines + 1)
    for i = start, #state.log do
        local msg = state.log[i]
        if #msg > 30 then msg = msg:sub(1, 27) .. "..." end
        love.graphics.print(msg, logX + 5, logY + 5 + (i - start) * lineH)
    end
end

function battlecards.load() end

function battlecards.enter()
    state = battleState.create()
    battleState.initBattle(state, 'centurion')
    battleAI.resetTurnState()
    hoveredHandCard, hoveredPlayerCreature, hoveredEnemyCreature = nil, nil, nil
    hoveredPlayerHero, hoveredEnemyHero, hoveredPlacementSlot, placingCard = false, false, nil, nil
end

function battlecards.exit()
    state = nil
end

function battlecards.update(dt)
    if not state then return end
    local w, h = love.graphics.getDimensions()
    
    endTurnButton.x, endTurnButton.y = w - 140, h / 2 - 20
    restartButton.x, restartButton.y = (w - 140) / 2, h / 2 + 50
    
    if state.phase == battleState.PHASES.ENEMY_TURN then
        battleAI.processEnemyTurn(state, battleState, dt)
    end
end

function battlecards.draw()
    if not state then return end
    local w, h = love.graphics.getDimensions()
    
    -- Background gradient
    for i = 0, h do
        local t = i / h
        love.graphics.setColor(
            colors.background[1] + (colors.backgroundGrad[1] - colors.background[1]) * t,
            colors.background[2] + (colors.backgroundGrad[2] - colors.background[2]) * t,
            colors.background[3] + (colors.backgroundGrad[3] - colors.background[3]) * t
        )
        love.graphics.line(0, i, w, i)
    end
    
    -- Title and divider
    love.graphics.setColor(colors.text)
    local titleFont = love.graphics.newFont(20)
    love.graphics.setFont(titleFont)
    love.graphics.print("Battle Cards", w/2 - 50, 5)
    love.graphics.setColor(colors.divider[1], colors.divider[2], colors.divider[3], 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.line(100, h/2, w - 100, h/2)
    
    -- Enemy hand
    handUI.drawEnemy(#state.enemy.hand, { y = 35, scale = 0.5 })
    
    -- Get hero positions (centered)
    local heroPos = boardUI.getHeroPositions()
    
    -- Enemy hero (centered)
    boardUI.drawHero(state.enemy, heroPos.enemy.x, heroPos.enemy.y, {
        isPlayer = false,
        isTargetable = state.attackingCreature ~= nil,
        hovered = hoveredEnemyHero
    })
    
    -- Enemy mana (to the right of hero)
    boardUI.drawMana(state.enemy.mana, state.enemy.maxMana, heroPos.enemy.x + 95, heroPos.enemy.y + 15)
    
    -- Enemy deck info (far right)
    boardUI.drawDeckInfo(#state.enemy.deck, #state.enemy.graveyard, w - 60, 90)
    
    -- Enemy board
    local validTargets = {}
    if state.attackingCreature then
        for _, c in ipairs(state.enemy.board) do validTargets[c.instanceId] = true end
    end
    boardUI.drawCreatures(state.enemy.board, boardUI.ENEMY_BOARD_Y, {
        hoveredIndex = hoveredEnemyCreature, isValidTargets = validTargets, isPlayerBoard = false
    })
    
    -- Player board
    if placingCard then
        boardUI.drawPlacementSlots(#state.player.board, boardUI.PLAYER_BOARD_Y, hoveredPlacementSlot)
    end
    boardUI.drawCreatures(state.player.board, boardUI.PLAYER_BOARD_Y, {
        hoveredIndex = hoveredPlayerCreature,
        attackingId = state.attackingCreature and state.attackingCreature.instanceId,
        isPlayerBoard = true
    })
    
    -- Player hero (centered, between board and hand)
    boardUI.drawHero(state.player, heroPos.player.x, heroPos.player.y, {
        isPlayer = true, hovered = hoveredPlayerHero
    })
    
    -- Player mana (to the right of hero)
    boardUI.drawMana(state.player.mana, state.player.maxMana, heroPos.player.x + 95, heroPos.player.y + 15)
    
    -- Player deck info (far right)
    boardUI.drawDeckInfo(#state.player.deck, #state.player.graveyard, w - 60, heroPos.player.y)
    
    -- Player hand
    local handY = h - cardUI.CARD_HEIGHT - 20
    handUI.draw(state.player.hand, {
        y = handY, hoveredIndex = hoveredHandCard,
        canPlay = function(c) return state.phase == battleState.PHASES.MAIN and battleState.canPlayCard(state, c, true) end
    })
    
    -- UI elements
    if state.phase == battleState.PHASES.MAIN then
        drawButton(endTurnButton, "End Turn")
    elseif state.phase == battleState.PHASES.ENEMY_TURN then
        love.graphics.setColor(0.9, 0.5, 0.2)
        local f = love.graphics.newFont(18)
        love.graphics.setFont(f)
        love.graphics.print("Enemy Turn...", w - f:getWidth("Enemy Turn...") - 30, h/2 - 10)
    end
    
    drawButton(backButton, "Back")
    
    -- Victory/Defeat overlay
    if state.phase == battleState.PHASES.VICTORY or state.phase == battleState.PHASES.DEFEAT then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle('fill', 0, 0, w, h)
        local rf = love.graphics.newFont(48)
        love.graphics.setFont(rf)
        local txt = state.phase == battleState.PHASES.VICTORY and "VICTORY!" or "DEFEAT"
        love.graphics.setColor(state.phase == battleState.PHASES.VICTORY and {0.3, 0.9, 0.4} or {0.9, 0.3, 0.3})
        love.graphics.print(txt, (w - rf:getWidth(txt)) / 2, h/2 - 80)
        drawButton(restartButton, "Play Again")
    end
    
    -- Targeting indicator
    if state.attackingCreature then
        love.graphics.setColor(1, 0.8, 0.2, 0.8)
        local f = love.graphics.newFont(14)
        love.graphics.setFont(f)
        love.graphics.print("Select target for " .. state.attackingCreature.card.name, 220, h/2 - 7)
    end
    
    drawBattleLog()
    
    -- Tooltip for hovered card/creature
    local tooltipCard = nil
    if hoveredHandCard and state.player.hand[hoveredHandCard] then
        tooltipCard = state.player.hand[hoveredHandCard].card
    elseif hoveredPlayerCreature and state.player.board[hoveredPlayerCreature] then
        tooltipCard = state.player.board[hoveredPlayerCreature].card
    elseif hoveredEnemyCreature and state.enemy.board[hoveredEnemyCreature] then
        tooltipCard = state.enemy.board[hoveredEnemyCreature].card
    end
    if tooltipCard then
        tooltip.drawCard(tooltipCard, mouseX, mouseY)
    end
end

function battlecards.mousemoved(x, y)
    if not state then return end
    mouseX, mouseY = x, y
    local w, h = love.graphics.getDimensions()
    
    hoveredHandCard, hoveredPlayerCreature, hoveredEnemyCreature = nil, nil, nil
    hoveredPlayerHero, hoveredEnemyHero, hoveredPlacementSlot = false, false, nil
    
    endTurnButton.hovered = isPointInRect(x, y, endTurnButton)
    backButton.hovered = isPointInRect(x, y, backButton)
    restartButton.hovered = isPointInRect(x, y, restartButton)
    
    if state.phase == battleState.PHASES.MAIN and not placingCard then
        local idx = handUI.getCardAtPosition(state.player.hand, x, y, { y = h - cardUI.CARD_HEIGHT - 20 })
        if idx then hoveredHandCard = idx end
    end
    
    if placingCard then
        hoveredPlacementSlot = boardUI.getPlacementSlotAtPosition(#state.player.board, x, y, boardUI.PLAYER_BOARD_Y)
    end
    
    local pi = boardUI.getCreatureAtPosition(state.player.board, x, y, boardUI.PLAYER_BOARD_Y)
    if pi then hoveredPlayerCreature = pi end
    
    local ei = boardUI.getCreatureAtPosition(state.enemy.board, x, y, boardUI.ENEMY_BOARD_Y)
    if ei then hoveredEnemyCreature = ei end
    
    local heroPos = boardUI.getHeroPositions()
    if boardUI.isPointInHero(x, y, heroPos.player.x, heroPos.player.y) then hoveredPlayerHero = true end
    if boardUI.isPointInHero(x, y, heroPos.enemy.x, heroPos.enemy.y) then hoveredEnemyHero = true end
end

function battlecards.mousepressed(x, y, button)
    if not state or button ~= 1 then return end
    if endTurnButton.hovered then endTurnButton.pressed = true end
    if backButton.hovered then backButton.pressed = true end
    if restartButton.hovered then restartButton.pressed = true end
end

function battlecards.mousereleased(x, y, button)
    if not state or button ~= 1 then return end
    
    if endTurnButton.pressed and endTurnButton.hovered and state.phase == battleState.PHASES.MAIN then
        battleState.endTurn(state)
        state.attackingCreature, placingCard = nil, nil
    end
    endTurnButton.pressed = false
    
    if backButton.pressed and backButton.hovered then switchScene("battlecards_menu") end
    backButton.pressed = false
    
    if restartButton.pressed and restartButton.hovered then
        if state.phase == battleState.PHASES.VICTORY or state.phase == battleState.PHASES.DEFEAT then
            battlecards.enter()
        end
    end
    restartButton.pressed = false
    
    if state.phase ~= battleState.PHASES.MAIN then return end
    
    if placingCard and hoveredPlacementSlot then
        battleState.playCreature(state, placingCard, true, hoveredPlacementSlot)
        placingCard = nil
        return
    end
    if placingCard then placingCard = nil return end
    
    if hoveredHandCard then
        local card = state.player.hand[hoveredHandCard]
        if card and battleState.canPlayCard(state, card, true) then
            if card.card.type == 'creature' then
                placingCard, state.attackingCreature = card, nil
            else
                battleState.playSpell(state, card, true, nil)
            end
        end
        return
    end
    
    if hoveredPlayerCreature then
        local c = state.player.board[hoveredPlayerCreature]
        if c and c.canAttack and not c.hasAttacked then
            state.attackingCreature = state.attackingCreature == c and nil or c
        end
        return
    end
    
    if hoveredEnemyCreature and state.attackingCreature then
        local target = state.enemy.board[hoveredEnemyCreature]
        if target then
            battleState.attackCreature(state, state.attackingCreature, target, true)
            state.attackingCreature = nil
        end
        return
    end
    
    if hoveredEnemyHero and state.attackingCreature then
        battleState.attackFace(state, state.attackingCreature, true)
        state.attackingCreature = nil
        return
    end
    
    state.attackingCreature = nil
end

function battlecards.keypressed(key)
    if key == "escape" then switchScene("battlecards_menu")
    elseif key == "space" and state and state.phase == battleState.PHASES.MAIN then
        battleState.endTurn(state)
        state.attackingCreature, placingCard = nil, nil
    end
end

function battlecards.resize() end

return battlecards
