# frozen_string_literal: true

require 'minitest/autorun'
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
end

