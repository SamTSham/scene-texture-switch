# frozen_string_literal: true

module SceneTextureSwitcher
  # Read-only discovery and readiness checks for the established texture
  # library. This module never creates, renames, or removes files.
  module TextureLibraryStatus
    extend self

    SUPPORTED_EXTENSIONS = %w[.png .jpg .jpeg].freeze
    LIBRARY_NAME = /\Atextures(?:\s*[-\u2013\u2014].*)?\z/i
    SURFACE_NAME = /\ASurface\d+\z/i

    def discover(project_dir, preferred_name = nil)
      return missing_discovery unless project_dir && Dir.exist?(project_dir)

      if preferred_name && !preferred_name.to_s.empty?
        preferred_path = File.join(project_dir, File.basename(preferred_name.to_s))
        return {
          status: :associated_missing,
          root: nil,
          candidates: [],
          preferred_name: preferred_name.to_s
        } unless Dir.exist?(preferred_path)

        return {
          status: :found,
          root: preferred_path,
          candidates: [preferred_path],
          associated: true
        }
      end

      candidates = Dir.children(project_dir).sort.map do |entry|
        path = File.join(project_dir, entry)
        path if File.directory?(path) && entry.match?(LIBRARY_NAME)
      end.compact

      case candidates.length
      when 0
        missing_discovery
      when 1
        { status: :found, root: candidates.first, candidates: candidates }
      else
        { status: :ambiguous, root: nil, candidates: candidates }
      end
    rescue SystemCallError => error
      { status: :error, root: nil, candidates: [], message: error.message }
    end

    def state(root, cue)
      layout = layout(root)
      return scene_first_state(root, cue) if layout == :scene_first
      return mixed_state(root, cue) if layout == :mixed

      legacy_state(root, cue)
    end

    def layout(root)
      return :missing unless root && Dir.exist?(root)

      entries = Dir.children(root)
      legacy = entries.any? do |entry|
        File.directory?(File.join(root, entry)) && entry.match?(SURFACE_NAME)
      end
      scene_first = entries.any? do |entry|
        File.directory?(File.join(root, entry)) && entry.match?(/\A\d{2}\z/)
      end
      return :mixed if legacy && scene_first
      return :scene_first if scene_first
      return :legacy if legacy

      :missing
    rescue SystemCallError
      :missing
    end

    def legacy_state(root, cue)
      surfaces = surface_folders(root)
      return no_surfaces_state(cue) if surfaces.empty?

      present = []
      missing = []
      conflicts = []

      surfaces.each do |surface_path|
        surface = File.basename(surface_path)
        matches = SUPPORTED_EXTENSIONS.map do |extension|
          path = File.join(surface_path, "#{normalize_cue(cue)}#{extension}")
          path if File.file?(path)
        end.compact

        if matches.empty?
          missing << surface
        else
          present << surface
          conflicts << { surface: surface, files: matches } if matches.length > 1
        end
      end

      status = if conflicts.any?
                 :conflict
               elsif present.empty?
                 :missing
               elsif missing.empty?
                 :ready
               else
                 :incomplete
               end

      {
        cue: normalize_cue(cue),
        status: status,
        present: present,
        missing: missing,
        required_count: surfaces.length,
        present_count: present.length,
        conflicts: conflicts
      }
    end

    def scene_first_state(root, cue)
      surfaces = scene_first_surfaces(root)
      return no_surfaces_state(cue) if surfaces.empty?

      cue_folder = File.join(root, normalize_cue(cue))
      readiness_for_surface_names(cue, surfaces) do |surface, extension|
        File.join(cue_folder, "#{surface}#{extension}")
      end
    end

    def scene_first_surfaces(root)
      return [] unless root && Dir.exist?(root)

      Dir.children(root).sort.flat_map do |entry|
        folder = File.join(root, entry)
        next [] unless File.directory?(folder) && entry.match?(/\A\d{2}\z/)

        Dir.children(folder).map do |filename|
          match = filename.match(/\A(Surface\d+)(?:\.png|\.jpg|\.jpeg)\z/i)
          match && match[1]
        end.compact
      end.uniq.sort
    rescue SystemCallError
      []
    end

    def surface_folders(root)
      return [] unless root && Dir.exist?(root)

      Dir.children(root).sort.map do |entry|
        path = File.join(root, entry)
        path if File.directory?(path) && entry.match?(SURFACE_NAME)
      end.compact
    rescue SystemCallError
      []
    end

    def normalize_cue(cue)
      number = cue.to_s[/\d+/].to_i
      number = 1 unless number.between?(1, 99)
      format('%02d', number)
    end

    private

    def mixed_state(root, cue)
      legacy = legacy_state(root, cue)
      scene_first = scene_first_state(root, cue)
      scene_first.merge(
        status: :conflict,
        conflicts: Array(scene_first[:conflicts]) + Array(legacy[:conflicts]) + [
          { type: :mixed_layouts, message: 'Legacy and scene-first folders coexist in one library.' }
        ]
      )
    end

    def readiness_for_surface_names(cue, surfaces)
      present = []
      missing = []
      conflicts = []

      surfaces.each do |surface|
        matches = SUPPORTED_EXTENSIONS.map do |extension|
          path = yield(surface, extension)
          path if File.file?(path)
        end.compact

        if matches.empty?
          missing << surface
        else
          present << surface
          conflicts << { surface: surface, files: matches } if matches.length > 1
        end
      end

      status = if conflicts.any?
                 :conflict
               elsif present.empty?
                 :missing
               elsif missing.empty?
                 :ready
               else
                 :incomplete
               end

      {
        cue: normalize_cue(cue), status: status, present: present,
        missing: missing, required_count: surfaces.length,
        present_count: present.length, conflicts: conflicts
      }
    end

    def missing_discovery
      { status: :missing, root: nil, candidates: [] }
    end

    def no_surfaces_state(cue)
      {
        cue: normalize_cue(cue),
        status: :missing,
        present: [],
        missing: [],
        required_count: 0,
        present_count: 0,
        conflicts: [],
        message: 'No Surface## folders were found.'
      }
    end
  end
end
