#------------------------------------------------------------------------------#
#  Mutisantos' Charge Skill Window
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 0.1
#------------------------------------------------------------------------------#
# Call this Window using @window = SkillWindow_Bar.new(80,40,340,80) on an event
# This will open a window that will operate a charge bar based on the values of 
# TIMES_PRESSED and PRESSED_LIMIT game variables. The window disposal is currently
# done also as a script call on an event too.
#------------------------------------------------------------------------------#
class SkillWindow_Bar < Window_Base

    attr_accessor :reduce_rate
    attr_accessor :charge_sfx
    # Damage multiplier game variable
    DAMAGE_MULTIPLIER = 102
    # Damage multiplier game variable
    TIMES_PRESSED = 105
    # Damage multiplier game variable
    PRESS_LIMIT = 106
    
    def initialize(x=220, y=0 , h=60, w=200, sfx = "correctbuzz")
        super(x,y,h,w)
        self.contents = Bitmap.new(width-8, height-8)
        self.opacity = 200
        self.z = 1
        self.arrows_visible = false
        self.ox = -50
        self.oy = -10
        @reduce_rate = 0.0
        @charge_sfx = sfx
        refresh()
    end
        
  
    # ------------------------------------------------- -------------------------
    # ● refresh
    # Current = progress rate (%)
    # ------------------------------------------------- -------------------------
    def refresh (penalty = 0)
      self.contents.clear
      draw_counter_bar(0, 1, penalty) # progress direction: ←    

    end
    # ------------------------------------------------- -------------------------
    # ● Bar display
    # X: x display position
    # Y: y display position
    # Current: progress rate (%)
    # ------------------------------------------------- -------------------------
    def draw_counter_bar (x, y, penalty)
        fill_rate = $game_variables[TIMES_PRESSED].to_f
        if penalty > 0
            @reduce_rate = @reduce_rate + (1.0 / penalty)
            fill_rate = fill_rate - @reduce_rate
        end 
        # p(@reduce_rate)  
        bitmap = Bitmap.new("Graphics/System/bar.png")
        cw = ((bitmap.width * fill_rate) + 1 )/ $game_variables[PRESS_LIMIT].to_f         
        ch = bitmap.height * 10
        src_rect = Rect.new(x, y, cw, ch)
        self.contents.blt(x, y, bitmap, src_rect)
        if penalty == 0 
            pitch = 70.0 + (fill_rate/$game_variables[PRESS_LIMIT].to_f)*20.0
            RPG::SE.new(@charge_sfx,100,pitch).play
        end
        $game_variables[DAMAGE_MULTIPLIER] = (cw / bitmap.width) + 0.25
        # p ($game_variables[DAMAGE_MULTIPLIER])
    end
end