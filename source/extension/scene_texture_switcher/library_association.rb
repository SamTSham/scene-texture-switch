# frozen_string_literal: true

Sketchup.require File.join(__dir__.dup.force_encoding(Encoding::UTF_8), 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  module LibraryAssociation
    extend self

    ATTRIBUTE_DICTIONARY = 'SceneTextureSwitcher'
    LIBRARY_KEY = 'texture_library_folder'

    def folder_name(model)
      value = model.get_attribute(ATTRIBUTE_DICTIONARY, LIBRARY_KEY, nil).to_s
      value.empty? ? nil : value
    end

  end
end
