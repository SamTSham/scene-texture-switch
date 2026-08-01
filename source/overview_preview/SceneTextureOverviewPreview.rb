# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module SceneTextureSwitcher
  PREVIEW_EXTENSION = SketchupExtension.new(
    'Scene Texture Overview Editor',
    'scene_texture_overview_preview/core'
  )
  PREVIEW_EXTENSION.description = 'Development scene texture assignment and readiness overview.'
  PREVIEW_EXTENSION.version = '1.1.0-dev.4'
  PREVIEW_EXTENSION.creator = 'Scene Texture Switcher project'
  Sketchup.register_extension(PREVIEW_EXTENSION, true)
end
