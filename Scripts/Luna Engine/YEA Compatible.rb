#==============================================================================
# ■ Luna Engine: Yanfly Compatibility Script
#==============================================================================
# This is to ensure that the Yanfly scripts are compatible with the Luna Engine.
# If you want to use his scripts, this is a must-have.
#==============================================================================

$imported = {} if $imported.nil?
$imported["YEL-YEACompatibility"] = true

#==============================================================================
# ■ LuneEngine
#==============================================================================

module LuneEngine
  module CORE
    
    YEA_COMPATIBILITY = {
      # Yanfly Engine Ace - Ace Battle Engine
      :battle_engine    =>  {
        # Change this to false to disable changing actor by LEFT RIGHT.
        :arrow_battler  =>  false,
        # Change this to false to disable target help window, which is shown
        # when selecting target.
        :target_help    =>  true,
      },
      
      # Yanfly Engine Ace - Ace Equip Engine
      :equip_engine       =>  {
        # Change this to false to make item window in Equip Scene always shows
        :hide_item_window =>  false,
        # Change this to false to make slot window in Equip Scene always shows
        :hide_slot_window =>  false,
      }
    } # End VISUAL
    
  end # End CORE
end # LuneEngine

#==============================================================================
# Editing anything past the engine's configuration script may potentially  
# result in causing computer damage, incontinence, explosion of user's head, 
# coma, death, and/or halitosis so edit at your own risk. 
# We're not liable for the risks you take should you pass this sacred grounds.
#==============================================================================

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager
  
  #--------------------------------------------------------------------------
  # alias method: gain_exp
  # Compatible with YEA - Victory Aftermath.
  #--------------------------------------------------------------------------
  class <<self; alias battle_luna_yea_gain_exp gain_exp; end
  def self.gain_exp
    if $imported["YEL-BattleLuna"]
      $game_party.all_members.each { |actor| actor.battle_hud = nil }
    end
    battle_luna_yea_gain_exp
  end
  
end # BattleManager

#==============================================================================
# ■ Game_ActionResult
#==============================================================================

class Game_ActionResult
  
  #--------------------------------------------------------------------------
  # alias method: clear_stored_damage
  #--------------------------------------------------------------------------
  alias battle_luna_yea_clear_stored_damage clear_stored_damage if $imported["YEA-BattleEngine"]
  def clear_stored_damage
    battle_luna_yea_clear_stored_damage unless $imported["YES-BattlePopup"]
  end
  
  #--------------------------------------------------------------------------
  # alias method: store_damage
  #--------------------------------------------------------------------------
  alias battle_luna_yea_store_damage store_damage if $imported["YEA-BattleEngine"]
  def store_damage
    battle_luna_yea_store_damage unless $imported["YES-BattlePopup"]
  end
  
  #--------------------------------------------------------------------------
  # alias method: restore_damage
  #--------------------------------------------------------------------------
  alias battle_luna_yea_restore_damage restore_damage if $imported["YEA-BattleEngine"]
  def restore_damage
    battle_luna_yea_restore_damage unless $imported["YES-BattlePopup"]
  end
  
end # Game_ActionResult

#==============================================================================
# ■ Window Cursor + YEA: B
#==============================================================================
class Window_BattleEnemy < Window_Selectable
  if $imported["YEL-MenuLuna-CustomCursor"]
    alias battle_luna_yea_col_max col_max
    def col_max
      return [battle_luna_yea_col_max, 1].max
    end
  end
end # Window_BattleEnemy

#==============================================================================
# ■ Window_EquipStatus
#==============================================================================

class Window_EquipStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # removed method: draw_background_colour
  # Remove the black background in status equip
  #--------------------------------------------------------------------------
  def draw_background_colour(dx, dy)
    # removed
  end
  
end # Window_EquipStatus

#==============================================================================
# ■ Window_ActorCommand
#==============================================================================

class Window_ActorCommand < Window_Command

  #--------------------------------------------------------------------------
  # overwrite method: process_handling
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  def process_handling
    return unless open? && active
    if LuneEngine::CORE::YEA_COMPATIBILITY[:battle_engine][:arrow_battler]
      return process_dir4 if Input.repeat?(:LEFT)
      return process_dir6 if Input.repeat?(:RIGHT)
    end
    return super
  end
  end

end # Window_ActorCommand

#~ #==============================================================================
#~ # ■ Window_BattleHelp
#~ #==============================================================================

