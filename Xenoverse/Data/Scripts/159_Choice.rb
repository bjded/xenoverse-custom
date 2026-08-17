module Choices
  
  Variable_ID = 15
  # ID of variable you would like to use for choices.
  Window_Opacity = 160
  
  def self.setup(width, choices, cancel = true, x = nil, y = nil)
    return unless $scene.is_a?(Scene_Map)
    $game_system.map_interpreter.message_waiting = true
    $game_temp.choice_cancel_type = cancel
    $scene.choice_window = Window_Command.new(width, choices)
    $scene.choice_window.x = x == nil ? (640 - $scene.choice_window.width)/2 : x
    $scene.choice_window.y = y == nil ? (480 - $scene.choice_window.height)/2 : y
    $scene.choice_window.back_opacity = Window_Opacity
  end
end


class Scene_Map
  
  attr_accessor :choice_window
  
  alias zer0_choice_window_main main
  def main
    zer0_choice_window_main
    @choice_window.dispose if @choice_window != nil
  end
  
  alias zer0_choice_window_upd update
  def update
    if @choice_window != nil && @choice_window.active
      @choice_window.update
      update_choice_window
    end
    zer0_choice_window_upd
  end
  
  def update_choice_window
    if Input.trigger?(Input::B)
      unless $game_temp.choice_cancel_type
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.cancel_se)
      $game_variables[Choices::Variable_ID] = 0
      terminate_choice_window
    elsif Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_variables[Choices::Variable_ID] = @choice_window.index + 1
      terminate_choice_window
    end
  end
  
  def terminate_choice_window
    $game_system.map_interpreter.message_waiting = false
    @choice_window.dispose
    @choice_window = nil
  end
end


class Interpreter
  attr_accessor :message_waiting
end