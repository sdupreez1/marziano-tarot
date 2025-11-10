SMODS.Atlas {
    key = "15C_tarot",
    path = "15th_century_tarot.png",
    px = 71,
    py = 95
}

-- -- This will need a new 15C set to be created to create specifically 15C tarots --
-- SMODS.Consumable({
--     set = "Tarot", key = "giove", cost = 10, discovered = true,
--     atlas = "15C_tarot",
--     pos = {
--         x = 0,
--         y = 0
--     },
--     loc_txt = {
--         name = 'Giove',
        -- text = {
        --     "Creates 2 random 15C Tarot Cards"
        -- }
--     },
--     config = {},
--     loc_vars = function(self, info_queue, card)

--     end,
--     can_use = function(self, card)
    
--     end,
--     use = function(self, card, area, copier)
--         for i = 1, math.min((self.ability.consumeable.tarots or self.ability.consumeable.planets), G.consumeables.config.card_limit - #G.consumeables.cards) do
--             G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
--                 if G.consumeables.config.card_limit > #G.consumeables.cards then
--                     play_sound('timpani')
--                     local card = create_card((self.ability.name == 'The Emperor' and 'Tarot'), G.consumeables, nil, nil, nil, nil, nil, (self.ability.name == 'The Emperor' and 'emp'))
--                     card:add_to_deck()
--                     G.consumeables:emplace(card)
--                     used_tarot:juice_up(0.3, 0.5)
--                 end
--                 return true end }))
--         end
--     end
-- })

SMODS.Consumable({
    set = "Tarot", key = "giunone", cost = 10, discovered = true, atlas = "15C_tarot", 
    pos = {
        x = 1,
        y = 0
    },
    loc_txt = {
        name = 'Giunone',
        text = {
            "Enhances {C:attention}3{} selected",
            "cards to {C:attention}Mult Cards{}"
        }
    },
    config = {
        max_highlighted = 3, 
        mod_conv = 'm_mult'
    },

    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and (#G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted) then
            return true
        end
    end,

    use = function(self, card, area, copier)
        for i=1, #G.hand.highlighted do
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);
            return true end }))
        end
        delay(0.2)
        for i=1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                G.hand.highlighted[i]:set_ability(G.P_CENTERS[card.ability.consumeable.mod_conv]);
            return true end }))
        end
        for i=1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999)/(#G.hand.highlighted - 0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(0.3, 0.3);
            return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end }))
        delay(0.5)
    end
})

-- SMODS.Consumable({
--     set = "Tarot", key = "pallas", cost = 10, discovered = true,
--     atlas = "15C_tarot",
--     pos = {
--         x = 2,
--         y = 0
--     },
--     loc_txt = {
--         name = 'Pallas',
        -- text = {
        --     "Changes rank of 3 selected cards to the highest most common rank in your deck {C:inactive}(currently #1#){}"
        -- }
--     },

--     calculate = function(self, card, context)
--         if (context.playing_card_added or context.remove_playing_cards or context.destroy_card) then -- might need to add some variation of `and (context.cardarea == G.play)`
--             local rank_counts = {}
--             local stones = nil
--             for k, v in ipairs(G.playing_cards) do
--                 if v.ability.effect == 'Stone Card' then
--                     stones = stones or 0
--                 end
--                 if (v.area and v.area == G.deck) then -- removed  `or v.ability.wheel_flipped` from the if statement, not sure if it affects what gets counted
--                     if v.ability.effect == 'Stone Card' then
--                         stones = stones + 1
--                     else
--                         rank_counts[v.base.id] = (rank_counts[v.base.id] or 0) + 1
--                     end
--                 end
--             end

--             local most_common_r, most_common_count = next(rank_counts)
--             for rank, count in next, rank_counts, most_common_r do
--                 if count > most_common_count then
--                     most_common_r = rank
--                 elseif count == most_common_count then
--                     if  rank > most_common_r then -- account for KQJ
--                         most_common_r = rank
--                     end
--                 end
--             end
            
--             card.ability.most_common_rank = most_common_r

--             return {}
--         end
--     end,
--     -- figure out how to properly format config
--     config = { 
--         max_highlighted = 2,
--         most_common_rank = 0 -- this might need to be something like `mod_conv = 'up_rank'` as in Strength
--     },

--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.ability.most_common_rank } }
--     end,

--     can_use = function(self, card)
--         if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
--             return true
--         end
--     end,