#~ class Window_BattleHelp < Window_Help
#~   
#~   #--------------------------------------------------------------------------
#~   # alias method: update_battler_name
#~   # Compatible with YEA - Battle Engine.
#~   #--------------------------------------------------------------------------
#~   if $imported["YEA-BattleEngine"]
#~   alias battle_luna_yea_update_battler_name update_battler_name
#~   def update_battler_name
#~     return unless @actor_window
#~     return unless @enemy_window
#~     battle_luna_yea_update_battler_name
#~   end
#~   end
#~   
#~ end # Window_BattleHelp

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: create_new_popup
  # Compatible with YEA - Battle Engine.
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"] && !$imported["YES-BattlePopup"]
  alias battle_luna_yea_create_new_popup create_new_popup
  def create_new_popup(value, rules, flags)
    battle_luna_yea_create_new_popup(value, rules, flags)
    @popups.each { |popup| 
      popup.viewport = nil
      popup.z = @battler.screen_z + 1000
    }
  end
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Window_BattleHelp
#==============================================================================

class Window_BattleHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # alias method: update_battler_name
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias battle_luna_yea_be_update_battler_name update_battler_name
  def update_battler_name
    return unless @actor_window
    return unless @enemy_window
    return unless @actor_window.active || @enemy_window.active
    battle_luna_yea_be_update_battler_name
    return unless LuneEngine::CORE::YEA_COMPATIBILITY[:battle_engine][:target_help] 
    self.show
  end
  end
  
end # Window_BattleHelp

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: command_skill
  #--------------------------------------------------------------------------
  alias battle_luna_yea_command_skill command_skill
  def command_skill
    battle_luna_yea_command_skill
    @status_aid_window.hide if $imported["YEA-BattleEngine"]
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_item
  #--------------------------------------------------------------------------
  alias battle_luna_yea_command_item command_item
  def command_item
    battle_luna_yea_command_item
    @status_aid_window.hide if $imported["YEA-BattleEngine"]
  end
  
  #--------------------------------------------------------------------------
  # alias method: select_actor_selection
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias battle_luna_yea_select_actor_selection select_actor_selection
  def select_actor_selection
    battle_luna_yea_select_actor_selection
    return if LuneEngine::CORE::YEA_COMPATIBILITY[:battle_engine][:target_help] 
    @help_window.hide
  end
  end

  #--------------------------------------------------------------------------
  # alias method: select_enemy_selection
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias battle_luna_yea_select_enemy_selection select_enemy_selection
  def select_enemy_selection
    battle_luna_yea_select_enemy_selection
    return if LuneEngine::CORE::YEA_COMPATIBILITY[:battle_engine][:target_help] 
    @help_window.hide
  end
  end
  
  #--------------------------------------------------------------------------
  # alias method: show_comparison_windows
  # Compatible with YEA - Enemy Target Info.
  #--------------------------------------------------------------------------
  if $imported["YEA-EnemyTargetInfo"]
  alias battle_luna_yea_show_comparison_windows show_comparison_windows
  def show_comparison_windows
    battle_luna_yea_show_comparison_windows
    @status_window.hide
  end
  end

  #--------------------------------------------------------------------------
  # alias method: hide_comparison_windows
  # Compatible with YEA - Enemy Target Info.
  #--------------------------------------------------------------------------
  if $imported["YEA-EnemyTargetInfo"]
  alias battle_luna_yea_hide_comparison_windows hide_comparison_windows
  def hide_comparison_windows
    battle_luna_yea_hide_comparison_windows
    @status_window.show
  end
  end

  #--------------------------------------------------------------------------
  # alias method: hide_ftb_action_windows
  # Compatible with YEA - Battle System Add-On: Free Turn Battle.
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleSystem-FTB"]
  alias battle_luna_yea_hide_ftb_action_windows hide_ftb_action_windows
  def hide_ftb_action_windows
    battle_luna_yea_hide_ftb_action_windows
    @actor_command_window.close
  end
  end
  
  #--------------------------------------------------------------------------
  # alias method: show_ftb_action_windows
  # Compatible with YEA - Battle System Add-On: Free Turn Battle.
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleSystem-FTB"]
  alias battle_luna_yea_show_ftb_action_windows show_ftb_action_windows
  def show_extra_gauges
    battle_luna_yea_show_ftb_action_windows
    @actor_command_window.open
  end
  end
  
