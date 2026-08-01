# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/scene_marker_name'
require_relative '../source/extension/scene_texture_switcher/scene_marker_sync'

class SceneMarkerSyncTest < Minitest::Test
  Sync = SamMadwar::SceneTextureSwitch::SceneMarkerSync

  def test_repairs_old_marker_and_moves_it_after_reassignment
    Dir.mktmpdir do |root|
      old = write_managed_marker(root, '08', 'strangely long name.txt', 'page-101', 'strangely long name')
      scenes = [{ cue: '04', name: 'strangely long name', scene_key: 'page-101' }]

      result = Sync.sync(root, scenes)

      desired = File.join(root, '04', '04_strangely long name.txt')
      assert File.file?(desired)
      refute File.exist?(old)
      refute Dir.exist?(File.join(root, '08'))
      assert_includes result[:created], desired
      assert_includes result[:removed], old
    end
  end

  def test_rename_creates_replacement_before_removing_managed_old_name
    Dir.mktmpdir do |root|
      old = write_managed_marker(root, '03', '03_Old Name.txt', 'page-101', 'Old Name')

      Sync.sync(root, [{ cue: '03', name: 'New / Name', scene_key: 'page-101' }])

      assert File.file?(File.join(root, '03', '03_New - Name.txt'))
      refute File.exist?(old)
    end
  end

  def test_shared_state_keeps_separate_point_suffixed_markers
    Dir.mktmpdir do |root|
      scenes = [
        { cue: '02', name: 'Kitchen / Night', scene_key: 'page-101' },
        { cue: '02', name: 'Kitchen \\ Night', scene_key: 'page-102' }
      ]

      Sync.sync(root, scenes)

      assert File.file?(File.join(root, '02', '02_Kitchen - Night.txt'))
      assert File.file?(File.join(root, '02', '02_Kitchen - Night.2.txt'))
    end
  end

  def test_deleted_scene_removes_only_managed_marker_and_preserves_user_file
    Dir.mktmpdir do |root|
      marker = write_managed_marker(root, '05', '05_Deleted.txt', 'page-101', 'Deleted')
      user_file = File.join(root, '05', 'notes.txt')
      File.write(user_file, 'keep me')

      Sync.sync(root, [])

      refute File.exist?(marker)
      assert_equal 'keep me', File.read(user_file)
      assert Dir.exist?(File.join(root, '05'))
    end
  end

  def test_never_overwrites_unrelated_text_file_at_desired_name
    Dir.mktmpdir do |root|
      folder = File.join(root, '06')
      FileUtils.mkdir_p(folder)
      user_file = File.join(folder, '06_Finale.txt')
      File.write(user_file, 'user notes')

      Sync.sync(root, [{ cue: '06', name: 'Finale', scene_key: 'page-106' }])

      assert_equal 'user notes', File.read(user_file)
      assert File.file?(File.join(folder, '06_Finale.2.txt'))
    end
  end

  private

  def write_managed_marker(root, cue, filename, scene_key, scene_name)
    folder = File.join(root, cue)
    FileUtils.mkdir_p(folder)
    path = File.join(folder, filename)
    File.write(path, <<~TEXT)
      Scene Texture Switcher label
      Scene: #{scene_name}
      Texture state: #{cue}
      Scene identity: #{scene_key}
    TEXT
    path
  end
end
