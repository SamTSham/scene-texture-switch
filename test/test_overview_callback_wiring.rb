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
end
