# frozen_string_literal: true

module SceneTextureSwitcher
  # Reads the original Surface##/NN.ext texture arrangement without changing it.
  class LegacyLibraryScanner
    SUPPORTED_EXTENSIONS = %w[.png .jpg .jpeg].freeze
    SURFACE_PATTERN = /\ASurface\d+\z/i
    TEXTURE_PATTERN = /\A(\d{1,2})(\.(?:png|jpg|jpeg))\z/i

    def initialize(texture_root)
      @texture_root = File.expand_path(texture_root.to_s)
    end

    def scan
      result = empty_result
      return result_with_error(result, 'Texture library does not exist.') unless Dir.exist?(@texture_root)

      surface_paths = Dir.children(@texture_root).sort.map do |entry|
        File.join(@texture_root, entry)
      end.select do |path|
        File.directory?(path) && File.basename(path).match?(SURFACE_PATTERN)
      end

      result[:surfaces] = surface_paths.map { |path| File.basename(path) }
      result[:warnings] << 'No Surface## folders were found.' if surface_paths.empty?

      surface_paths.each { |path| scan_surface(path, result) }
      finalize(result)
    end

    private

    def empty_result
      {
        root: @texture_root,
        surfaces: [],
        cues: {},
        files: [],
        conflicts: [],
        ignored: [],
        warnings: [],
        errors: []
      }
    end

    def result_with_error(result, message)
      result[:errors] << message
      result
    end

    def scan_surface(surface_path, result)
      surface = File.basename(surface_path)

      Dir.children(surface_path).sort.each do |filename|
        path = File.join(surface_path, filename)
        next if File.directory?(path)

        match = filename.match(TEXTURE_PATTERN)
        unless match
          result[:ignored] << relative(path)
          next
        end

        cue = format('%02d', match[1].to_i)
        extension = match[2].downcase
        record = {
          cue: cue,
          surface: surface,
          extension: extension,
          source: path,
          source_relative: relative(path),
          size: File.size(path)
        }

        result[:files] << record
        result[:cues][cue] ||= {}
        result[:cues][cue][surface] ||= []
        result[:cues][cue][surface] << record
      end
    end

    def finalize(result)
      result[:cues].each do |cue, surface_records|
        surface_records.each do |surface, records|
          next unless records.length > 1

          result[:conflicts] << {
            type: :multiple_extensions,
            cue: cue,
            surface: surface,
            files: records.map { |record| record[:source_relative] }
          }
        end

        present = surface_records.keys & result[:surfaces]
        missing = result[:surfaces] - present
        status = if present.empty?
                   :missing
                 elsif missing.empty? && !surface_records.values.any? { |records| records.length > 1 }
                   :ready
                 else
                   :incomplete
                 end

        surface_records[:summary] = {
          status: status,
          present: present.sort,
          missing: missing.sort
        }
      end

      result[:files].sort_by! { |record| [record[:cue], record[:surface], record[:extension]] }
      result[:cues] = result[:cues].sort.to_h
      result
    end

    def relative(path)
      path.sub(/\A#{Regexp.escape(@texture_root)}\/?/, '')
    end
  end
end

