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

        { surface: surface, path: path, url: file_url(path), filename: File.basename(path) }
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

    private

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
