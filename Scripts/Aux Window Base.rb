class SkillWindow_Bar < Window_Base

    reduce_rate = 0

    def initialize(x=220, y=0 , h=60, w=200)
        super(x,y,h,w)
        self.contents = Bitmap.new(width-8, height-8)
        self.opacity = 200
        self.z = 1
        self.arrows_visible = false
        self.ox = -50
        self.oy = -10
        @reduce_rate = 0.0
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
        fill_rate = $game_variables[105].to_f
        if penalty > 0
            @reduce_rate = @reduce_rate + (1.0 / penalty)
            fill_rate = fill_rate - @reduce_rate
        end 
        # p(@reduce_rate)  
        bitmap = Bitmap.new("Graphics/System/bar.png")
        cw = ((bitmap.width * fill_rate) + 1 )/ $game_variables[106].to_f         
        ch = bitmap.height * 10
        src_rect = Rect.new(x, y, cw, ch)
        self.contents.blt(x, y, bitmap, src_rect)
        if penalty == 0 
            pitch = 70.0 + (fill_rate/$game_variables[106].to_f)*20.0
            RPG::SE.new("correctbuzz",100,pitch).play
        end
        $game_variables[102] = (cw / bitmap.width) + 0.25
        p ($game_variables[102])
    end
end