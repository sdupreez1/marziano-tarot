SMODS.Atlas {
    key = "15C_tarot",
    path = "marziano_tarot.png",
    px = 71,
    py = 95
}

SMODS.Consumable({
    set = "Tarot", key = "giove", cost = 10, discovered = true,
    atlas = "15C_tarot",
    pos = {
        x = 0,
        y = 0
    },
    loc_txt = {
        name = 'Giove',
        text = {
            "Creates 2 random {C:781e0c}Marziano{}", -- this might cause problems
            "{C:attention}Tarot Cards{}",
            "{C:inactive}(if there is room){}"
        }
    },
    config = {
        max_tarots = 2,
        marz = true
    },
    loc_vars = function(self, info_queue, card)

    end,
    can_use = function(self, card)
    
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(card.ability.consumeable.max_tarots, ( G.consumeables.config.card_limit - #G.consumeables.cards )) do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                if G.consumeables.config.card_limit > #G.consumeables.cards then
                    play_sound('timpani')
                    local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil,'emp')
                    if new_card then

                    end
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    used_tarot:juice_up(0.3, 0.5)
                end
                return true end }))
        end
    end
})

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
        mod_conv = 'm_mult',
        marz = true
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

SMODS.Consumable({
    set = "Tarot", key = "pallas", cost = 10, discovered = true,
    atlas = "15C_tarot",
    pos = {
        x = 2,
        y = 0
    },
    loc_txt = {
        name = 'Pallas',
        text = {
            "Changes rank of {C:attention}#1#{}",
            "selected cards to your",
            "most common rank",
            "{C:inactive}(currently #2#){}"
        }
    },

    config = { 
        max_highlighted = 2,
        rank_conv = 14,
        rank_conv_value = 'Ace',
        marz = true
    },

    calculate = function(self, card, context)
        if (context.drawing_cards or context.using_consumeable or context.playing_card_added or context.remove_playing_cards or context.destroy_card) then -- might need to add some variation of `and (context.cardarea == G.play)`
            local rank_counts = {} -- this will have keys 2 to 14 (Ace=14, K=13, Q=12, J=11)
            local stones = nil
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect == 'Stone Card' then
                    stones = stones or 0
                end
                if (v.area and v.area == G.deck) then -- removed `or v.ability.wheel_flipped` from the if statement, not sure if it affects what gets counted
                    if v.ability.effect == 'Stone Card' then
                        stones = stones + 1
                    else
                        rank_counts[v.base.id] = (rank_counts[v.base.id] or 0) + 1
                    end
                end
            end

            local most_common_r, most_common_count = next(rank_counts)
            for rank, count in next, rank_counts, most_common_r do
                if count > most_common_count then
                    most_common_r = rank
                elseif count == most_common_count then
                    if  rank > most_common_r then -- accounts for KQJA since we are using <playing_card>.base.id (an int), not <playing_card>.base.value (a string)
                        most_common_r = rank
                    end
                end
            end
            
            card.ability.consumeable.rank_conv = most_common_r
            local rank_suffix = card.ability.consumeable.rank_conv
            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end
            card.ability.consumeable.rank_conv_value = G.P_CARDS['H_'..rank_suffix].value

        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.consumeable.max_highlighted, 
            card.ability.consumeable.rank_conv_value 
            } 
        }
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
            local changing_card = G.hand.highlighted[i]
            local suit_prefix = string.sub(changing_card.base.suit, 1, 1)..'_'
            local rank_suffix = card.ability.consumeable.rank_conv

            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                G.hand.highlighted[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix]);
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
            "{C:inactive}(currently #1#){}"
        }
    },
    config = {
        max_highlighted = 3,
        suit_conv = 'Spades',
        marz = true
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

-- WIP
SMODS.Consumable({
    set = "Tarot", key = "apollo", cost = 10, discovered = true,
    atlas = "15C_tarot",    
    pos = {
        x = 4,
        y = 0
    },
    loc_txt = {
        name = 'Apollo',
        text = {
            "Disables current",
            "boss blind"
        }
    },
    config = { marz = true },

    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
            return true
        end        
    end,

    
    use = function(self, card, area, copier) 
    
    end
})

-- need to localise suit_conv
SMODS.Consumable({
    set = "Tarot", key = "nettuno", cost = 10, discovered = true,
    atlas = "15C_tarot",
    pos = {
        x = 5,
        y = 0
    },
    loc_txt = {
        name = 'Nettuno',
        text = {
            "Select {C:attention}#1#{} cards,",
            "convert both to your",
            "most common card",
            "{C:inactive}(currently #2# of #3#)"
        }
    },
    config = {
        max_highlighted = 2,
        suit_conv = 'Spades',
        rank_conv = 14,
        rank_conv_value = 'Ace',
        marz = true
    },    
    loc_vars = function(self, info_queue, card)
        return { vars = { 
                card.ability.consumeable.max_highlighted,
                card.ability.consumeable.rank_conv_value,
                card.ability.consumeable.suit_conv
            } 
        }
    end,

    calculate = function(self, card, context)
        if (context.drawing_cards or context.using_consumeable or context.playing_card_added or context.remove_playing_cards or context.destroy_card) then -- might need to add some variation of `and (context.cardarea == G.play)`
             local suit_counts = {
                        Spades = 0,
                        Hearts = 0,
                        Clubs = 0,
                        Diamonds = 0
                    }
            local rank_counts = {}
            local stones = nil
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect == 'Stone Card' then
                    stones = stones or 0
                end
                if (v.area and v.area == G.deck) then -- removed  `or v.ability.wheel_flipped` from the if statement, not sure if it affects what gets counted
                    if v.ability.effect == 'Stone Card' then
                        stones = stones + 1
                    else
                        -- for suit, count in pairs(suit_counts) do
                        --     if v.base.suit == suit then suit_counts[suit] = suit_counts[suit] + 1 end 
                        -- end
                        suit_counts[v.base.suit] = suit_counts[v.base.suit] + 1
                        rank_counts[v.base.id] = (rank_counts[v.base.id] or 0) + 1
                    end
                end
            end

            local most_common_s, most_common_count = next(suit_counts)
            for suit, count in next, suit_counts, most_common_s do
                if count > most_common_count then
                    most_common_s = suit
                end
            end

            local most_common_r, most_common_count = next(rank_counts)
            for rank, count in next, rank_counts, most_common_r do
                if count > most_common_count then
                    most_common_r = rank
                elseif count == most_common_count then
                    if  rank > most_common_r then
                        most_common_r = rank
                    end
                end
            end
            
            card.ability.consumeable.suit_conv = most_common_s
            card.ability.consumeable.rank_conv = most_common_r
            local rank_suffix = card.ability.consumeable.rank_conv
            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end
            card.ability.consumeable.rank_conv_value = G.P_CARDS['H_'..rank_suffix].value -- no important reason why `H_` is used, just the first suit in the P_CARDS table

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
            -- Change rank...
            local changing_card = G.hand.highlighted[i]
            local suit_prefix = string.sub(changing_card.base.suit, 1, 1)..'_'
            local rank_suffix = card.ability.consumeable.rank_conv

            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                G.hand.highlighted[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix]);
            return true end }))
            
            -- ...Then change suit
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

