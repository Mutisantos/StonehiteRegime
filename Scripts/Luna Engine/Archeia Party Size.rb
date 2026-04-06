#==============================================================================
# ■ Adjust Party Size by Archeia
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This scriptlet allows you to have more than 4 party members in battle.
# This is made so you won't have to edit the Default Scripts!
#==============================================================================

module BattleLuna
	module LUNA_PARTY
    # This is the default amount of party members you can have.
		PARTY_SIZE = 4
    
    # This is an option to change it in-game, whenever you want.
    PARTY_VARIABLE_ID = 0
	end
end

#==============================================================================
# ■ GAME_PARTY
#==============================================================================

class Game_Party < Game_Unit
  alias archeia_max_battle_members max_battle_members
  def max_battle_members
    p_var = $game_variables[BattleLuna::LUNA_PARTY::PARTY_VARIABLE_ID]
    return p_var > 0 ? p_var : BattleLuna::LUNA_PARTY::PARTY_SIZE
  end
end