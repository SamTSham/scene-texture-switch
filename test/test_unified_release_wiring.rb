# frozen_string_literal: true

require 'minitest/autorun'

class UnifiedReleaseWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_primary_loader_registers_unified_extension
    source = File.read(File.join(ROOT, 'source', 'extension', 'SceneTextureSwitcher.rb'))

    assert_includes source, "SketchupExtension.new('Scene TextureSwitch', 'scene_texture_overview_preview/core')"
    assert_includes source, "PLUGIN.version     = '1.2.0-rc.5'"
  end

  def test_former_companion_loader_is_a_retirement_shim
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'SceneTextureOverviewPreview.rb'))

    refute_includes source, 'Sketchup.register_extension'
    refute_includes source, 'SketchupExtension.new'
  end

  def test_one_extensions_submenu_contains_all_entry_points
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_equal 1, source.scan("UI.menu('Extensions')").length
    assert_includes source, "add_submenu('Scene TextureSwitch')"
    assert_includes source, "add_item('Open Scene TextureSwitch')"
    assert_includes source, "add_item('Settings + Quick Guide…')"
    assert_equal 2, source.scan('menu.add_item').length
    refute_includes source, 'migrate_scene_first_copy'
    refute_includes source, 'adopt_existing_scene_first_copy'
    assert_includes source, 'OverviewPreview.start_scene_monitoring'
    assert_includes source, 'Sketchup::Pages.add_frame_change_observer'
    assert_includes source, 'UI.start_timer(1.0, true)'
  end

  def test_release_package_includes_settings_guide_and_retirement_shim
    source = File.read(File.join(ROOT, 'tools', 'build_unified_release.rb'))

    assert_includes source, 'SceneTextureSwitcher.rb'
    assert_includes source, 'SceneTextureOverviewPreview.rb'
    assert_includes source, 'settings.html'
    assert_includes source, 'surface_labels.rb'
    assert_includes source, 'scene_transition_observer.rb'
    assert_includes source, 'USER_GUIDE.md'
    assert_includes source, 'textures - Starter'
    assert_includes source, 'Surface01'
    assert_includes source, '_PICTURE SET'
  end
end
