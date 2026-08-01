# frozen_string_literal: true

require 'minitest/autorun'

class OverviewNavigationWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_html_keeps_assignment_click_separate_from_scene_double_click
    source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'html', 'overview.html'))

    assert_includes source, "row.addEventListener('dblclick'"
    assert_includes source, 'window.sketchup.activateScene(scene.scene_key)'
    assert_includes source, "row.querySelector('.cue').addEventListener('dblclick'"
  end

  def test_reload_callback_applies_current_texture_then_refreshes
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, 'reload_current_scene_textures'
    assert_includes source, "add_action_callback('reloadCurrent')"
    assert_includes source, 'apply_current_texture(TextureLibraryStatus.normalize_cue(cue))'
    assert_includes source, 'refresh(@dialog)'
  end

  def test_scene_activation_does_not_reselect_the_current_page
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, 'model.pages.selected_page = page unless page.equal?(model.pages.selected_page)'
  end
end
