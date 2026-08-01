require 'sketchup.rb'
require 'extensions.rb'

module SceneTextureSwitcher
  PLUGIN = SketchupExtension.new('Scene Texture Switcher', 'scene_texture_switcher/core')
  PLUGIN.description = 'Switches multiple textures per scene from local project folder.'
  PLUGIN.version     = '1.0.0'
  PLUGIN.creator     = 'ChatGPT + [Your Name]'
  Sketchup.register_extension(PLUGIN, true)
end
