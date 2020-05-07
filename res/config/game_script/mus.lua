local state = {
    warningShaderMod = false
}

local entryWarning = function()
    if (not (game.config.underpassMod and game.config.shaderMod)) then
        if not state.warningShaderMod then
            local textview = gui.textView_create(
                "mus.warning.textView",
                _("UNDERPASS_WARNING"),
                400
            )
            local layout = gui.boxLayout_create("mus.warning.boxLayout", "VERTICAL")
            layout:addItem(textview)
            state.warningShaderMod = gui.window_create(
                "mus.warning.window",
                _("Warning"),
                layout
            )
            state.warningShaderMod:onClose(function()state.warningShaderMod = false end)
        end
        
        local mainView = game.gui.getContentRect("mainView")
        local mainMenuHeight = game.gui.getContentRect("mainMenuTopBar")[4] + game.gui.getContentRect("mainMenuBottomBar")[4]
        local size = game.gui.calcMinimumSize(state.warningShaderMod.id)
        local y = mainView[4] - size[2] - mainMenuHeight
        local x = mainView[3] - size[1]
        
        game.gui.window_setPosition(state.warningShaderMod.id, x * 0.5, y * 0.5)
        game.gui.setHighlighted(state.warningShaderMod.id, true)
    end
end

local script = {
    guiHandleEvent = function(id, name, param)
        if name == "builder.apply" then
            local toAdd = param.proposal.toAdd
            if toAdd and #toAdd > 0 then
                for i = 1, #toAdd do
                    local con = toAdd[i]
                    if (con.fileName == [[station/rail/mus.con]]) then
                        entryWarning()
                        if(con.params.isFinalized == 0) then
                            -- get the id
                            local newId = nil
                            for k, _ in pairs(param.data.entity2tn) do
                                local entity = game.interface.getEntity(k)
                                -- n BASE_EDGE, m BASE_NODE, 1 CONSTRUCTION
                                if type(entity) == 'table' and type(entity.type) == 'string' and entity.type == 'CONSTRUCTION' then
                                    newId = entity.id
                                    break
                                end
                            end

                            if newId ~= nil then
                                game.interface.sendScriptEvent(
                                    "__underpassEvent__", "new",
                                    {
                                        -- id = param.result[1], -- works no more
                                        id = newId,
                                        isStation = true
                                    }
                                )
                            end
                        end
                    end
                end
            end
        end
    end
}

function data()
    return script
end
