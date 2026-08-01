# frozen_string_literal: true

require 'minitest/autorun'

class OverviewObserverWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_observer_covers_rename_add_and_remove_notifications
    source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'overview_pages_observer.rb'))

    assert_includes source, 'onContentsModified'
    assert_includes source, 'onElementAdded'
    assert_includes source, 'onElementRemoved'
    assert_equal 3, source.scan('@owner.schedule_refresh').length
  end

  def test_preview_attaches_only_while_dialog_is_open
    source = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    assert_includes source, 'attach_pages_observer'
    assert_includes source, 'detach_pages_observer'
    assert_includes source, 'UI.start_timer(0.1, false)'
  end
end
