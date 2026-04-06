#==============================================================================
# ■ MenuLuna: Lunatic Common Methods
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This will handle base of the lunatic code. 
# You can import and add your own configurations.
# This is meant for advanced users.
#==============================================================================
#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================
module MenuLuna
  module MainMenu
    
    def self.command_text(index, contents, item_rect, enable, select)
      result = user_command_text(index, contents, item_rect, enable, select)
      import = import_command_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_command_text(index, contents, item_rect, enable, select)
      {}
    end
    
    def self.status_text(index, actor, contents, item_rect, enable, select, formation)
      result = user_status_text(index, actor, contents, item_rect, enable, select, formation)
      import = import_status_text(index, actor, contents, item_rect, enable, select, formation)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(index, actor, contents, item_rect, enable, select, formation)
      {}
    end
    
    def self.gold_text(contents)
      result = user_gold_text(contents)
      import = import_gold_text(contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_gold_text(contents)
      {}
    end
    
  end # MainMenu
  
  module ItemMenu
    
    def self.category_text(index, contents, item_rect, enable, select)
      result = user_category_text(index, contents, item_rect, enable, select)
      import = import_category_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_category_text(index, contents, item_rect, enable, select)
      {}
    end

    def self.item_text(item, contents, item_rect, enable, select)
      result = user_item_text(item, contents, item_rect, enable, select)
      import = import_item_text(item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_item_text(item, contents, item_rect, enable, select)
      {}
    end
    
    def self.status_text(index, actor, contents, item_rect, enable, select, formation)
      result = user_status_text(index, actor, contents, item_rect, enable, select)
      import = import_status_text(index, actor, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(index, actor, contents, item_rect, enable, select)
      {}
    end
    
    def self.description_text(item, contents)
      result = user_description_text(item, contents)
      import = import_description_text(item, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_description_text(item, contents)
      {}
    end
    
  end # ItemMenu
  
  module SkillMenu
    
    def self.category_text(index, contents, item_rect, enable, select)
      result = user_category_text(index, contents, item_rect, enable, select)
      import = import_category_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_category_text(index, contents, item_rect, enable, select)
      {}
    end
    
    def self.skill_text(item, contents, item_rect, enable, select)
      result = user_skill_text(item, contents, item_rect, enable, select)
      import = import_skill_text(item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_skill_text(item, contents, item_rect, enable, select)
      {}
    end
    
    def self.status_text(index, actor, contents, item_rect, enable, select, formation)
      result = user_status_text(index, actor, contents, item_rect, enable, select)
      import = import_status_text(index, actor, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(index, actor, contents, item_rect, enable, select)
      {}
    end
    
    def self.description_text(item, contents)
      result = user_description_text(item, contents)
      import = import_description_text(item, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_description_text(item, contents)
      {}
    end
    
  end # SkillMenu
  
  module StatusMenu
    
    def self.status_text(actor, contents)
      result = user_status_text(actor, contents)
      import = import_status_text(actor, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(actor, contents)
      {}
    end
    
  end # StatusMenu
  
  module SaveMenu
    
    def self.save_text(index, contents, enable)
      result = user_save_text(index, contents, enable)
      import = import_save_text(index, contents, enable)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_save_text(index, contents, enable)
      {}
    end
    
  end # SaveMenu
  
  module EquipMenu
    
    def self.command_text(index, contents, item_rect, enable, select)
      result = user_command_text(index, contents, item_rect, enable, select)
      import = import_command_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_command_text(index, contents, item_rect, enable, select)
      {}
    end

    def self.item_text(item, contents, item_rect, enable, select)
      result = user_item_text(item, contents, item_rect, enable, select)
      import = import_item_text(item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_item_text(item, contents, item_rect, enable, select)
      {}
    end
    
    def self.slot_text(index, item, contents, item_rect, enable, select)
      result = user_slot_text(index, item, contents, item_rect, enable, select)
      import = import_slot_text(index, item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_slot_text(index, item, contents, item_rect, enable, select)
      {}
    end
    
    def self.status_text(actor, temp_actor, contents)
      result = user_status_text(actor, temp_actor, contents)
      import = import_status_text(actor, temp_actor, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(actor, temp_actor, contents)
      {}
    end
    
    def self.description_text(item, contents)
      result = user_description_text(item, contents)
      import = import_description_text(item, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_description_text(item, contents)
      {}
    end
    
  end # EquipMenu
  
  module ShopMenu
    
    def self.command_text(index, contents, item_rect, enable, select)
      result = user_command_text(index, contents, item_rect, enable, select)
      import = import_command_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_command_text(index, contents, item_rect, enable, select)
      {}
    end
    
    def self.category_text(index, contents, item_rect, enable, select)
      result = user_category_text(index, contents, item_rect, enable, select)
      import = import_category_text(index, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_category_text(index, contents, item_rect, enable, select)
      {}
    end

    def self.sell_text(item, contents, item_rect, enable, select)
      result = user_sell_text(item, contents, item_rect, enable, select)
      import = import_sell_text(item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_sell_text(item, contents, item_rect, enable, select)
      {}
    end
    
    def self.buy_text(item, contents, item_rect, enable, select)
      result = user_buy_text(item, contents, item_rect, enable, select)
      import = import_buy_text(item, contents, item_rect, enable, select)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_buy_text(item, contents, item_rect, enable, select)
      {}
    end
    
    def self.gold_text(contents)
      result = user_gold_text(contents)
      import = import_gold_text(contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_gold_text(contents)
      {}
    end
    
    def self.number_text(item, number, price, contents)
      result = user_number_text(item, number, price, contents)
      import = import_number_text(item, number, price, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_number_text(item, number, price, contents)
      {}
    end
    
    def self.status_text(index, item, actor, equippable, cur_item, possesion, contents)
      result = user_status_text(index, item, actor, equippable, cur_item, possesion, contents)
      import = import_status_text(index, item, actor, equippable, cur_item, possesion, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_status_text(index, item, actor, equippable, cur_item, possesion, contents)
      {}
    end
    
    def self.description_text(item, contents)
      result = user_description_text(item, contents)
      import = import_description_text(item, contents)
      return nil unless result
      [result.compact, import]
    end
    
    def self.import_description_text(item, contents)
      {}
    end
    
  end # ShopMenu

end