--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        },
        throwable = false,
        breakable = false
    },

    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 16,
        width = 16,
        height = 16,
        solid = true,
        defaultState = 'intact',
        states = {
            ['intact'] = {
                frame = 16
            },
            ['broken'] = {
                frame = 52
            }
        },
        throwable = true,
        onCollide = function(player, object)
        end,
        breakable = false
    },

    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 5
            }
        },
        throwable = false,
        consumable = true,
        breakable = false
    },

    ['chest'] = {
        type = 'chest',
        texture = 'tiles',
        width = 16,
        height = 12,
        solid = true,
        defaultState = 'intact',
        states = {
            ['intact'] = {
                frame = 110
            },
            ['broken'] = {
                frame = 111
            }
        },
        throwable = true,
        breakable = true
    }
}