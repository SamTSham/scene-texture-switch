# frozen_string_literal: true

require 'minitest/autorun'

class OverviewCallbackWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_standalone_callback_refreshes_the_dialog_not_action_context
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, "refresh(@dialog)"
    refute_match(/do \|dialog,/, source)
  end

  def test_integrated_callback_refreshes_the_dialog_not_action_context
    source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'core.rb'))

    assert_includes source, "refresh_overview(@overview_dialog)"
    refute_match(/requestSnapshot.*do \|dialog,/m, source)
  end

  def test_reveal_control_opens_only_the_library_root
    core = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))
    html = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'html', 'overview.html'))

    assert_includes core, "add_action_callback('revealLibrary')"
    assert_includes core, 'UI.openURL(PreviewAssets.file_url(root))'
    assert_includes html, "temporaryGuide('Reveal texture library')"
    assert_includes html, 'window.sketchup.revealLibrary()'
  end

  def test_help_control_opens_settings_and_quick_guide
    core = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))
    html = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'html', 'overview.html'))

    assert_includes core, "add_action_callback('openSettings')"
    assert_includes core, 'activate_settings'
    assert_includes html, 'aria-label="Open Settings and Quick Guide"'
    assert_includes html, 'window.sketchup.openSettings()'
  end
end
