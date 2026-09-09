# frozen_string_literal: true

source_dir = __dir__.dup.force_encoding(Encoding::UTF_8)
Sketchup.require File.join(source_dir, 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

Sketchup.require File.join(source_dir, 'texture_library_status') unless defined?(SamMadwar::SceneTextureSwitch::TextureLibraryStatus)
Sketchup.require File.join(source_dir, 'texture_applier') unless defined?(SamMadwar::SceneTextureSwitch::TextureApplier)
Sketchup.require File.join(source_dir, 'preview_assets') unless defined?(SamMadwar::SceneTextureSwitch::PreviewAssets)
Sketchup.require File.join(source_dir, 'surface_labels') unless defined?(SamMadwar::SceneTextureSwitch::SurfaceLabels)

module SamMadwar::SceneTextureSwitch
  # Converts SketchUp pages and texture readiness into plain serializable data
  # for the overview. It does not alter the model or filesystem.
  module SceneSnapshot
    extend self

    ATTRIBUTE_DICTIONARY = 'SceneTextureSwitcher'
    TEXTURE_INDEX_KEY = 'texture_index'

    def build(model, discovery)
      selected = model.pages.selected_page
      root = discovery[:root]
      dimensions = root ? dimension_analysis(root) : { warnings: {}, assets: {} }
      dimension_warnings = dimensions[:warnings]
      surface_labels = root ? SurfaceLabels.load(root) : {}

      rows = model.pages.each_with_index.map do |page, index|
        cue = TextureLibraryStatus.normalize_cue(
          page.get_attribute(ATTRIBUTE_DICTIONARY, TEXTURE_INDEX_KEY, '01')
        )
        readiness = root ? TextureLibraryStatus.state(root, cue) : unavailable_state(cue, discovery)
        readiness = with_dimension_warning(readiness, dimension_warnings[cue])

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
        texture_states: texture_states(root, discovery, dimension_warnings, dimensions[:assets]),
        surface_labels: surface_labels,
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

    def texture_states(root, discovery, dimension_warnings = {}, assets_by_cue = {})
      (1..99).map do |number|
        cue = format('%02d', number)
        readiness = root ? TextureLibraryStatus.state(root, cue) : unavailable_state(cue, discovery)
        warning = dimension_warnings[cue]
        readiness = with_dimension_warning(readiness, warning)
        {
          texture_index: cue,
          status: readiness[:status].to_s,
          present_count: readiness[:present_count],
          required_count: readiness[:required_count],
          conflicts: readiness[:conflicts],
          preview_files: root ? assets_by_cue.fetch(cue) { PreviewAssets.for_state(root, cue) } : []
        }
      end
    end

    def dimension_warnings(root)
      dimension_analysis(root)[:warnings]
    end

    def dimension_analysis(root)
      assets_by_cue = (1..99).each_with_object({}) do |number, result|
        cue = format('%02d', number)
        result[cue] = PreviewAssets.for_state(root, cue)
      end
      by_surface = Hash.new { |hash, key| hash[key] = [] }
      assets_by_cue.each do |cue, assets|
        assets.each do |asset|
          next unless asset[:width] && asset[:height]

          by_surface[asset[:surface]] << [cue, asset[:width], asset[:height]]
        end
      end

      warnings = Hash.new { |hash, key| hash[key] = [] }
      by_surface.each do |surface, records|
        expected = records.group_by { |_cue, width, height| [width, height] }
                          .max_by { |_dimensions, matching| matching.length }&.first
        next unless expected

        records.each do |cue, width, height|
          next if [width, height] == expected

          warnings[cue] << {
            type: :dimension_mismatch,
            surface: surface,
            message: "#{surface} is #{width} × #{height} px; other states use #{expected[0]} × #{expected[1]} px."
          }
        end
      end
      { warnings: warnings, assets: assets_by_cue }
    end

    def with_dimension_warning(readiness, warnings)
      return readiness unless warnings && !warnings.empty?

      readiness.merge(status: :conflict, conflicts: Array(readiness[:conflicts]) + warnings)
    end
  end
end
