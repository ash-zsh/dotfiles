local wezterm = require 'wezterm'

return {
  color_scheme = 'Shapeshifter (light) (terminal.sexy)',
  colors = {
    visual_bell = '#ffb0b0'
  },

  font = wezterm.font 'FiraCode Nerd Font',
  font_size = 16,

  visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 100,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 100,    
  },

  window_decorations = 'NONE',
  enable_tab_bar = false,

  enable_wayland = true
}
