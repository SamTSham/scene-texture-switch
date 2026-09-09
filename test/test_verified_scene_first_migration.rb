# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/scene_texture_switcher/legacy_library_scanner'
require_relative '../lib/scene_texture_switcher/migration_planner'
require_relative '../lib/scene_texture_switcher/verified_scene_first_migration'
require_relative '../source/extension/scene_texture_switcher/scene_marker_name'

class VerifiedSceneFirstMigrationTest < Minitest::Test
  Scanner = SceneTextureSwitcher::LegacyLibraryScanner
  Planner = SceneTextureSwitcher::MigrationPlanner
  Migration = SceneTextureSwitcher::VerifiedSceneFirstMigration
  MarkerNamer = SamMadwar::SceneTextureSwitch::SceneMarkerName

  def test_copies_verifies_and_labels_without_changing_source
    Dir.mktmpdir do |root|
      source = File.join(root, 'textures')
      destination = File.join(root, 'Textures — Set')
      write_texture(source, 'Surface01', '01.png', 'png-one')
      write_texture(source, 'Surface01', '01.psd', 'working-psd')
      write_texture(source, 'Surface02', '01.jpg', 'jpg-two')
      source_before = snapshot_files(source)
      plan = Planner.new(Scanner.new(source).scan).plan
      scenes = [
        { cue: '01', name: 'Opening / House', scene_key: 'page-101' },
        { cue: '01', name: 'Opening \\ House', scene_key: 'page-102' }
      ]

      result = Migration.new(plan, MarkerNamer).execute(destination, scenes)

      assert result[:success]
      assert_equal source_before, snapshot_files(source)
      assert_equal 'png-one', File.read(File.join(destination, '01', 'Surface01.png'))
      assert_equal 'working-psd', File.read(File.join(destination, '01', 'Surface01.psd'))
      assert_equal 'jpg-two', File.read(File.join(destination, '01', 'Surface02.jpg'))
      assert File.file?(File.join(destination, '01', '01_Opening - House.txt'))
      assert File.file?(File.join(destination, '01', '01_Opening - House.2.txt'))
      assert File.file?(File.join(destination, Migration::REPORT_NAME))
      assert_equal 3, result[:copied].length
      assert result[:copied].all? { |record| record[:sha256].length == 64 }
    end
  end

  def test_preserves_png_and_jpg_alternatives_as_housekeeping_warning
    Dir.mktmpdir do |root|
      source = File.join(root, 'textures')
      destination = File.join(root, 'Scene First Copy')
      write_texture(source, 'Surface01', '01.png', 'preferred')
      write_texture(source, 'Surface01', '01.jpg', 'alternative')
      plan = Planner.new(Scanner.new(source).scan).plan

      result = Migration.new(plan, MarkerNamer).execute(destination, [])

      assert File.file?(File.join(destination, '01', 'Surface01.png'))
      assert File.file?(File.join(destination, '01', 'Surface01.jpg'))
      refute_empty result[:warnings]
    end
  end

  def test_existing_destination_is_never_modified
    Dir.mktmpdir do |root|
      source = File.join(root, 'textures')
      destination = File.join(root, 'Existing')
      write_texture(source, 'Surface01', '01.png', 'texture')
      FileUtils.mkdir_p(destination)
      sentinel = File.join(destination, 'keep.txt')
      File.write(sentinel, 'keep')
      plan = Planner.new(Scanner.new(source).scan).plan

      error = assert_raises(ArgumentError) do
        Migration.new(plan, MarkerNamer).execute(destination, [])
      end

      assert_match(/already exists/, error.message)
      assert_equal 'keep', File.read(sentinel)
    end
  end

  private

  def write_texture(root, surface, filename, contents)
    folder = File.join(root, surface)
    FileUtils.mkdir_p(folder)
    File.write(File.join(folder, filename), contents)
  end

  def snapshot_files(root)
    Dir.glob(File.join(root, '**', '*')).select { |path| File.file?(path) }.sort.to_h do |path|
      [path.sub("#{root}/", ''), File.binread(path)]
    end
  end
end
