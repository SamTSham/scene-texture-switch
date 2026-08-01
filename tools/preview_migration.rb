# frozen_string_literal: true

require_relative '../lib/scene_texture_switcher/legacy_library_scanner'
require_relative '../lib/scene_texture_switcher/migration_planner'
require_relative '../lib/scene_texture_switcher/migration_report'

texture_root = ARGV.first
unless texture_root
  warn 'Usage: ruby tools/preview_migration.rb /path/to/textures'
  exit 2
end

scan = SceneTextureSwitcher::LegacyLibraryScanner.new(texture_root).scan
plan = SceneTextureSwitcher::MigrationPlanner.new(scan).plan
puts SceneTextureSwitcher::MigrationReport.new(plan).render
exit(plan[:errors].empty? ? 0 : 1)

