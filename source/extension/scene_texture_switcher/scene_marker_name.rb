# frozen_string_literal: true

Sketchup.require File.join(__dir__.dup.force_encoding(Encoding::UTF_8), 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  # Pure folder-name rules. This module does not touch SketchUp or the filesystem,
  # so it can be tested without loading the plugin.
  module SceneMarkerName
    extend self

    FALLBACK_NAME = 'Untitled Scene'
    MAX_LENGTH = 120

    WINDOWS_RESERVED_NAMES = begin
      names = %w[CON PRN AUX NUL]
      names.concat((1..9).map { |number| "COM#{number}" })
      names.concat((1..9).map { |number| "LPT#{number}" })
      names.freeze
    end

    def sanitize(scene_name, max_length = MAX_LENGTH)
      name = scene_name.to_s
      name = normalize_unicode(name)
      name = name.gsub(/[\\\/]+/, ' - ')
      name = name.gsub(/[\u0000-\u001f\u007f:*?"<>|]/, ' ')
      name = name.gsub(/\s+/, ' ').strip
      name = name.gsub(/\A[. ]+|[. ]+\z/, '')
      name = FALLBACK_NAME if name.empty?
      name = "_#{name}" if windows_reserved?(name)
      name = truncate(name, max_length)
      name.empty? ? FALLBACK_NAME : name
    end

    def allocate(scene_names)
      counts = Hash.new(0)

      scene_names.map do |scene_name|
        base = sanitize(scene_name)
        key = comparison_key(base)
        counts[key] += 1
        counts[key] == 1 ? base : suffixed(base, counts[key])
      end
    end

    def next_available(scene_name, occupied_names)
      base = sanitize(scene_name)
      occupied = occupied_names.each_with_object({}) do |name, result|
        result[comparison_key(name)] = true
      end

      return base unless occupied[comparison_key(base)]

      suffix = 2
      loop do
        candidate = suffixed(base, suffix)
        return candidate unless occupied[comparison_key(candidate)]

        suffix += 1
      end
    end

    private

    def normalize_unicode(name)
      return name.unicode_normalize(:nfc) if name.respond_to?(:unicode_normalize)

      name
    rescue Encoding::CompatibilityError
      name
    end

    def windows_reserved?(name)
      stem = name.split('.').first.to_s.upcase
      WINDOWS_RESERVED_NAMES.include?(stem)
    end

    def comparison_key(name)
      normalize_unicode(name.to_s).downcase
    end

    def truncate(name, max_length)
      limit = [max_length.to_i, 1].max
      return name if name.length <= limit

      name[0, limit].to_s.gsub(/[. ]+\z/, '')
    end

    def suffixed(base, number)
      suffix = ".#{number}"
      visible_limit = [MAX_LENGTH - suffix.length, 1].max
      "#{truncate(base, visible_limit)}#{suffix}"
    end
  end
end
