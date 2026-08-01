# frozen_string_literal: true

module SceneTextureSwitcher
  # Converts a scanner result into a proposed NN/Surface##.ext mapping.
  # It only returns data and never writes to the filesystem.
  class MigrationPlanner
    EXTENSION_PRIORITY = { '.png' => 0, '.jpg' => 1, '.jpeg' => 2 }.freeze

    def initialize(scan_result)
      @scan_result = scan_result
    end

    def plan(scene_labels = {})
      mappings = @scan_result[:files].map do |record|
        {
          source: record[:source],
          source_relative: record[:source_relative],
          destination_relative: File.join(record[:cue], "#{record[:surface]}#{record[:extension]}"),
          cue: record[:cue],
          surface: record[:surface],
          extension: record[:extension],
          size: record[:size]
        }
      end

      supporting_mappings = Array(@scan_result[:supporting_files]).map do |record|
        {
          source: record[:source],
          source_relative: record[:source_relative],
          destination_relative: File.join(record[:cue], "#{record[:surface]}#{record[:extension]}"),
          cue: record[:cue],
          surface: record[:surface],
          extension: record[:extension],
          size: record[:size],
          supporting: true
        }
      end
      mappings.concat(supporting_mappings)

      destination_groups = mappings.group_by { |mapping| mapping[:destination_relative].downcase }
      destination_conflicts = destination_groups.values.select { |group| group.length > 1 }.map do |group|
        {
          type: :duplicate_destination,
          destination: group.first[:destination_relative],
          sources: group.map { |mapping| mapping[:source_relative] }
        }
      end

      {
        source_root: @scan_result[:root],
        surfaces: @scan_result[:surfaces],
        cue_plans: cue_plans(scene_labels),
        mappings: mappings.sort_by { |mapping| mapping[:destination_relative] },
        supporting_file_count: supporting_mappings.length,
        conflicts: @scan_result[:conflicts] + destination_conflicts,
        ignored: @scan_result[:ignored],
        warnings: @scan_result[:warnings],
        errors: @scan_result[:errors],
        writable: false
      }
    end

    private

    def cue_plans(scene_labels)
      @scan_result[:cues].each_with_object({}) do |(cue, records), result|
        summary = records[:summary]
        result[cue] = {
          status: summary[:status],
          present: summary[:present],
          missing: summary[:missing],
          labels: Array(scene_labels[cue]).map(&:to_s)
        }
      end
    end
  end
end
