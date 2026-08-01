# frozen_string_literal: true

module SceneTextureSwitcher
  # Read-only discovery and readiness checks for the established texture
  # library. This module never creates, renames, or removes files.
  module TextureLibraryStatus
    extend self

    SUPPORTED_EXTENSIONS = %w[.png .jpg .jpeg].freeze
    LIBRARY_NAME = /\Atextures(?:\s*[-\u2013\u2014].*)?\z/i
    SURFACE_NAME = /\ASurface\d+\z/i

    def discover(project_dir)
      return missing_discovery unless project_dir && Dir.exist?(project_dir)

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
