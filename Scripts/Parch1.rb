=begin
YEA Battle Engine Compatibility Patch for Enu's Tankentai
=end
 
class Sprite_Base < Sprite
 
  unless $imported["YEA-CoreEngine"]
  def start_pseudo_animation(animation, mirror = false)
    return false
  end
  end # $imported["YEA-CoreEngine"]
 
end
 
class Sprite_Battler < Sprite_Base
 
  unless $imported["YEA-CoreEngine"]
  alias sprite_battler_setup_new_animation_abe setup_new_animation  
  def setup_new_animation
    sprite_battler_setup_new_animation_abe
    return false
  end
  end # $imported["YEA-CoreEngine"]
 
end

 
class Scene_Battle < Scene_Base
 
  def show_normal_animation(targets, animation_id, mirror = false)
    return false
  end
 
  def show_all_animation?(item)
    return false
  end
 
  def separate_ani?(target, item)
    return false
  end
 
  def load_notetags_abe
    @one_animation = false
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEA::REGEXP::USABLEITEM::ONE_ANIMATION
        @one_animation = false
      end
    } # self.note.split
    #---
  end
 
end