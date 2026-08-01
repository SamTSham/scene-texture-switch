# frozen_string_literal: true

module SceneTextureSwitcher
  # Converts SketchUp pages and texture readiness into plain serializable data
  # for the overview. It does not alter the model or filesystem.
  module SceneSnapshot
    extend self

    ATTRIBUTE_DICTIONARY = 'SceneTextureSwitcher'
    TEXTURE_INDEX_KEY = 'texture_index'

    def build(model, discovery)
      selected = model.pages.selected_page
      root = discovery[:root]

      rows = model.pages.each_with_index.map do |page, index|
        cue = TextureLibraryStatus.normalize_cue(
          page.get_attribute(ATTRIBUTE_DICTIONARY, TEXTURE_INDEX_KEY, '01')
        )
        readiness = root ? TextureLibraryStatus.state(root, cue) : unavailable_state(cue, discovery)

        {
          scene_key: scene_key(page, index),
          scene_name: page.name.to_s,
          texture_index: cue,
          status: readiness[:status].to_s,
          present_count: readiness[:present_count],
          required_count: readiness[:required_count],
          missing_surfaces: readiness[:missing],
          conflicts: readiness[:conflicts],
          current: page.equal?(selected)
        }
      end

      {
        mode: 'editor',
        model_name: model_name(model),
        saved: saved_model?(model),
        library: serialize_discovery(discovery),
        scenes: rows,
        texture_states: texture_states(root, discovery),
        summary: summarize(rows)
      }
    end

    private

    def scene_key(page, index)
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

    def model_name(model)
      path = model.path.to_s
      return 'Unsaved SketchUp model' if path.empty?

      File.basename(path, File.extname(path))
    end

    def saved_model?(model)
      !model.path.to_s.empty?
    end

    def serialize_discovery(discovery)
      {
        status: discovery[:status].to_s,
        name: discovery[:root] ? File.basename(discovery[:root]) : nil,
        path: discovery[:root],
        candidates: Array(discovery[:candidates]).map { |path| File.basename(path) },
        message: discovery[:message]
      }
    end

    def unavailable_state(cue, discovery)
      {
        cue: cue,
        status: discovery[:status] == :ambiguous ? :conflict : :missing,
        present_count: 0,
        required_count: 0,
        missing: [],
        conflicts: []
      }
    end

    def summarize(rows)
      counts = Hash.new(0)
      rows.each { |row| counts[row[:status].to_sym] += 1 }
      {
        scene_count: rows.length,
        ready: counts[:ready],
        incomplete: counts[:incomplete],
        missing: counts[:missing],
        conflict: counts[:conflict],
        attention: counts[:incomplete] + counts[:missing] + counts[:conflict]
      }
    end

    def texture_states(root, discovery)
      (1..99).map do |number|
        cue = format('%02d', number)
        readiness = root ? TextureLibraryStatus.state(root, cue) : unavailable_state(cue, discovery)
        {
          texture_index: cue,
          status: readiness[:status].to_s,
          present_count: readiness[:present_count],
          required_count: readiness[:required_count]
        }
      end
    end
  end
end
