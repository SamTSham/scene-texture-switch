# frozen_string_literal: true

require 'minitest/autorun'

class MarkerSyncWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_palette_open_assignment_and_scene_events_trigger_sync
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_operator source.scan('sync_scene_markers').length, :>=, 5
    assert_includes source, 'SceneMarkerSync.sync(root, scene_records(model))'
  end

  def test_package_includes_synchronizer
    source = File.read(File.join(ROOT, 'tools', 'build_overview_preview.rb'))

    assert_includes source, 'scene_marker_sync.rb'
  end
end
