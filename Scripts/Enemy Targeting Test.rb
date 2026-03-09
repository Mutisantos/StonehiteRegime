#==============================================================================
# ■ Enemy Targeting Test
#------------------------------------------------------------------------------
# Simple test to verify the Advanced Enemy Targeting System integration
#==============================================================================

module EnemyTargetingTest
  def self.run_test
    return unless $game_party && $game_party.in_battle
    
    puts "=== Enemy Targeting System Test ==="
    
    # Test each enemy in the troop
    $game_troop.members.each do |enemy|
      next unless enemy.alive?
      
      puts "\nTesting Enemy: #{enemy.name} (ID: #{enemy.enemy_id})"
      
      # Test target type parsing
      target_type = enemy.enemy_type rescue :random
      puts "  Target Type: #{target_type}"
      
      # Test strategic target selection
      if enemy.respond_to?(:select_strategic_target)
        targets = $game_party.alive_members
        selected = enemy.select_strategic_target(targets)
        puts "  Selected Target: #{selected ? selected.name : 'None'}"
        
        # Test memory system
        if enemy.respond_to?(:should_retarget_last?)
          should_retarget = enemy.should_retarget_last?(targets)
          puts "  Should Retarget Last: #{should_retarget}"
        end
      else
        puts "  ERROR: select_strategic_target method not found"
      end
      
      # Test role detection on actors
      $game_party.alive_members.each do |actor|
        healer = enemy.healer?(actor) rescue false
        mage = enemy.mage?(actor) rescue false
        tank = enemy.tank?(actor) rescue false
        
        if healer || mage || tank
          puts "  #{actor.name}: Healer=#{healer}, Mage=#{mage}, Tank=#{tank}"
        end
      end
    end
    
    puts "\n=== Test Complete ==="
  end
end

# Add test command to debug menu
class Window_DebugLeft < Window_Selectable
  alias enemy_targeting_refresh refresh
  
  def refresh
    enemy_targeting_refresh
    # Add test option at the end of debug menu
    @data.push("Test Enemy Targeting")
  end
end

class Scene_Debug
  alias enemy_targeting_update_target update_target
  
  def update_target
    enemy_targeting_update_target
    
    # Check if test option is selected
    if @left_window.index == @left_window.item_max - 1
      EnemyTargetingTest.run_test
    end
  end
end
