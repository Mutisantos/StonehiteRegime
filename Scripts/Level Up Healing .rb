############################################
#                                          #
#         LEVEL-UP HEALING v1.0            #
#                                          #
#     Community DLC Content for VX Ace     #
#                                          #
# Created by Jason "Wavelength" Commander  #
#                                          #
############################################

# "Your Level doesn't really mean anything, right?"
#                                       ~ Misaka, A Certain Scientific Railgun


############################################
#                                          #
#           ABOUT THIS SCRIPT              #
#                                          #
############################################

# This script will automatically heal a character when they Level Up.
#     You can set the healing to be equal to the amount of Max HP (MP)
#     gained by the Level Up, or you can heal them completely.

# This script is compatible with nearly all other scripts, including the
#     "Level-Up Healing" script that is also included in this pack.
#     If you are using any other scripts that alias level_up, be
#     judicious about where you place them, as this script needs
#     to do operations both before and after the normal "level_up" method.

# As part of the Community DLC Pack, you may use this script royalty-free
#     for commercial or noncommercial use in any RPG Maker project.

# More of my work can be found at wavescripts.wordpress.com.


############################################
#                                          #
#         HOW TO USE THIS SCRIPT           #
#                                          #
############################################

# This script should be placed in the "Materials" section
#     of the script editor.  In general, this script should
#     be placed below other scripts that modify the level_up
#     method, but you may need to play around with the order.


############################################
#                                          #
#          LEVEL-UP HEALING SETUP          #
#                                          #
############################################

# All of the following options can be left alone if desired, or you can
#      modify them to better customize the script to your game.
  
module LU_Healing
  
  # Set the HP and MP Heal Modes based on the desired HP/MP healing behavior
  #   when a character Levels Up!
  #   0: HP (MP) will not be restored upon Leveling Up.
  #   1: HP (MP) equal to the Max HP (MP) gained by Leveling Up will be restored
  #         (e.g., if you're 113/140 HP before Level Up, you'll be 133/160 after).
  #   2: HP (MP) will be restored completely upon Leveling Up.
  
  HP_Heal_Mode = 1
  
  MP_Heal_Mode = 1
  
end

############################################
#                                          #
#               ICKY CODE!                 #
#                                          #
############################################

# Everything from here on represents the inner workings of the script.
#       Please don't alter anything from here on unless you are an
#       advanced scripter yourself (in which case, have at it!)  


class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------
  # * Level Up
  #--------------------------------------------------------------------------
  alias :healing_level_up :level_up
  def level_up
    # Note the Max HP and Max MP right before leveling up
    last_mhp = mhp
    last_mmp = mmp
    # Do normal Level Up Processing
    healing_level_up
    # Heal HP to a character upon leveling up
    case LU_Healing::HP_Heal_Mode
    when 1
      @hp += (mhp - last_mhp)
      @hp = [@hp, 1].max
    when 2
      @hp = mhp
    else
    end
    # Heal MP to a character upon leveling up
    case LU_Healing::MP_Heal_Mode
    when 1
      @mp += (mmp - last_mmp)
    when 2
      @mp = mmp
    else
    end
  end
  
end