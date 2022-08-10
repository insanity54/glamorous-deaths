--[[
Glamorous Deaths - Announce players' deaths server-wide with
colorful messages

Copyright (C) 2022 Brett Cornwall
Copyright (C) 2016 EvergreenTree

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local title = "Glamorous Deaths"
local version = "0.1.0"
local mname = minetest.get_current_modname()

dofile(minetest.get_modpath(mname).."/settings.txt")

-- A table of quips for death messages. The first item in each sub table is
-- the default message used when RANDOM_MESSAGES is disabled.
local messages = {}

-- These messages must make sense for both “You […]” and “SomePlayerName […]”

messages.lava = {
    " melted into a puddle.",
    " got a little too close to lava.",
    " burned up in lava.",
    " turned into molten slag.",
}

messages.water = {
    " drowned.",
    " struggled for air.",
    " suffocated.",
    " ran out of oxygen.",
    " should have worn a lifejacket.",
}

messages.fire = {
    " burned to a crisp.",
    " burned up.",
    " didn't stop, drop, and roll.",
    " got roasted like a marshmallow.",
    " got barbecued.",
    " got toasty.",
    " got roasted.",
    " played with fire.",
}

messages.fall = {
    " fell.",
    " had a tumble.",
    " lost footing.",
    " went splat.",
}

messages.punch = {
    " got hit hard."
}

messages.node = {
    " got killed by "
}

function get_message(mtype)
    if RANDOM_MESSAGES then
        return messages[mtype][math.random(1, #messages[mtype])]
    else
        return messages[1] -- 1 is the index for the non-random message
    end
end

local function tchelper(first, rest)
   return first:upper()..rest:lower()
end

minetest.register_on_dieplayer(function(player, reason)
    local player_name = player:get_player_name()
    local node = minetest.registered_nodes[
        minetest.get_node(player:getpos()).name
    ]

    if minetest.is_singleplayer() then
        player_name = "You"
    end

    if reason["type"] == "node_damage" then
        if reason["node"] == "default:lava_source" then
            minetest.chat_send_all(player_name .. get_message("lava"))
        elseif reason["node"] == "fire:basic_flame" then
            minetest.chat_send_all(player_name .. get_message("fire"))
        else
            -- Try to make something out of the node that killed the player as
            -- a last-ditch effort. Strip the mod name from the item and
            -- sentence-case it to make it seem a little more natural.
            node_mod, node_name = string.match(reason["node"], "(.*):(.*)")
            node_name_pretty = string.gsub(node_name, "_", " ")
            node_name_pretty = node_name_pretty:gsub("(%a)([%w_']*)", tchelper)
            minetest.chat_send_all(
                player_name .. get_message("node") .. node_name_pretty .. "."
            )
        end
    elseif reason["type"] == "drown" then
        minetest.chat_send_all(player_name .. get_message("water"))
    elseif reason["type"] == "fall" then
        minetest.chat_send_all(player_name .. get_message("fall"))
    else
        minetest.chat_send_all(player_name .. " died.")
    end

end)

print("[Mod] "..title.." ["..version.."] ["..mname.."] loaded.")