SMODS.Consumable({
    set = "Tarot", key = "diana", cost = 10, discovered = true,
    atlas = "15C_tarot",
    pos = {
        x = 6,
        y = 0
    },
    loc_txt = {
        name = 'Diana',
        text = {
            "Enhances {C:attention}3{}",
            "selected cards to",
            "{C:attention}Wild Cards{}"
        }
    },
    config = {
        max_highlighted = 3,
        mod_conv = 'm_wild',
        marz = true
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

SMODS.Consumable({
    set = "Tarot", key = "bacco", cost = 10, discovered = true,
    atlas = "15C_tarot",    
    pos = {
        x = 7,
        y = 0
    },

    loc_txt = {
        name = 'Bacco',
        text = {
            "Spend total sell value",
            "of all current Jokers",
            "{C:inactive}({C:money}$#1#{C:inactive}){} to add {C:dark_edition}negative{} to",
            "a random Joker"
        }
    },
    
    config = {
        money = 0,
        eligible_editionless_jokers = nil,
        marz = true
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars ={
                card.ability.consumeable.money
            }
        }
    end,

    calculate = function(self, card, context)
        card.ability.consumeable.eligible_editionless_jokers = EMPTY(card.ability.consumeable.eligible_editionless_jokers)
        for k, v in pairs(G.jokers.cards) do
            if v.ability.set == 'Joker' and (not v.edition) then
                table.insert(card.ability.consumeable.eligible_editionless_jokers, v)
            end
        end

        card.ability.consumeable.money = 0
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].ability.set == 'Joker' then
                card.ability.consumeable.money = card.ability.consumeable.money + G.jokers.cards[i].sell_cost
            end
        end
    end,

    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
            return true
        end        
    end,

    use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                local temp_pool = card.ability.consumeable.eligible_editionless_jokers
                local eligible_card = pseudorandom_element( temp_pool, pseudoseed('bacco') )
                local edition = {negative = true}
                eligible_card:set_edition(edition, true)
                check_for_unlock({type = 'have_edition'})
                card:juice_up(0.3, 0.5)
            return true end }))
    end
})

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
            {id = 'consumable_slots', value = 8},
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
        {id = 'c_15Ctarot_bacco'}
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
        -- yes_suits = {H=true},
        -- no_suits = {D=true},
        cards = {{s='D',r='2',e='m_glass',},{s='D',r='3',e='m_glass',},{s='D',r='4',e='m_glass',},{s='D',r='5',e='m_glass',},{s='D',r='6',e='m_glass',},{s='D',r='7',e='m_glass',},{s='D',r='8',e='m_glass',},{s='D',r='9',e='m_glass',},{s='D',r='T',e='m_glass',},{s='D',r='J',e='m_glass',},{s='D',r='Q',e='m_glass',},{s='D',r='K',e='m_glass',},{s='D',r='A',e='m_glass',},{s='C',r='2',e='m_glass',},{s='C',r='3',e='m_glass',},{s='C',r='4',e='m_glass',},{s='C',r='5',e='m_glass',},{s='C',r='6',e='m_glass',},{s='C',r='7',e='m_glass',},{s='C',r='8',e='m_glass',},{s='C',r='9',e='m_glass',},{s='C',r='T',e='m_glass',},{s='C',r='J',e='m_glass',},{s='C',r='Q',e='m_glass',},{s='C',r='K',e='m_glass',},{s='C',r='A',e='m_glass',},{s='H',r='2',e='m_glass',},{s='H',r='3',e='m_glass',},{s='H',r='4',e='m_glass',},{s='H',r='5',e='m_glass',},{s='H',r='6',e='m_glass',},{s='H',r='7',e='m_glass',},{s='H',r='8',e='m_glass',},{s='H',r='9',e='m_glass',},{s='H',r='T',e='m_glass',},{s='H',r='J',e='m_glass',},{s='H',r='Q',e='m_glass',},{s='H',r='K',e='m_glass',},{s='H',r='A',e='m_glass',},{s='S',r='2',e='m_glass',},{s='S',r='3',e='m_glass',},{s='S',r='4',e='m_glass',},{s='S',r='5',e='m_glass',},{s='S',r='6',e='m_glass',},{s='S',r='7',e='m_glass',},{s='S',r='8',e='m_glass',},{s='S',r='9',e='m_glass',},{s='S',r='T',e='m_glass',},{s='S',r='J',e='m_glass',},{s='S',r='Q',e='m_glass',},{s='S',r='K',e='m_glass',},{s='S',r='A',e='m_glass',},},
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