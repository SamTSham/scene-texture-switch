# frozen_string_literal: true

require 'minitest/autorun'

class UnifiedReleaseWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_primary_loader_registers_unified_extension
    source = File.read(File.join(ROOT, 'source', 'extension', 'SceneTextureSwitcher.rb'))

    assert_includes source, "SketchupExtension.new('Scene Textures', 'scene_texture_overview_preview/core')"
    assert_includes source, "PLUGIN.version     = '1.2.0-rc.1'"
  end

  def test_former_companion_loader_is_a_retirement_shim
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'SceneTextureOverviewPreview.rb'))

    refute_includes source, 'Sketchup.register_extension'
    refute_includes source, 'SketchupExtension.new'
  end

  def test_one_extensions_submenu_contains_all_entry_points
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_equal 1, source.scan("UI.menu('Extensions')").length
    assert_includes source, "add_submenu('Scene Textures')"
    assert_includes source, "add_item('Open Scene Textures')"
    assert_includes source, "add_item('Settings & Quick Guide…')"
    assert_includes source, 'OverviewPreview.start_scene_polling'
  end

  def test_release_package_includes_settings_guide_and_retirement_shim
    source = File.read(File.join(ROOT, 'tools', 'build_unified_release.rb'))

    assert_includes source, 'SceneTextureSwitcher.rb'
    assert_includes source, 'SceneTextureOverviewPreview.rb'
    assert_includes source, 'settings.html'
    assert_includes source, 'surface_labels.rb'
    assert_includes source, 'USER_GUIDE.md'
  end
end
