require 'sketchup.rb'
require 'extensions.rb'

module SceneTextureSwitcher
  PLUGIN = SketchupExtension.new('Scene Textures', 'scene_texture_overview_preview/core')
  PLUGIN.description = 'Offline scene-controlled texture states for planned Surface## materials.'
  PLUGIN.version     = '1.2.0-rc.1'
  PLUGIN.creator     = 'Sam Madwar'
  Sketchup.register_extension(PLUGIN, true)
end
