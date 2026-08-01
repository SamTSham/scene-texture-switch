# frozen_string_literal: true

require 'digest'
require 'fileutils'

module SceneTextureSwitcher
  # Executes a previously prepared legacy migration plan into a brand-new
  # destination. The legacy source is read only. Any failed copy removes only
  # the newly created destination.
  class VerifiedSceneFirstMigration
    REPORT_NAME = '_Scene Texture Migration Report.txt'

    def initialize(plan, marker_namer)
      @plan = plan
      @marker_namer = marker_namer
    end

    def execute(destination_root, scenes)
      destination = File.expand_path(destination_root.to_s)
      preflight!(destination)
      copied = []
      markers = []

      begin
        FileUtils.mkdir_p(destination)
        @plan[:mappings].each do |mapping|
          copied << copy_and_verify(mapping, destination)
        end
        markers = write_markers(destination, scenes)
        report_path = write_report(destination, copied, markers)

        {
          success: true,
          source_root: @plan[:source_root],
          destination_root: destination,
          copied: copied,
          markers: markers,
          report_path: report_path,
          warnings: @plan[:conflicts]
        }
      rescue StandardError
        FileUtils.rm_rf(destination) if Dir.exist?(destination)
        raise
      end
    end

    private

    def preflight!(destination)
      raise ArgumentError, 'Migration plan contains errors.' unless Array(@plan[:errors]).empty?
      raise ArgumentError, 'Migration destination already exists.' if File.exist?(destination)
      raise ArgumentError, 'Migration plan contains no texture files.' if Array(@plan[:mappings]).empty?

      duplicate_destinations = @plan[:mappings].group_by do |mapping|
        mapping[:destination_relative].downcase
      end.values.select { |group| group.length > 1 }
      raise ArgumentError, 'Two source files map to the same destination.' if duplicate_destinations.any?
    end

    def copy_and_verify(mapping, destination)
      target = File.join(destination, mapping[:destination_relative])
      FileUtils.mkdir_p(File.dirname(target))
      FileUtils.cp(mapping[:source], target)

      source_size = File.size(mapping[:source])
      target_size = File.size(target)
      source_hash = Digest::SHA256.file(mapping[:source]).hexdigest
      target_hash = Digest::SHA256.file(target).hexdigest
      unless source_size == target_size && source_hash == target_hash
        raise IOError, "Verification failed for #{mapping[:destination_relative]}"
      end

      {
        source: mapping[:source],
        destination: target,
        destination_relative: mapping[:destination_relative],
        size: target_size,
        sha256: target_hash
      }
    end

    def write_markers(destination, scenes)
      Array(scenes).group_by { |scene| normalize_cue(scene[:cue]) }.flat_map do |cue, cue_scenes|
        names = @marker_namer.allocate(cue_scenes.map { |scene| scene[:name] })
        cue_scenes.zip(names).map do |scene, safe_name|
          folder = File.join(destination, cue)
          FileUtils.mkdir_p(folder)
          path = File.join(folder, "#{cue}_#{safe_name}.txt")
          File.open(path, 'wb') do |file|
            file.write("Scene Texture Switcher label\n")
            file.write("Scene: #{scene[:name]}\n")
            file.write("Texture state: #{cue}\n")
            file.write("Scene identity: #{scene[:scene_key]}\n")
          end
          { cue: cue, scene_key: scene[:scene_key], scene_name: scene[:name], path: path }
        end
      end
    end

    def write_report(destination, copied, markers)
      path = File.join(destination, REPORT_NAME)
      File.open(path, 'wb') do |file|
        file.puts 'Scene Texture Switcher — Verified Scene-First Copy'
        file.puts "Source: #{@plan[:source_root]}"
        file.puts "Destination: #{destination}"
        file.puts 'Original files changed: none'
        file.puts
        file.puts "Verified texture copies: #{copied.length}"
        copied.each do |record|
          file.puts "#{record[:destination_relative]} | #{record[:size]} bytes | SHA-256 #{record[:sha256]}"
        end
        file.puts
        file.puts "Scene markers: #{markers.length}"
        markers.each do |marker|
          file.puts "#{marker[:cue]}/#{File.basename(marker[:path])} | #{marker[:scene_key]}"
        end
        unless Array(@plan[:conflicts]).empty?
          file.puts
          file.puts 'Non-blocking housekeeping warnings:'
          @plan[:conflicts].each { |warning| file.puts warning.inspect }
        end
      end
      path
    end

    def normalize_cue(cue)
      number = cue.to_s[/\d+/].to_i
      number = 1 unless number.between?(1, 99)
      format('%02d', number)
    end
  end
end
