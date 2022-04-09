#------------------------------------------------------------------------------#
#  Galv's Group Manager
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.3
#------------------------------------------------------------------------------#
#  2012-11-20 - Version 1.3 - added minimum member requirement option for groups
#                           - added option to require unassigned actor
#                           - added save/loading of groups and unassigned actors
#  2012-11-20 - Version 1.2 - changes to scene useability and options added
#  2012-11-20 - Version 1.1 - can now have more than 4 groups and 8 max in each
#  2012-11-20 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  This script allows the player to distribute their party members into separate
#  teams.
#------------------------------------------------------------------------------#
#  INSTRUCTIONS:
#  Read the setup options below and set it up as desired.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------##
#  SCRIPT CALLS:
#------------------------------------------------------------------------------#
#  groups(amount)       # change the number of groups the player can distrubute
#                       # members to.
#------------------------------------------------------------------------------#
#  group_clear(id)      # remove all members from one group
#------------------------------------------------------------------------------#
#  group_clear_all      # remove all members from all groups
#------------------------------------------------------------------------------#
#  group_count(id)      # use in variable script. Gets number of actors in group
#------------------------------------------------------------------------------#
#  group_save(group_id,save_id)   # save group to any save position (save_id)
#                                 # more description of this feature below:
#  # whenever you leave the group_manager scene, it automatically saves all
#  # unassigned members to save_id 0. This data will remain in save_id 0 until
#  # you enter and leave the group_manager scene again.
#  # To save 'save_id 0' elsewhere, use 0 for group_id. eg: group_save(0,save_id)
#------------------------------------------------------------------------------#
#  group_load(save_id,x)  # x can be 0 or 1. Adds the saved group to party and...
#                         # if x is 0, removes all other party members
#                         # if x is 1, keeps current party members
#------------------------------------------------------------------------------#
#  group_info(id,"name",max,lock,min)  # Set individual group options:
#                                      # id = group number   
#                                      # name = used instead of default name
#                                      # max = max members in the group
#                                      # min = must have at least this many
#                                      # lock = true or false
#                                      # true prevents changes to the group
#  # name, max, lock and min can be set to nil, which won't change that setting.
#
#  EXAMPLE OF USE:
#  group_info(1,"Into the Forest",4,false,2)
#  group_info(2,"Remain at Base",2,false,0)
#  group_info(2,nil,nil,true,nil)
#------------------------------------------------------------------------------#
#  group_info_reset(id)      # resets a group's info changes to default
#------------------------------------------------------------------------------#  
#  group_info_reset_all      # resets all groups info to default
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  change_party(id)          # replace current party with members in that group
#------------------------------------------------------------------------------#
#  collect_groups(x)         # x can be 0 or 1. Adds all groups to party and...
#                            # if x is 0, removes members from all groups
#                            # if x is 1, leaves members in the groups
#------------------------------------------------------------------------------#
#  collect_group(id,x)       # x can be 0 or 1. Adds only members from group with
#                            # that id to party and...
#                            # if x is 0, removes members from that group
#                            # if x is 1, leaves members in that group
#------------------------------------------------------------------------------#



#------------------------------------------------------------------------------#
#  SCRIPT CALLS TO CALL THE GROUP MANAGER SCENES:
#------------------------------------------------------------------------------#
#
#  group_manager       # Calls the group manager scene.
#
#  group_selector      # Calls the group select scene to change to a group.
#
#------------------------------------------------------------------------------#


($imported ||= {})["Galv_Party_Split"] = true
module Galv_Split

