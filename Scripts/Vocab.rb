#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Shop Screen
  ShopBuy         = "Comprar"
  ShopSell        = "Vender"
  ShopCancel      = "Salir"
  Possession      = "Tienes"

  # Status Screen
  ExpTotal        = "Experiencia Total"
  ExpNext         = "Restante %s"

  # Save/Load Screen
  SaveMessage     = "Donde desea guardar?"
  LoadMessage     = "Cual archivo desea cargar?"
  File            = "Archivo"

  # Display when there are multiple members
  PartyName       = "El equipo de %s "

  # Basic Battle Messages
  Emerge          = "%s Apareció!"
  Preemptive      = "%s Ataca Primero!"
  Surprise        = "%s Te sorprendió!"
  EscapeStart     = "%s Comienza a escapar...."
  EscapeFailure   = "No ha podido Escapar"

  # Battle Ending Messages
  Victory         = "%s Ha salido vencedor!"
  Defeat          = "%s Ha sido derrotado."
  ObtainExp       = "Ganas %s Puntos de Experiencia"
  ObtainGold      = "Obtienes %s \\G "
  ObtainItem      = "Obtienes %s"
  LevelUp         = "%s ha subido al nivel %s %s"
  ObtainSkill     = "Has obtenido la habilidad %s"

  # Use Item
  UseItem         = "%s Ha usado %s"

  # Critical Hit
  CriticalToEnemy = "Tu daño ha sido Critico!!!"
  CriticalToActor = "Te han dado un golpe Critico"
  
  # Results for Actions on Actors
  ActorDamage     = "A %s le han hecho %s puntos de daño!!!"
  ActorRecovery   = "%s recupera %s de %s!!!"
  ActorGain       = "%s ha ganado %s de %s!"
  ActorLoss       = "%s ha perdido %s de %s!"
  ActorDrain      = "%s ha perdido %s de %s!"
  ActorNoDamage   = "%s no ha recibido daño!!!"
  ActorNoHit      = "Falló! %s no recibe daño!!!"

  # Results for Actions on Enemies
  EnemyDamage     = "A %s Le han hecho %s puntos de daño!!"
  EnemyRecovery   = "%s recupera %s de %s!!!"
  EnemyGain       = "%s ha ganado %s de %s!"
  EnemyLoss       = "%s ha perdido %s de %s!"
  EnemyDrain      =  "%s ha perdido %s de %s!"
  EnemyNoDamage   = "%s no ha recibido daño!!!"
  EnemyNoHit      = "Falló! %s no recibe daño!!!"
  
  # Evasion/Reflection
  Evasion         = "%s ha esquivado el ataque!!"
  MagicEvasion    = "%s ha esquivado el hechizo!!"
  MagicReflection = "%s ha reflejazo el hechizo"
  CounterAttack   = "%s ha coontratacado!!"
  Substitute      = "%s conjuró %s!!"

  # Buff/Debuff
  BuffAdd         = "%s ahora usa %s!!"
  DebuffAdd       = "%s ahora usa %s!!"
  BuffRemove      = "%s ya no usa %s"
  
  # Skill or Item Had No Effect
  ActionFailure   = "%s ha fallado."

  # Error Message
  PlayerPosError  = "No encuentra el punto de partida del jugador."
  EventOverflow   = "Se ha superado el limite de llamados para eventos(Event Overflow)"

  # Basic Status
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # Parameters
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # Equip Type
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # Commands
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # Currency Unit
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # Level
  def self.level_a;     basic(1);     end   # Level (short)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (short)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (short)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (short)
  def self.fight;       command(0);   end   # Fight
  def self.escape;      command(1);   end   # Escape
  def self.attack;      command(2);   end   # Attack
  def self.guard;       command(3);   end   # Guard
  def self.item;        command(4);   end   # Items
  def self.skill;       command(5);   end   # Skills
  def self.equip;       command(6);   end   # Equip
  def self.status;      command(7);   end   # Status
  def self.formation;   command(8);   end   # Change Formation
  def self.save;        command(9);   end   # Save
  def self.game_end;    command(10);  end   # Exit Game
  def self.weapon;      command(12);  end   # Weapons
  def self.armor;       command(13);  end   # Armor
  def self.key_item;    command(14);  end   # Key Items
  def self.equip2;      command(15);  end   # Change Equipment
  def self.optimize;    command(16);  end   # Ultimate Equipment
  def self.clear;       command(17);  end   # Remove All
  def self.new_game;    command(18);  end   # New Game
  def self.continue;    command(19);  end   # Continue
  def self.shutdown;    command(20);  end   # Shut Down
  def self.to_title;    command(21);  end   # Go to Title
  def self.cancel;      command(22);  end   # Cancel
  #--------------------------------------------------------------------------
end
