# frozen_string_literal: true

require File.join(__dir__, 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

require 'json'

module SamMadwar::SceneTextureSwitch
  # Optional human descriptions for strict Surface## identifiers. The readable
  # project file travels with the texture library and never affects matching.
  module SurfaceLabels
    extend self

    FILE_NAME = '_Scene TextureSwitch Settings.json'
    EARLIER_FILE_NAME = '_Scene Texture Settings.json'
    MARKER_HEADER = 'Scene TextureSwitch surface label'

    def load(root)
      return {} unless root

      path = [FILE_NAME, EARLIER_FILE_NAME].map { |name| File.join(root, name) }
                                               .find { |candidate| File.file?(candidate) }
      return {} unless path

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
      sync_markers(root, clean)
      clean
    ensure
      File.delete(temporary) if defined?(temporary) && File.file?(temporary)
    end

    def display(surface, labels)
      description = labels[surface.to_s]
      description && !description.empty? ? "#{surface} — #{description}" : surface.to_s
    end

    private

    def sync_markers(root, labels)
      desired = labels.each_with_object({}) do |(surface, description), result|
        filename = safe_marker_name("#{surface} — #{description}.txt")
        result[filename] = "#{MARKER_HEADER}\nSurface: #{surface}\nDescription: #{description}\n"
      end

      # Create or update the desired labels before removing obsolete ones.
      desired.each do |filename, content|
        path = File.join(root, filename)
        next if File.file?(path) && !managed_marker?(path)

        File.write(path, content)
      end
      managed_markers(root).each do |path|
        File.delete(path) unless desired.key?(File.basename(path))
      end
    end

    def managed_markers(root)
      Dir.children(root).map do |filename|
        path = File.join(root, filename)
        path if File.file?(path) && File.extname(filename).casecmp('.txt').zero? && managed_marker?(path)
      end.compact
    end

    def managed_marker?(path)
      File.open(path, &:readline).strip == MARKER_HEADER
    rescue EOFError, SystemCallError
      false
    end

    def safe_marker_name(filename)
      cleaned = filename.gsub(/[\\\/:*?"<>|\u0000-\u001F]/, ' ')
                        .gsub(/\s+/, ' ').strip
      cleaned = cleaned[0, 180].rstrip
      cleaned.end_with?('.txt') ? cleaned : "#{cleaned}.txt"
    end

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