--     use = function(self, card, area, copier)
--         G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
--             play_sound('tarot1')
--             used_tarot:juice_up(0.3, 0.5)
--             return true end }))
--         for i=1, #G.hand.highlighted do
--             local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
--             G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
--                 G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);
--             return true end }))
--         end
--         delay(0.2)
--         for i=1, #G.hand.highlighted do
--             G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
--                 G.hand.highlighted[i]:set_ability(G.P_CENTERS[self.ability.mod_conv]);
--             return true end }))
--         end
--         for i=1, #G.hand.highlighted do
--             local percent = 0.85 + (i - 0.999)/(#G.hand.highlighted - 0.998)*0.3
--             G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
--                 G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(0.3, 0.3);
--             return true end }))
--         end
--         G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
--             G.hand:unhighlight_all();
--         return true end }))
--         delay(0.5)
--     end
-- })

SMODS.Consumable({
    set = "Tarot", key = "venus", cost = 10, discovered = true,
    atlas = "15C_tarot",
    pos = {
        x = 3,
        y = 0
    },
    loc_txt = {
        name = 'Venus',
        text = {
            "Converts {C:attention}3{}",
            "selected cards to",
            "your top suit",
            "{C:inactive}(currently #1#){}" -- get this to display a suit symbol
        }
    },
    config = {
        max_highlighted = 3,
        suit_conv = 'Spades'
    },    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.consumeable.suit_conv } }
    end,

    calculate = function(self, card, context)
        if (context.drawing_cards or context.using_consumeable or context.playing_card_added or context.remove_playing_cards or context.destroy_card) then -- might need to add some variation of `and (context.cardarea == G.play)`
             local suit_counts = {
                        Spades = 0,
                        Hearts = 0,
                        Clubs = 0,
                        Diamonds = 0
                    }
            local stones = nil
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect == 'Stone Card' then
                    stones = stones or 0
                end
                if (v.area and v.area == G.deck) then -- removed  `or v.ability.wheel_flipped` from the if statement, not sure if it affects what gets counted
                    if v.ability.effect == 'Stone Card' then
                        stones = stones + 1
                    else
                        for suit, count in pairs(suit_counts) do
                            if v.base.suit == suit then suit_counts[suit] = suit_counts[suit] + 1 end 
                            -- removed the same as above^ that increased mod_suit_counts, not sure what the difference is
                        end
                    end
                end
            end

            local most_common_s, most_common_count = next(suit_counts)
            for suit, count in next, suit_counts, most_common_s do
                if count > most_common_count then
                    most_common_s = suit
                -- by not accounting for the == case, implicitly ranks suits by order in suit_counts (i.e S > H > C > D)
                end
            end
            
            card.ability.consumeable.suit_conv = most_common_s

            return {
                suit_conv = card.ability.suit_conv,
                message = localize { type = 'suits_plural', key = card.ability.consumeable.suit_conv }
            }
        end
    end,

    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and (#G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted) then
            return true
        end        
    end,

    use = function(self, card, area, copier)
        for i=1, #G.hand.highlighted do
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);
            return true end }))
        end
        delay(0.2)
        for i=1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                G.hand.highlighted[i]:change_suit(card.ability.consumeable.suit_conv);
            return true end }))
        end
        delay(0.5)
        for i=1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999)/(#G.hand.highlighted - 0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(0.3, 0.3);
            return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all();
        return true end }))
        delay(0.5)
    end
})

-- SMODS.Consumable({
--     set = "Tarot", key = "apollo", cost = 10, discovered = true,
--     atlas = "15C_tarot",    
--     pos = {
--         x = 4,
--         y = 0
--     },
--     loc_txt = {
--         name = 'Apollo',
        -- text = {
        --     "Disables (or changes?) current boss blind"
        -- }
--     },
--     config = {},
--     loc_vars = function(self, info_queue, card)

--     end,

--     can_use = function(self, card)
    
--     end,
    
--     use = function(self, card, area, copier)
    
--     end
-- })

-- SMODS.Consumable({
--     set = "Tarot", key = "nettuno", cost = 10, discovered = true,
--     atlas = "15C_tarot",
--     pos = {
--         x = 5,
--         y = 0
--     },
--     loc_txt = {
--         name = 'Nettuno',
        -- text = {
        --     "Select 2 cards, convert both to the most common card in your deck (currently <suit><number>)"
        -- }
--     },
--     config = {},
--     loc_vars = function(self, info_queue, card)

--     end,
--     can_use = function(self, card)
    
--     end,
--     use = function(self, card, area, copier)
    
--     end
-- })

-- SMODS.Consumable({
--     set = "Tarot", key = "diana", cost = 10, discovered = true,
--     atlas = "15C_tarot",
--     pos = {
--         x = 6,
--         y = 0
--     },
--     loc_txt = {
--         name = 'Diana',
        -- text = {
        --     "Enhances {C:attention}3{} selected cards to {C:attention}Wild Cards{}"
        -- }
--     },
--     config = {},
--     loc_vars = function(self, info_queue, card)

--     end,
--     can_use = function(self, card)
    
--     end,
--     use = function(self, card, area, copier)
    
--     end
-- })

