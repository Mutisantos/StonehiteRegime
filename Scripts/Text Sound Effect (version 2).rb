#==============================================================================
# Text Sound Effect (version 2)
# NEW FEATURE: Switch to turn off sound effect
#------------------------------------------------------------------------------
# by Zerbu
#==============================================================================
module Text_Sound_Effect
  #--------------------------------------------------------------------------
  # Options
  #--------------------------------------------------------------------------
  # The sound effect to play
  MESSAGE_SOUND = RPG::SE.new("text_sound.ogg", 80, 100)

  # The number of characters to display before each time the sound plays
  # The default is 3, it's recommended you keep it as this unless you
  # know what you're doing
  MESSAGE_SOUND_FRAMES = 10

  # Switch to disable sound effect
  # If you need to turn off the sound effect for any part of the game,
  # turn this switch on
  # Set to nil to disable this feature
  MESSAGE_SOUND_DISABLE = nil
  
end

class Window_Message < Window_Base
  include Text_Sound_Effect
  #--------------------------------------------------------------------------
  # alias method: process_characer
  #--------------------------------------------------------------------------
  alias textsound_process_character_normal process_character
  def process_character(c, text, pos)
    if !MESSAGE_SOUND_DISABLE or !$game_switches[MESSAGE_SOUND_DISABLE]
      #---
      if !defined?(@sound_frames)
        @sound_frames = 0
      end
      #---
      if @sound_frames == 0
        MESSAGE_SOUND.play
      end
      #---
      @sound_frames+=1
      #---
      if @sound_frames == MESSAGE_SOUND_FRAMES
        @sound_frames = 0
      end
      #---
    end
    textsound_process_character_normal(c, text, pos)
  end
  #---
end