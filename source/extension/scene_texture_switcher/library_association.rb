# frozen_string_literal: true

require File.join(__dir__, 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  module LibraryAssociation
    extend self

    ATTRIBUTE_DICTIONARY = 'SceneTextureSwitcher'
    LIBRARY_KEY = 'texture_library_folder'

    def folder_name(model)
      value = model.get_attribute(ATTRIBUTE_DICTIONARY, LIBRARY_KEY, nil).to_s
      value.empty? ? nil : value
    end

    def set(model, folder_name)
      safe_name = File.basename(folder_name.to_s)
      raise ArgumentError, 'Texture library must be beside the SketchUp model.' unless safe_name == folder_name.to_s

      model.set_attribute(ATTRIBUTE_DICTIONARY, LIBRARY_KEY, safe_name)
      safe_name
    end

    def clear(model)
      model.delete_attribute(ATTRIBUTE_DICTIONARY, LIBRARY_KEY)
    end
  end
end
