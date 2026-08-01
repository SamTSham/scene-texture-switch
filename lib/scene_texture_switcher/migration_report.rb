# frozen_string_literal: true

module SceneTextureSwitcher
  class MigrationReport
    def initialize(plan)
      @plan = plan
    end

    def render
      lines = []
      lines << 'Scene Texture Switcher — Read-Only Migration Preview'
      lines << '=' * 56
      lines << "Source: #{@plan[:source_root]}"
      lines << 'Mode: READ ONLY — no files were copied, moved, renamed, or deleted.'
      lines << ''
      lines << "Controlled surfaces (#{@plan[:surfaces].length}): #{@plan[:surfaces].join(', ')}"
      lines << ''
      lines << 'Texture states'
      lines << '--------------'

      @plan[:cue_plans].each do |cue, cue_plan|
        label = cue_plan[:labels].empty? ? '(scene label unavailable outside SketchUp)' : cue_plan[:labels].join(' / ')
        lines << format('%s  %-10s  %s', cue, cue_plan[:status].to_s.upcase, label)
        lines << "    Present: #{display_list(cue_plan[:present])}"
        lines << "    Missing: #{display_list(cue_plan[:missing])}"
      end

      lines << ''
      lines << 'Proposed file mapping'
      lines << '---------------------'
      @plan[:mappings].each do |mapping|
        lines << "#{mapping[:source_relative]}  ->  #{mapping[:destination_relative]}"
      end

      append_issues(lines, 'Conflicts', @plan[:conflicts])
      append_issues(lines, 'Warnings', @plan[:warnings])
      append_issues(lines, 'Errors', @plan[:errors])
      append_issues(lines, 'Ignored files', @plan[:ignored])

      lines << ''
      lines << 'No changes were made.'
      lines.join("\n") + "\n"
    end

    private

    def display_list(items)
      items.empty? ? 'none' : items.join(', ')
    end

    def append_issues(lines, title, issues)
      return if issues.empty?

      lines << ''
      lines << title
      lines << ('-' * title.length)
      issues.each { |issue| lines << format_issue(issue) }
    end

    def format_issue(issue)
      return issue unless issue.is_a?(Hash)

      issue.map { |key, value| "#{key}=#{Array(value).join(', ')}" }.join('; ')
    end
  end
end