-- SMODS.Consumable({
--     set = "Tarot", key = "bacco", cost = 10, discovered = true,
--     atlas = "15C_tarot",    
--     pos = {
--         x = 7,
--         y = 0
--     },

--     loc_txt = {
--         name = 'Bacco',
        -- text = {
        --     "Spend total sell value of all current Jokers ($<total_cost>) to add negative to a random Joker"
        -- }
--     },
--     config = {},
--     loc_vars = function(self, info_queue, card)

--     end,
--     can_use = function(self, card)
    
--     end,
--     use = function(self, card, area, copier)
    
--     end
-- })

SMODS.Challenge({
    key = 'TEST',
    loc_txt = {
        name = "TEST"
    },
    id = 'c_test_1',
    rules = {
        custom = {
            --{id = 'no_reward'},
            {id = 'no_reward_specific', value = 'Big'},
            {id = 'no_extra_hand_money'},
            {id = 'no_interest'},
            {id = 'daily'},
            {id = 'set_seed', value = 'SEEDEEDS'},
        },
        modifiers = {
            {id = 'dollars', value = 100},
            {id = 'discards', value = 1},
            {id = 'hands', value = 6},
            {id = 'reroll_cost', value = 10},
            {id = 'joker_slots', value = 8},
            {id = 'consumable_slots', value = 3},
            {id = 'hand_size', value = 5},
        }
    },
    jokers = {
        {id = 'j_egg'},
        {id = 'j_egg'},
        {id = 'j_egg'},
        {id = 'j_egg'},
        {id = 'j_egg', edition = 'foil', eternal = true}
    },
    consumeables = {
        {id = 'c_tarot15C_venus'}
    },
    vouchers = {
        {id = 'v_hieroglyph'},
    },
    deck = {
        -- enhancement = 'm_glass',
        -- edition = 'foil',
        -- gold_seal = true,
        -- yes_ranks = {['3'] = true,T = true},
        -- no_ranks = {['4'] = true},
        yes_suits = {H=true},
        -- no_suits = {D=true},
        -- cards = {{s='D',r='2',e='m_glass',},{s='D',r='3',e='m_glass',},{s='D',r='4',e='m_glass',},{s='D',r='5',e='m_glass',},{s='D',r='6',e='m_glass',},{s='D',r='7',e='m_glass',},{s='D',r='8',e='m_glass',},{s='D',r='9',e='m_glass',},{s='D',r='T',e='m_glass',},{s='D',r='J',e='m_glass',},{s='D',r='Q',e='m_glass',},{s='D',r='K',e='m_glass',},{s='D',r='A',e='m_glass',},{s='C',r='2',e='m_glass',},{s='C',r='3',e='m_glass',},{s='C',r='4',e='m_glass',},{s='C',r='5',e='m_glass',},{s='C',r='6',e='m_glass',},{s='C',r='7',e='m_glass',},{s='C',r='8',e='m_glass',},{s='C',r='9',e='m_glass',},{s='C',r='T',e='m_glass',},{s='C',r='J',e='m_glass',},{s='C',r='Q',e='m_glass',},{s='C',r='K',e='m_glass',},{s='C',r='A',e='m_glass',},{s='H',r='2',e='m_glass',},{s='H',r='3',e='m_glass',},{s='H',r='4',e='m_glass',},{s='H',r='5',e='m_glass',},{s='H',r='6',e='m_glass',},{s='H',r='7',e='m_glass',},{s='H',r='8',e='m_glass',},{s='H',r='9',e='m_glass',},{s='H',r='T',e='m_glass',},{s='H',r='J',e='m_glass',},{s='H',r='Q',e='m_glass',},{s='H',r='K',e='m_glass',},{s='H',r='A',e='m_glass',},{s='S',r='2',e='m_glass',},{s='S',r='3',e='m_glass',},{s='S',r='4',e='m_glass',},{s='S',r='5',e='m_glass',},{s='S',r='6',e='m_glass',},{s='S',r='7',e='m_glass',},{s='S',r='8',e='m_glass',},{s='S',r='9',e='m_glass',},{s='S',r='T',e='m_glass',},{s='S',r='J',e='m_glass',},{s='S',r='Q',e='m_glass',},{s='S',r='K',e='m_glass',},{s='S',r='A',e='m_glass',},},
        type = 'Challenge Deck'
    },
    restrictions = {
        banned_cards = {
            {id = 'j_joker'},
            {id = 'j_egg'},
        },
        banned_tags = {
            {id = 'tag_garbage'},
            {id = 'tag_handy'},
        },
        banned_other = {
            {id = 'bl_wall', type = 'blind'}
        }
    },
    unlocked = function(self)
        return true
    end
})