#------------------------------------------------------------------------------#
#  SCRIPT SETUP OPTIONS
#------------------------------------------------------------------------------#
  
  ONLY_ONE_GROUP = true      # true = restrict actors to only one group
                             # false = allow actors to be in multiple groups

  REQUIRE_GROUPED = false     # true = must add all party members into a group
                              # false = can leave scene without adding members
  REQUIRE_UNASSIGNED = true   # require at least 1 un-assigned actor in party
                              # this only works if above REQUIRE_GROUPED = false

  EMPTY_TEXT = "Empty"         # Text displayed when no actors in a group
  LOCKED_TEXT = "Locked"       # Displayed when you lock a group
  MIN_MEMBER_TEXT = "Required" # Displayed when group requires min no. members
  
  ADD_SE = ["Equip1", 80, 100]   # SE played when member is added
  REM_SE = ["Wind7", 80, 100]    # SEO played when member is removed
                                 # ["SE Name", volume, pitch]

  SELECTOR_SE = ["Barrier", 80, 100]  # SE played when a group is chosen in
                                      #  the group_selector scene
  
  CHOSEN_GROUP_VAR = 1       # Variable used to store the group chosen in the
                             # group selector scene (for eventing purposes).


  # DEFAULTS (These can be changed during game with script calls)

  GROUP_NAME = "Group"       # The name of each group/party
  NO_GROUPS = 5              # no. groups the player can add members to
  NO_MEMBERS = 8             # no. members each group can have. (max 8)

#------------------------------------------------------------------------------#
#  END SCRIPT SETUP OPTIONS
#------------------------------------------------------------------------------#

end


class Scene_GroupManager < Scene_MenuBase
  
  def start
    super
    @error_timer = 0
    create_groups_window
    create_party_window
    create_error_window
  end
  
  def update
    if @error_timer >= 0
      @error_timer -= 1
      on_error_ok if @error_timer == 0
    end
    super
  end
  
#--------------------------------------------------------------------------
  def create_error_window
    @error_window = Window_Error.new
    @error_window.hide
    @error_window.z = @group_window.z + 1
  end
  
  def on_error_ok
    @error_window.hide
    @party_window.activate
  end
#--------------------------------------------------------------------------  
  def create_party_window
    @party_window = Window_Party_List.new(0)
    @party_window.set_handler(:ok,     method(:on_party_ok))
    @party_window.set_handler(:cancel, method(:on_party_cancel))
    @party_window.activate
    @party_window.select(0)
  end
  
  def on_party_ok
    check_if_locked
    if @locked_members.include?($game_party.members[@party_window.index].id)
      $game_temp.group_error = "Member in locked group."
      show_error
      @party_window.deactivate
    else
      @party_index = @party_window.index
      @group_index = 0 if @group_index.nil?
      @party_window.deactivate
      @group_window.activate
      @group_window.select(@group_index)
    end
  end
  def on_party_cancel
    check_members_in_groups
    check_min_group_members

    
    if @check_arrays.sort != @party_array.sort && Galv_Split::REQUIRE_GROUPED
      # Check all members have been distributed
      $game_temp.group_error = "All members must be in a group."
      show_error
    elsif @min_number_check == false
      # Check if all groups have minimum requirement of members filled
      $game_temp.group_error = "A group requires members."
      show_error
    elsif Galv_Split::REQUIRE_UNASSIGNED && !Galv_Split::REQUIRE_GROUPED
      # Check if at least 1 unassigned party member remains
      if @check_arrays.sort == @party_array.sort
        $game_temp.group_error = "One member must be unassigned."
        show_error
      else
        $game_party.saved_group[0] = @party_array.sort - @group_array.sort
        SceneManager.return
      end
    else
      $game_party.saved_group[0] = @party_array.sort - @group_array.sort
      SceneManager.return
    end
  end
  
  def check_min_group_members
    @min_number_check = true
    $game_party.group.each do |g|
      if !$game_party.group_info[g[0]][3].nil?
        if $game_party.group_info[g[0]][3] > g[1].count
          # min number fails for group unless group is locked
          @min_number_check = false if $game_party.group_info[g[0]][2] != true
        end
      end
    end
  end
  
  def check_members_in_groups
    @party_array = []
    $game_party.members.each do |m|
      @party_array << m.id
    end
    @group_array = $game_party.group.values.flatten
    @check_arrays = @group_array.sort & @party_array.sort
  end
  
  def show_error
    Sound.play_buzzer
    @error_window.refresh
    @error_window.show
    @error_timer = 60
  end
  
