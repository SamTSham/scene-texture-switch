# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/scene_texture_switcher/legacy_library_scanner'

class LegacyLibraryScannerTest < Minitest::Test
  Scanner = SceneTextureSwitcher::LegacyLibraryScanner
  DEMO_ROOT = File.expand_path('fixtures/demo_project/textures', __dir__)

  def test_recovered_demo_library_is_ready
    result = Scanner.new(DEMO_ROOT).scan

    assert_empty result[:errors]
    assert_equal %w[Surface01 Surface02], result[:surfaces]
    assert_equal %w[01 02 03], result[:cues].keys
    assert result[:cues].values.all? { |records| records[:summary][:status] == :ready }
    assert_equal 6, result[:files].length
  end

  def test_incomplete_state_lists_missing_surface
    Dir.mktmpdir do |root|
      create_texture(root, 'Surface01', '01.png')
      FileUtils.mkdir_p(File.join(root, 'Surface02'))

      result = Scanner.new(root).scan
      summary = result[:cues]['01'][:summary]

      assert_equal :incomplete, summary[:status]
      assert_equal ['Surface02'], summary[:missing]
    end
  end

  def test_duplicate_extensions_are_conflicts
    Dir.mktmpdir do |root|
      create_texture(root, 'Surface01', '01.png')
      create_texture(root, 'Surface01', '01.jpg')

      result = Scanner.new(root).scan

      assert_equal 1, result[:conflicts].length
      assert_equal :incomplete, result[:cues]['01'][:summary][:status]
    end
  end

  def test_unrelated_files_are_ignored
    Dir.mktmpdir do |root|
      create_texture(root, 'Surface01', '01.png')
      File.write(File.join(root, 'Surface01', 'notes.txt'), '')

      result = Scanner.new(root).scan
      assert_equal ['Surface01/notes.txt'], result[:ignored]
    end
  end

  def test_numeric_working_files_are_permitted_supporting_content
    Dir.mktmpdir do |root|
      create_texture(root, 'Surface01', '01.png')
      create_texture(root, 'Surface01', '01.psd')
      create_texture(root, 'Surface01', '01.tif')

      result = Scanner.new(root).scan

      assert_equal %w[.psd .tif], result[:supporting_files].map { |record| record[:extension] }
      assert_equal :ready, result[:cues]['01'][:summary][:status]
      assert_empty result[:conflicts]
    end
  end

  private

  def create_texture(root, surface, filename)
    folder = File.join(root, surface)
    FileUtils.mkdir_p(folder)
    File.write(File.join(folder, filename), 'fixture')
  end
end
