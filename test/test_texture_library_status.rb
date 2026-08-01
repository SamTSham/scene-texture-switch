# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'

class TextureLibraryStatusTest < Minitest::Test
  Status = SamMadwar::SceneTextureSwitch::TextureLibraryStatus

  def test_texture_folder_suffix_is_only_a_human_label
    %w[textures texturesAnything].each { |name| assert_match Status::LIBRARY_NAME, name }
    assert_match Status::LIBRARY_NAME, 'Textures WHATEVER HELPS ME'
    assert_match Status::LIBRARY_NAME, 'textures — Hamlet'
    refute_match Status::LIBRARY_NAME, '_textures-old'
  end

  def test_discovers_plain_and_project_named_texture_folders
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, 'Textures — Hamlet'))

      result = Status.discover(root)

      assert_equal :found, result[:status]
      assert_equal 'Textures — Hamlet', File.basename(result[:root])
    end
  end

  def test_multiple_compatible_folders_are_ambiguous
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, 'textures'))
      FileUtils.mkdir_p(File.join(root, 'Textures - Hamlet'))

      result = Status.discover(root)

      assert_equal :ambiguous, result[:status]
      assert_nil result[:root]
      assert_equal 2, result[:candidates].length
    end
  end

  def test_ready_incomplete_missing_and_conflict_are_distinct
    Dir.mktmpdir do |root|
      %w[Surface01 Surface02].each { |surface| FileUtils.mkdir_p(File.join(root, surface)) }
      write_texture(root, 'Surface01', '01.png')
      write_texture(root, 'Surface02', '01.jpg')
      write_texture(root, 'Surface01', '02.png')
      write_texture(root, 'Surface01', '04.png')
      write_texture(root, 'Surface01', '04.jpg')

      assert_equal :ready, Status.legacy_state(root, '01')[:status]
      assert_equal :incomplete, Status.legacy_state(root, '02')[:status]
      assert_equal :missing, Status.legacy_state(root, '03')[:status]
      assert_equal :conflict, Status.legacy_state(root, '04')[:status]
      assert_equal ['Surface02'], Status.legacy_state(root, '02')[:missing]
    end
  end

  def test_zero_surfaces_is_missing_not_ready
    Dir.mktmpdir do |root|
      state = Status.legacy_state(root, '01')

      assert_equal :missing, state[:status]
      assert_equal 0, state[:required_count]
    end
  end

  def test_association_resolves_several_compatible_folders
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, 'textures'))
      FileUtils.mkdir_p(File.join(root, 'Textures — Set'))

      result = Status.discover(root, 'Textures — Set')

      assert_equal :found, result[:status]
      assert result[:associated]
      assert_equal 'Textures — Set', File.basename(result[:root])
    end
  end

  def test_missing_associated_folder_is_not_silently_replaced
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, 'textures'))

      result = Status.discover(root, 'Textures — Missing')

      assert_equal :associated_missing, result[:status]
      assert_nil result[:root]
    end
  end

  def test_scene_first_layout_reports_readiness_and_alternatives
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, '01'))
      FileUtils.mkdir_p(File.join(root, '02'))
      File.write(File.join(root, '01', 'Surface01.png'), 'one')
      File.write(File.join(root, '01', 'Surface02.jpg'), 'two')
      File.write(File.join(root, '02', 'Surface01.png'), 'one')
      File.write(File.join(root, '02', 'Surface01.jpg'), 'alternative')

      assert_equal :scene_first, Status.layout(root)
      assert_equal :ready, Status.state(root, '01')[:status]
      assert_equal :conflict, Status.state(root, '02')[:status]
      assert_equal ['Surface02'], Status.state(root, '02')[:missing]
    end
  end

  private

  def write_texture(root, surface, filename)
    File.write(File.join(root, surface, filename), 'texture')
  end
end