#--------------------------------------------------------------------------
  def create_groups_window
    @group_window = Window_Group_List.new(0)
    @group_window.set_handler(:ok,     method(:on_group_ok))
    @group_window.set_handler(:cancel, method(:on_group_cancel))
    @group_window.deactivate
  end
  
  def on_group_ok
    member_action
    @group_window.refresh(0)
    @party_window.refresh(0)
  end
  def on_group_cancel
    @group_index = @group_window.index
    @group_window.select(-1)
    @group_window.deactivate
    @party_window.activate
    @party_window.select(@party_index)
  end
  
  def member_action
    @g = @group_window.index
    @p = @party_window.index
    
    # Check if group locked
    if !$game_party.group_info[@g][2].nil?
      return Sound.play_buzzer if $game_party.group_info[@g][2] == true
    end
    
    if $game_party.group[@g].include?($game_party.members[@p].id)
      remove_member
    else
      return Sound.play_buzzer if $game_party.group[@g].count >= max_members
      remove_from_all_groups if Galv_Split::ONLY_ONE_GROUP
      add_member
    end
  end
  
  def add_member
    RPG::SE.new(Galv_Split::ADD_SE[0], Galv_Split::ADD_SE[1], Galv_Split::ADD_SE[2]).play                              
    $game_party.group[@g] << $game_party.members[@p].id
  end
  
  def max_members
    if $game_party.group_info[@g][1].nil?
      return Galv_Split::NO_MEMBERS
    else
      return $game_party.group_info[@g][1]
    end
  end
  
  def remove_member
    RPG::SE.new(Galv_Split::REM_SE[0], Galv_Split::REM_SE[1], Galv_Split::REM_SE[2]).play                              
    $game_party.group[@g] -= [$game_party.members[@p].id]
  end
  
  def remove_from_all_groups
    $game_party.group.each_with_index do |g,i|
      $game_party.group[i] -= [$game_party.members[@p].id]
    end
  end
  
  def check_if_locked
    @locked_members = []
    $game_party.group.each_with_index do |g,i|
      if !$game_party.group_info[i][2].nil?
        @locked_members += $game_party.group[i] if $game_party.group_info[i][2]
      end
    end
  end
  
end

#--------------------------------------------------------------------------
#  * New Window - Party List
#--------------------------------------------------------------------------

class Window_Party_List < Window_Selectable

  def initialize(data)
      super(party_x, (Graphics.height - 410) / 2, 96 + standard_padding * 2, 410)
      self.opacity = 255
      @index = 0
      @set = true
      @item_max = $game_party.members.count
      refresh(data)
      select(0)
      activate
    end
    
  def party_x
    ((Graphics.width - 400 - (96 + standard_padding * 2)) / 2)
  end

  def refresh(data)
      self.contents.clear
      self.contents = Bitmap.new(96, @item_max * 96)
      for i in 0...@item_max
         draw_item(i) unless i == nil
      end
  end
  
  def check_item_max
     @data_max = 0
     for i in $game_party.members
         @data_max += 1
     end
  end
  
  def item_height
    96
  end

  def draw_item(index)
    x = 0
    y = (index) / col_max * 96
    check_item_max
    @mem = $game_party.members
    check_if_set(@mem[index].id)
    draw_face(@mem[index].face_name, @mem[index].face_index, x, y, @set)
  end
    
  def check_if_set(check)
    $game_party.group.each do |i|
      if !$game_party.group.values.flatten.include?(check)
        @set = true
      else
        @set = false
      end
    end
  end

  def item_max
    return @item_max == nil ? 0 : @item_max 
  end      
  
  def process_ok
    call_ok_handler
  end
  
end

#--------------------------------------------------------------------------
#  * New Window - Groups
#--------------------------------------------------------------------------

