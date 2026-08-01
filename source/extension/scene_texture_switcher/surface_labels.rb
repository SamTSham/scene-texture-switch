# frozen_string_literal: true

require 'json'

module SceneTextureSwitcher
  # Optional human descriptions for strict Surface## identifiers. The readable
  # project file travels with the texture library and never affects matching.
  module SurfaceLabels
    extend self

    FILE_NAME = '_Scene Texture Settings.json'

    def load(root)
      return {} unless root

      path = File.join(root, FILE_NAME)
      return {} unless File.file?(path)

      data = JSON.parse(File.read(path))
      sanitize(data['surface_labels'] || {})
    rescue JSON::ParserError, SystemCallError
      {}
    end

    def save(root, labels)
      raise ArgumentError, 'A texture library is required.' unless root && Dir.exist?(root)

      clean = sanitize(labels)
      path = File.join(root, FILE_NAME)
      temporary = "#{path}.tmp"
      File.write(temporary, JSON.pretty_generate({ 'surface_labels' => clean }) + "\n")
      File.rename(temporary, path)
      clean
    ensure
      File.delete(temporary) if defined?(temporary) && File.file?(temporary)
    end

    def display(surface, labels)
      description = labels[surface.to_s]
      description && !description.empty? ? "#{surface} — #{description}" : surface.to_s
    end

    private

    def sanitize(labels)
      labels.each_with_object({}) do |(surface, description), result|
        name = surface.to_s
        next unless name.match?(TextureLibraryStatus::SURFACE_NAME)

        value = description.to_s.strip.gsub(/[\r\n\t]+/, ' ')[0, 120]
        result[name] = value unless value.empty?
      end.sort.to_h
    end
  end
end
