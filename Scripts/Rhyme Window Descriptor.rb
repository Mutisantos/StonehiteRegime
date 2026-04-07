#==============================================================================
# ■ Window Identifier (WINDOW_IDENTIFIER) by rhyme
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Shows the name of the windows depending on the present class while holding 
# CTRL. Make sure to disable this on your game's final release!
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Create Window Contents
  #--------------------------------------------------------------------------
  alias create_contents_rhy create_contents
  def create_contents
    create_contents_rhy
    if @windowname
      @windowname.bitmap.dispose
      @windowname.dispose
      @windowname = nil
    end
    @windowname = Sprite.new(self.viewport)
    @windowname.bitmap = Bitmap.new(500, line_height)
    @windowname.bitmap.draw_text(0, 0, 500, 24, self.class.to_s, 0)
    @windowname.opacity = 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias update_rhy update
  def update
    update_rhy
    @windowname.x = self.x
    @windowname.y = self.y
    @windowname.z = self.z + 1
    if Input.press?(:CTRL)
      @windowname.opacity += 16
    else
      @windowname.opacity -= 16
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_rhy dispose
  def dispose
    if @windowname
      @windowname.bitmap.dispose
      @windowname.dispose
      @windowname = nil
    end
    dispose_rhy
  end  
end