class Window_Group_List < Window_Selectable

  def initialize(data)
    super(group_x(data), (Graphics.height - 410) / 2, 400, 410)
    self.opacity = 255
    @index = 0
    refresh(data)
    select(-1)
    activate
  end
  
  def group_x(data)
    if data == 1
      return ((Graphics.width - 400) / 2)
    else
      return ((Graphics.width - 400 + (96 + standard_padding * 2)) / 2)
    end
  end
  
  def refresh(data)
    @item_max = $game_party.no_groups
    
    self.contents.clear
    return if @item_max == 0
    
    self.contents = Bitmap.new(370, @item_max * 96)
    for i in 0...@item_max
      draw_item(i) unless i == nil
    end
  end
  
  def check_item_max
    @data_max = 0
    for i in $game_party.group
      @data_max += 1
    end
  end
   
  def item_height
    96
  end

  def draw_item(index)
    x = 0
    y = (index) / col_max * 96
    check_item_max
    
    mem_in_party = 0
    
    if $game_party.group_info[index][0].nil?
      self.contents.draw_text(x, y, 300, 24, Galv_Split::GROUP_NAME + " " + (index + 1).to_s,0)
    else
      self.contents.draw_text(x, y, 300, 24, $game_party.group_info[index][0],0)
    end
    
    if !$game_party.group[index].nil? && $game_party.group[index] != []
      actor = $game_actors
      $game_party.group[index].each_with_index do |data,i|
        draw_character(actor[data].character_name, actor[data].character_index,x + 25 + i * 45, y + 70)
      end
      mem_in_party = $game_party.group[index].count
    elsif $game_party.group[index] == [] || $game_party.group[index].nil?
      self.contents.draw_text(x, y + 24, 300, 24, Galv_Split::EMPTY_TEXT,0)
    end
    
    if $game_party.group_info[index][1].nil?
      self.contents.draw_text(x, y, 370, 24, mem_in_party.to_s + "/" + Galv_Split::NO_MEMBERS.to_s,2)
    else
      self.contents.draw_text(x, y, 370, 24, mem_in_party.to_s + "/" + $game_party.group_info[index][1].to_s,2)
    end
    
    lock_on = false
    if !$game_party.group_info[index][2].nil?
      if $game_party.group_info[index][2] == true
        lock_on = true
        self.contents.draw_text(x, y + 60, 370, 24, Galv_Split::LOCKED_TEXT,1)
      end
    end
    
    if !$game_party.group_info[index][3].nil? && lock_on == false
      if $game_party.group_info[index][3] > 0
        self.contents.draw_text(x, y + 60, 370, 24, Galv_Split::MIN_MEMBER_TEXT + " " + $game_party.group_info[index][3].to_s,1)
      end
    end    
    
    
  end
    
  def item_max
    return @item_max == nil ? 0 : @item_max 
  end      
  
  def process_ok
    call_ok_handler
  end
  

  
end # Window_Group_List < Window_Selectable


#--------------------------------------------------------------------------
#  * New Window - ERROR
#--------------------------------------------------------------------------

class Window_Error < Window_Base
  
  def initialize
    super(error_x, error_y, error_width, fitting_height(1))
    refresh
  end
  
  def error_x
    (Graphics.width - error_width + (96 + standard_padding * 2)) / 2
  end
  
  def error_y
    (Graphics.height - fitting_height(1)) / 2
  end
  
  def error_width
    380
  end

  def refresh
    contents.clear
    change_color(text_color(6))
    draw_text(0, 0, contents.width, contents.height, $game_temp.group_error.to_s,1)
  end

  def open
    refresh
    super
  end
end # Window_Error < Window_Base


