# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/surface_labels'

class SurfaceLabelsTest < Minitest::Test
  Labels = SceneTextureSwitcher::SurfaceLabels

  def test_round_trip_keeps_only_surface_descriptions
    Dir.mktmpdir do |root|
      saved = Labels.save(root, {
        'Surface01' => ' Rear LED wall ',
        'Surface02' => "Projection\ngauze",
        'NotASurface' => 'ignored',
        'Surface03' => ''
      })

      assert_equal({ 'Surface01' => 'Rear LED wall', 'Surface02' => 'Projection gauze' }, saved)
      assert_equal saved, Labels.load(root)
      assert File.file?(File.join(root, Labels::FILE_NAME))
      marker = File.join(root, 'Surface01 — Rear LED wall.txt')
      assert File.file?(marker)
      assert_includes File.read(marker), Labels::MARKER_HEADER
    end
  end

  def test_display_never_changes_the_identifier
    labels = { 'Surface01' => 'Rear LED wall' }
    assert_equal 'Surface01 — Rear LED wall', Labels.display('Surface01', labels)
    assert_equal 'Surface02', Labels.display('Surface02', labels)
  end

  def test_updating_labels_removes_only_managed_markers
    Dir.mktmpdir do |root|
      unrelated = File.join(root, 'My notes.txt')
      File.write(unrelated, 'keep me')
      Labels.save(root, { 'Surface01' => 'Rear wall' })
      Labels.save(root, { 'Surface02' => 'Floor' })

      refute File.exist?(File.join(root, 'Surface01 — Rear wall.txt'))
      assert File.exist?(File.join(root, 'Surface02 — Floor.txt'))
      assert_equal 'keep me', File.read(unrelated)
    end
  end
end
