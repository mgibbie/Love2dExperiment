-- Event System
-- Sequential event queue for animations and game flow
-- Similar to Balatro's G.E_MANAGER

local M = {}

-- Event types
M.EVENT_TYPES = {
    INSTANT = "instant",      -- Execute immediately
    TIMED = "timed",          -- Wait for duration
    BLOCKING = "blocking",    -- Wait for completion callback
    ANIMATION = "animation"   -- Animation with callback
}

-- Create a new event manager
function M.new()
    local manager = {
        queue = {},
        current_event = nil,
        paused = false,
        time_scale = 1.0,
        elapsed = 0,
        max_queue_size = 1000,  -- Prevent memory issues
        blocking_timeout = 5.0  -- Max seconds for blocking events
    }
    
    setmetatable(manager, {__index = M})
    return manager
end

-- Add an event to the queue
function M:add(event)
    -- Prevent queue overflow
    if #self.queue >= self.max_queue_size then
        print("WARNING: Event queue full, dropping oldest event")
        table.remove(self.queue, 1)
    end
    
    -- Normalize event structure
    local normalized = {
        type = event.type or M.EVENT_TYPES.INSTANT,
        duration = event.duration or 0,
        elapsed = 0,
        func = event.func,
        after = event.after,
        blocking = event.blocking or false,
        complete = false,
        data = event.data or {},
        blocking_start_time = nil  -- Track when blocking event started
    }
    
    table.insert(self.queue, normalized)
    return normalized
end

-- Add an instant event (runs immediately when reached)
function M:addInstant(func, after)
    return self:add({
        type = M.EVENT_TYPES.INSTANT,
        func = func,
        after = after
    })
end

-- Add a timed event (waits for duration)
function M:addTimed(duration, func, after)
    return self:add({
        type = M.EVENT_TYPES.TIMED,
        duration = duration,
        func = func,
        after = after
    })
end

-- Add a blocking event (waits for func to return true)
function M:addBlocking(func, after)
    return self:add({
        type = M.EVENT_TYPES.BLOCKING,
        func = func,
        after = after,
        blocking = true
    })
end

-- Add event with delay
function M:addDelay(delay, func)
    return self:add({
        type = M.EVENT_TYPES.TIMED,
        duration = delay,
        after = func
    })
end

-- Clear all events
function M:clear()
    self.queue = {}
    self.current_event = nil
end

-- Pause event processing
function M:pause()
    self.paused = true
end

-- Resume event processing
function M:resume()
    self.paused = false
end

-- Set time scale (for fast-forward)
function M:setTimeScale(scale)
    self.time_scale = scale
end

-- Update the event manager
function M:update(dt)
    if self.paused then return end
    
    dt = dt * self.time_scale
    self.elapsed = self.elapsed + dt
    
    -- Process current event
    if self.current_event then
        local event = self.current_event
        event.elapsed = event.elapsed + dt
        
        local complete = false
        local error_occurred = false
        
        if event.type == M.EVENT_TYPES.INSTANT then
            -- Instant events complete immediately
            if event.func then
                local success, err = pcall(event.func, event.data)
                if not success then
                    print("ERROR in instant event: " .. tostring(err))
                    error_occurred = true
                end
            end
            complete = true
            
        elseif event.type == M.EVENT_TYPES.TIMED then
            -- Timed events wait for duration
            if event.func then
                local progress = math.min(event.elapsed / event.duration, 1)
                local success, err = pcall(event.func, event.data, progress)
                if not success then
                    print("ERROR in timed event: " .. tostring(err))
                    error_occurred = true
                end
            end
            if event.elapsed >= event.duration then
                complete = true
            end
            
        elseif event.type == M.EVENT_TYPES.BLOCKING then
            -- Blocking events wait for func to return true
            -- Track start time for timeout
            if not event.blocking_start_time then
                event.blocking_start_time = self.elapsed
            end
            
            -- Check timeout
            if self.elapsed - event.blocking_start_time >= self.blocking_timeout then
                print("WARNING: Blocking event timed out after " .. self.blocking_timeout .. " seconds")
                complete = true
                error_occurred = true
            elseif event.func then
                local success, result = pcall(event.func, event.data, dt)
                if not success then
                    print("ERROR in blocking event: " .. tostring(result))
                    complete = true
                    error_occurred = true
                else
                    complete = result == true
                end
            else
                complete = true
            end
        end
        
        if complete then
            -- Run after callback (only if no error occurred)
            if event.after and not error_occurred then
                local success, err = pcall(event.after, event.data)
                if not success then
                    print("ERROR in event after callback: " .. tostring(err))
                end
            end
            event.complete = true
            self.current_event = nil
        end
    end
    
    -- Get next event if no current event
    if not self.current_event and #self.queue > 0 then
        self.current_event = table.remove(self.queue, 1)
        self.current_event.elapsed = 0
        self.current_event.blocking_start_time = nil
    end
end

-- Check if there are pending events
function M:hasPending()
    return self.current_event ~= nil or #self.queue > 0
end

-- Check if event queue is empty
function M:isEmpty()
    return self.current_event == nil and #self.queue == 0
end

-- Get number of pending events
function M:count()
    local count = #self.queue
    if self.current_event then count = count + 1 end
    return count
end

-- Create a sequence of events that run in order
function M:sequence(events)
    for _, event in ipairs(events) do
        self:add(event)
    end
end

-- Helper: Add card scoring animation sequence
function M:addCardScore(card, chips, mult, delay)
    delay = delay or 0.1
    self:addDelay(delay, function()
        -- Trigger card highlight
        if card.onScore then
            card.onScore(chips, mult)
        end
    end)
end

-- Helper: Add joker trigger animation
function M:addJokerTrigger(joker, effect, delay)
    delay = delay or 0.15
    self:addDelay(delay, function()
        if joker.onTrigger then
            joker.onTrigger(effect)
        end
    end)
end

-- Helper: Add score popup
function M:addScorePopup(value, x, y, delay)
    delay = delay or 0
    self:addDelay(delay, function()
        -- Trigger popup display
        if M.onScorePopup then
            M.onScorePopup(value, x, y)
        end
    end)
end

return M

