# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module SamMadwar
  module SceneTextureSwitch
    EXTENSION = SketchupExtension.new(
      'Scene TextureSwitch',
      'sam_madwar_scene_texture_switch/core'
    )
    EXTENSION.description = 'Makes named SketchUp materials show different image files in different scenes.'
    EXTENSION.version = '1.0.0'
    EXTENSION.creator = 'Sam Madwar'
    EXTENSION.copyright = 'Copyright 2026 Sam Madwar'

    Sketchup.register_extension(EXTENSION, true)
  end
end
