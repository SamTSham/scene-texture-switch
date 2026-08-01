# frozen_string_literal: true

require 'minitest/autorun'

class MigrationCommandWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_command_requires_two_separate_confirmations
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, 'Create a verified scene-first copy?'
    assert_includes source, 'Use this scene-first copy for the current model?'
    assert_operator source.scan('MB_YESNO').length, :>=, 2
  end

  def test_adoption_occurs_only_after_verified_execution
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    execute_position = source.index('VerifiedSceneFirstMigration.new(plan, SceneMarkerName).execute')
    adopt_position = source.index('adopt_library(model, destination_name)')
    refute_nil execute_position
    refute_nil adopt_position
    assert_operator execute_position, :<, adopt_position
  end

  def test_build_includes_migration_and_marker_modules
    source = File.read(File.join(ROOT, 'tools', 'build_overview_preview.rb'))

    assert_includes source, 'verified_scene_first_migration.rb'
    assert_includes source, 'scene_marker_name.rb'
    assert_includes source, 'legacy_library_scanner.rb'
  end
end
