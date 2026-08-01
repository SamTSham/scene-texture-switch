# frozen_string_literal: true

require 'fileutils'

module SceneTextureSwitcher
  module SceneMarkerSync
    extend self

    HEADER = 'Scene Texture Switcher label'
    IDENTITY_PREFIX = 'Scene identity: '

    def sync(root, scenes)
      existing = managed_markers(root)
      desired = desired_markers(root, scenes)
      created = []
      removed = []

      desired.each do |scene_key, marker|
        old_paths = Array(existing[scene_key])
        unless old_paths.include?(marker[:path]) && File.file?(marker[:path])
          write_marker(marker)
          created << marker[:path]
        end
        old_paths.each do |old_path|
          next if old_path == marker[:path]

          File.delete(old_path) if managed_marker?(old_path, scene_key)
          removed << old_path unless File.exist?(old_path)
          remove_empty_state_folder(File.dirname(old_path))
        end
      end

      (existing.keys - desired.keys).each do |scene_key|
        existing[scene_key].each do |path|
          File.delete(path) if managed_marker?(path, scene_key)
          removed << path unless File.exist?(path)
          remove_empty_state_folder(File.dirname(path))
        end
      end

      { created: created, removed: removed, desired: desired.values.map { |marker| marker[:path] } }
    end

    def managed_markers(root)
      result = Hash.new { |hash, key| hash[key] = [] }
      return result unless root && Dir.exist?(root)

      Dir.children(root).sort.each do |entry|
        folder = File.join(root, entry)
        next unless File.directory?(folder) && entry.match?(/\A\d{2}\z/)

        Dir.children(folder).sort.each do |filename|
          path = File.join(folder, filename)
          next unless File.file?(path) && File.extname(filename).downcase == '.txt'

          scene_key = marker_identity(path)
          result[scene_key] << path if scene_key
        end
      end
      result
    end

    private

    def desired_markers(root, scenes)
      Array(scenes).group_by { |scene| TextureLibraryStatus.normalize_cue(scene[:cue]) }.each_with_object({}) do |(cue, cue_scenes), result|
        safe_names = SceneMarkerName.allocate(cue_scenes.map { |scene| scene[:name] })
        cue_scenes.zip(safe_names).each do |scene, safe_name|
          scene_key = scene[:scene_key].to_s
          folder = File.join(root, cue)
          result[scene_key] = {
            cue: cue, scene_key: scene_key, scene_name: scene[:name].to_s,
            path: available_marker_path(folder, cue, safe_name, scene_key)
          }
        end
      end
    end

    def available_marker_path(folder, cue, safe_name, scene_key)
      stem = "#{cue}_#{safe_name}"
      candidate = File.join(folder, "#{stem}.txt")
      return candidate unless File.exist?(candidate)
      return candidate if marker_identity(candidate) == scene_key

      suffix = 2
      loop do
        candidate = File.join(folder, "#{stem}.#{suffix}.txt")
        return candidate unless File.exist?(candidate)
        return candidate if marker_identity(candidate) == scene_key

        suffix += 1
      end
    end

    def write_marker(marker)
      FileUtils.mkdir_p(File.dirname(marker[:path]))
      temporary = "#{marker[:path]}.new"
      File.open(temporary, 'wb') do |file|
        file.write("#{HEADER}\n")
        file.write("Scene: #{marker[:scene_name]}\n")
        file.write("Texture state: #{marker[:cue]}\n")
        file.write("#{IDENTITY_PREFIX}#{marker[:scene_key]}\n")
      end
      File.rename(temporary, marker[:path])
    ensure
      File.delete(temporary) if temporary && File.exist?(temporary)
    end

    def marker_identity(path)
      lines = File.readlines(path, chomp: true)
      return nil unless lines.first == HEADER

      identity = lines.find { |line| line.start_with?(IDENTITY_PREFIX) }
      identity&.sub(IDENTITY_PREFIX, '')
    rescue SystemCallError, ArgumentError
      nil
    end

    def managed_marker?(path, scene_key)
      marker_identity(path) == scene_key.to_s
    end

    def remove_empty_state_folder(folder)
      return unless File.basename(folder).match?(/\A\d{2}\z/)
      return unless Dir.exist?(folder) && Dir.children(folder).empty?

      Dir.rmdir(folder)
    rescue SystemCallError
      nil
    end
  end
end
