require 'sketchup.rb'
require 'extensions.rb'

module SceneTextureSwitcher
  PLUGIN = SketchupExtension.new('Scene TextureSwitch', 'scene_texture_overview_preview/core')
  PLUGIN.description = 'Makes named SketchUp materials show different image files in different scenes.'
  PLUGIN.version     = '1.2.0-rc.11'
  PLUGIN.creator     = 'Sam Madwar'
  Sketchup.register_extension(PLUGIN, true)
end