class Scene_GroupSelector < Scene_MenuBase
  
  def start
    super
    create_groups_window
  end

  def create_groups_window
    @group_window = Window_Group_List.new(1)
    @group_window.set_handler(:ok, method(:on_group_ok))
    @group_window.set_handler(:cancel, method(:on_group_cancel))
    @group_window.activate
    @group_window.select(0)
  end
  
  def on_group_ok
    g = @group_window.index
    
    if !$game_party.group_info[g][2].nil?
      return Sound.play_buzzer if $game_party.group_info[g][2] == true
    end
    
    SceneManager.return
    
    if $game_party.group[g].count != 0
      RPG::SE.new(Galv_Split::SELECTOR_SE[0], Galv_Split::SELECTOR_SE[1], Galv_Split::SELECTOR_SE[2]).play
      $game_variables[Galv_Split::CHOSEN_GROUP_VAR] = g + 1
    else
      Sound.play_cancel
    end
    return if $game_party.group[g].nil? || $game_party.group[g].count == 0
    $game_party.members.each do |actor|
      $game_party.remove_actor(actor.id)
    end
    $game_party.group[g].each do |actor_id|
      $game_party.add_actor(actor_id)
    end
  end
  
  def on_group_cancel
    SceneManager.return
  end

end # Scene_GroupSelector < Scene_MenuBase


class Game_Temp
  attr_accessor :group_error
end # Game_Temp


class Game_Party < Game_Unit
  attr_accessor :group
  attr_accessor :saved_group
  attr_accessor :no_groups
  attr_accessor :group_info
  
  alias galv_partysplit_initialize initialize
  def initialize
    @no_groups = Galv_Split::NO_GROUPS
    @saved_group = {}
    init_groups
    init_group_info
    galv_partysplit_initialize
  end
  
  def init_groups
    @group = {}
    @no_groups.times { |i|
      @group[i] = []
    }
  end
  
  def init_group_info
    @group_info = {}
    @no_groups.times { |i|
      @group_info[i] = []
    }
  end
  
end # Game_Party < Game_Unit


class Game_Interpreter
  def groups(amount)
    $game_party.no_groups = amount
    $game_party.init_groups
  end
  def group_info(id,name,max_mem,lock,min_mem)
    $game_party.group_info[id-1][0] = name if !name.nil?
    $game_party.group_info[id-1][1] = max_mem if !max_mem.nil?
    $game_party.group_info[id-1][2] = lock if !lock.nil?
    $game_party.group_info[id-1][3] = min_mem if !min_mem.nil?
  end
  def group_info_reset(id)
    $game_party.group_info[id-1] = []
  end
  def group_info_reset_all
    $game_party.init_group_info
  end
  def group_clear(id)
    $game_party.group[id-1] = []
  end
  def group_clear_all
    $game_party.init_groups
  end
  
  def group_save(group_id,save_id)
    return if $game_party.group[group_id-1].nil? && group_id != 0
    if group_id == 0
      $game_party.saved_group[save_id] = $game_party.saved_group[0]
    else
      $game_party.saved_group[save_id] = $game_party.group[group_id-1]
    end
  end
  
  def group_load(save_id,type)
    return if $game_party.saved_group[save_id].nil?
    return if $game_party.saved_group[save_id].count == 0
    if type == 0
      $game_party.members.each do |actor|
        $game_party.remove_actor(actor.id)
      end
    end
    $game_party.saved_group[save_id].each do |mem|
      $game_party.add_actor(mem)
    end
  end
  
  
  def group_count(id)
    $game_party.group[id-1].count
  end
  
  def change_party(group_id)
    return if $game_party.group[group_id-1].nil?
    return if $game_party.group[group_id-1].count == 0
    $game_party.members.each do |actor|
      $game_party.remove_actor(actor.id)
    end
    $game_party.group[group_id-1].each do |actor_id|
      $game_party.add_actor(actor_id)
    end
  end
  
  def collect_groups(type)
    $game_party.group.each do |g|
      g[1].each do |id|
        $game_party.add_actor(id)
      end
    end
    if type == 0
      $game_party.init_groups
    end
  end
  
  def collect_group(group_id,type)
    $game_party.group[group_id-1].each do |mem|
      $game_party.add_actor(mem)
    end
    if type == 0
      $game_party.group[group_id-1] = []
    end
  end
  
  def group_manager
    SceneManager.call(Scene_GroupManager)
    wait(1)
  end
  
  def group_selector
    SceneManager.call(Scene_GroupSelector)
    wait(1)
  end

end # Game_Interpreter