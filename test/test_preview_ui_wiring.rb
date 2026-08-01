# frozen_string_literal: true

require 'minitest/autorun'

class PreviewUiWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_hover_preview_is_delayed_literal_and_has_click_and_z_paths
    source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'html', 'overview.html'))

    assert_includes source, 'setTimeout(() => showPreview(anchor, scene), 350)'
    assert_includes source, 'asset.surface'
    assert_includes source, "tile.addEventListener('click', () => zoomPreview(asset))"
    assert_includes source, "event.key.toLowerCase() === 'z'"
    assert_includes source, 'z to zoom preview (or click)'
    assert_includes source, 'window.sketchup.previewShortcut'
    refute_includes source, 'deduplicate'
  end

  def test_large_preview_rejects_paths_outside_associated_library
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, 'PreviewAssets.allowed_path?(root, path)'
    assert_includes source, "add_action_callback('zoomPreview')"
    assert_includes source, "add_action_callback('previewShortcut')"
    assert_includes source, 'z or Escape — close'
    assert_includes source, 'PreviewAssets.metadata(current_library_root, path)'
  end

  def test_package_includes_preview_asset_service
    source = File.read(File.join(ROOT, 'tools', 'build_overview_preview.rb'))

    assert_includes source, 'preview_assets.rb'
  end
end
