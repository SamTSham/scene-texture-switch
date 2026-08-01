# frozen_string_literal: true

module SceneTextureSwitcher
  # Writes only the established per-page texture_index attribute. Texture files
  # and scene activation are outside this module.
  module SceneAssignment
    extend self

    ATTRIBUTE_DICTIONARY = 'SceneTextureSwitcher'
    TEXTURE_INDEX_KEY = 'texture_index'

    def assign(model, scene_key, cue)
      page = find_page(model.pages, scene_key)
      return { success: false, error: 'Scene no longer exists.' } unless page

      normalized_cue = TextureLibraryStatus.normalize_cue(cue)
      operation_started = false
      model.start_operation('Assign Scene Texture', true)
      operation_started = true
      page.set_attribute(ATTRIBUTE_DICTIONARY, TEXTURE_INDEX_KEY, normalized_cue)
      model.commit_operation

      {
        success: true,
        cue: normalized_cue,
        page: page,
        current: page.equal?(model.pages.selected_page)
      }
    rescue StandardError => error
      model.abort_operation if operation_started
      { success: false, error: error.message }
    end

    def find_page(pages, scene_key)
      pages.each_with_index.find do |page, index|
        key_for(page, index) == scene_key.to_s
      end&.first
    end

    def key_for(page, index)
      if page.respond_to?(:persistent_id)
        "page-#{page.persistent_id}"
      elsif page.respond_to?(:entityID)
        "entity-#{page.entityID}"
      else
        "position-#{index}"
      end
    rescue StandardError
      "position-#{index}"
    end
  end
end