end # Scene_Battle

#==============================================================================
# ■ Scene_Menu
#==============================================================================

class Scene_Menu < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # removed method: relocate_windows
  # Compatible with YEA - Ace Menu Engine.
  # ------------------------------------------------------------------------
  # We don't need those relocate method because Luna Engine will relocate
  # windows itself.
  #--------------------------------------------------------------------------
  def relocate_windows
  end
  
end # Scene_Menu

#==============================================================================
# ■ Scene_Item
#==============================================================================

class Scene_Item < Scene_ItemBase
  
  #--------------------------------------------------------------------------
  # removed method: relocate_windows
  # Compatible with YEA - Ace Menu Engine.
  # We don't need those relocate method because Luna Engine will relocate
  # windows itself.
  #--------------------------------------------------------------------------
  def relocate_windows
  end
  
end # Scene_Item

#==============================================================================
# ■ Scene_Skill
#==============================================================================

class Scene_Skill < Scene_ItemBase
  
  #--------------------------------------------------------------------------
  # removed method: relocate_windows
  # Compatible with YEA - Ace Menu Engine.
  # We don't need those relocate method because Luna Engine will relocate
  # windows itself.
  #--------------------------------------------------------------------------
  def relocate_windows
  end
  
end # Scene_Skill

#==============================================================================
# ■ Scene_Equip
#==============================================================================

class Scene_Equip < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # removed method: relocate_windows
  # Compatible with YEA - Ace Menu Engine.
  # We don't need those relocate method because Luna Engine will relocate
  # windows itself.
  #--------------------------------------------------------------------------
  def relocate_windows
  end
  
  #--------------------------------------------------------------------------
  # removed method: relocate_aee_windows
  # Compatible with YEA - Ace Menu Engine.
  # We don't need those relocate method because Luna Engine will relocate
  # windows itself.
  #--------------------------------------------------------------------------
  def relocate_aee_windows
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_item_window
  # Compatible with YEA - Ace Equip Engine.
  #--------------------------------------------------------------------------
  if $imported["YEA-AceEquipEngine"]
  alias lune_engine_yea_create_item_window create_item_window
  def create_item_window
    lune_engine_yea_create_item_window
    hide = LuneEngine::CORE::YEA_COMPATIBILITY[:equip_engine][:hide_item_window]
    return if hide
    @item_window.show
  end
  end

  #--------------------------------------------------------------------------
  # alias method: on_item_ok
  # Compatible with YEA - Ace Equip Engine.
  #--------------------------------------------------------------------------
  if $imported["YEA-AceEquipEngine"]
  alias lune_engine_yea_on_item_ok on_item_ok
  def on_item_ok
    lune_engine_yea_on_item_ok
    hide = LuneEngine::CORE::YEA_COMPATIBILITY[:equip_engine][:hide_item_window]
    return if hide
    @item_window.show
  end
  end

  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  # Compatible with YEA - Ace Equip Engine.
  #--------------------------------------------------------------------------
  if $imported["YEA-AceEquipEngine"]
  alias lune_engine_yea_on_item_cancel on_item_cancel
  def on_item_cancel
    lune_engine_yea_on_item_cancel
    hide = LuneEngine::CORE::YEA_COMPATIBILITY[:equip_engine][:hide_item_window]
    return if hide
    @item_window.show
  end
  end

  #--------------------------------------------------------------------------
  # alias method: on_slot_ok
  # Compatible with YEA - Ace Equip Engine.
  #--------------------------------------------------------------------------
  if $imported["YEA-AceEquipEngine"]
  alias lune_engine_yea_on_slot_ok on_slot_ok
  def on_slot_ok
    lune_engine_yea_on_slot_ok
    hide = LuneEngine::CORE::YEA_COMPATIBILITY[:equip_engine][:hide_slot_window]
    return if hide
    @slot_window.show
  end
  end

  #--------------------------------------------------------------------------
  # alias method: create_actor_window
  # Compatible with YEA - Ace Equip Engine.
  # We hide actor window because Luna Engine has an add-on to do this.
  #--------------------------------------------------------------------------
  if $imported["YEA-AceEquipEngine"]
  alias luna_engine_yea_create_actor_window create_actor_window
  def create_actor_window
    luna_engine_yea_create_actor_window
    @actor_window.x = 999
  end
  end
  
end # Scene_Equip