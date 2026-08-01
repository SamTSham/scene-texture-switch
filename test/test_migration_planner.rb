# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/scene_texture_switcher/legacy_library_scanner'
require_relative '../lib/scene_texture_switcher/migration_planner'

class MigrationPlannerTest < Minitest::Test
  DEMO_ROOT = File.expand_path('fixtures/demo_project/textures', __dir__)

  def test_demo_mapping_is_scene_first
    scan = SceneTextureSwitcher::LegacyLibraryScanner.new(DEMO_ROOT).scan
    plan = SceneTextureSwitcher::MigrationPlanner.new(scan).plan(
      '01' => ['Opening'],
      '02' => ['Hotel Room'],
      '03' => ['Finale']
    )

    destinations = plan[:mappings].map { |mapping| mapping[:destination_relative] }
    assert_includes destinations, File.join('01', 'Surface01.png')
    assert_includes destinations, File.join('01', 'Surface02.png')
    assert_equal ['Hotel Room'], plan[:cue_plans]['02'][:labels]
    assert_equal false, plan[:writable]
    assert_empty plan[:conflicts]
  end

  def test_numeric_working_files_are_preserved_without_becoming_textures
    Dir.mktmpdir do |root|
      folder = File.join(root, 'Surface01')
      FileUtils.mkdir_p(folder)
      File.write(File.join(folder, '01.png'), 'texture')
      File.write(File.join(folder, '01.psd'), 'working file')
      scan = SceneTextureSwitcher::LegacyLibraryScanner.new(root).scan

      plan = SceneTextureSwitcher::MigrationPlanner.new(scan).plan

      assert_includes plan[:mappings].map { |mapping| mapping[:destination_relative] }, File.join('01', 'Surface01.psd')
      assert_equal 1, plan[:supporting_file_count]
      assert_empty plan[:conflicts]
    end
  end
end
