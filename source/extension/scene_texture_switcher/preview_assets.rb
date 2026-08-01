# frozen_string_literal: true

require 'uri'

module SceneTextureSwitcher
  module PreviewAssets
    extend self

    def for_state(root, cue)
      layout = TextureLibraryStatus.layout(root)
      surfaces(root, layout).map do |surface|
        path = TextureApplier.preferred_texture(root, layout, surface, TextureLibraryStatus.normalize_cue(cue))
        next unless path

        dimensions = image_dimensions(path)
        {
          surface: surface, path: path, url: file_url(path), filename: File.basename(path),
          width: dimensions && dimensions[0], height: dimensions && dimensions[1]
        }
      end.compact
    end

    def allowed_path?(root, path)
      return false unless root && path

      expanded_root = File.expand_path(root)
      expanded_path = File.expand_path(path)
      inside = expanded_path.start_with?(expanded_root + File::SEPARATOR)
      supported = TextureLibraryStatus::SUPPORTED_EXTENSIONS.include?(File.extname(expanded_path).downcase)
      inside && supported && File.file?(expanded_path)
    end

    def file_url(path)
      expanded = File.expand_path(path).tr('\\', '/')
      expanded = "/#{expanded}" if expanded.match?(/\A[A-Za-z]:\//)
      URI::DEFAULT_PARSER.escape("file://#{expanded}")
    end

    def metadata(root, path)
      relative = if root
                   path.sub(/\A#{Regexp.escape(File.expand_path(root))}#{Regexp.escape(File::SEPARATOR)}?/, '')
                 else
                   File.basename(path)
                 end
      dimensions = image_dimensions(path)
      size = human_size(File.size(path))
      summary = dimensions ? "#{dimensions[0]} × #{dimensions[1]} px · #{size}" : size
      { relative_path: relative, summary: summary }
    rescue StandardError
      { relative_path: File.basename(path.to_s), summary: 'File information unavailable' }
    end

    def image_dimensions(path)
      return nil unless defined?(Sketchup::ImageRep)

      image = Sketchup::ImageRep.new
      image.load_file(path)
      [image.width, image.height]
    rescue StandardError
      nil
    end

    private

    def human_size(bytes)
      return "#{bytes} B" if bytes < 1024
      return format('%.1f KB', bytes / 1024.0) if bytes < 1024 * 1024

      format('%.1f MB', bytes / (1024.0 * 1024.0))
    end

    def surfaces(root, layout)
      case layout
      when :scene_first
        TextureLibraryStatus.scene_first_surfaces(root)
      when :legacy
        TextureLibraryStatus.surface_folders(root).map { |path| File.basename(path) }
      else
        []
      end
    end
  end
end
