# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/scene_snapshot'

class SceneSnapshotTest < Minitest::Test
  Snapshot = SceneTextureSwitcher::SceneSnapshot

  FakePage = Struct.new(:name, :persistent_id, :cue) do
    def get_attribute(_dictionary, _key, default)
      cue || default
    end
  end

  class FakePages < Array
    attr_accessor :selected_page
  end

  FakeModel = Struct.new(:path, :pages)

  def test_builds_serializable_rows_without_changing_pages
    Dir.mktmpdir do |project|
      texture_root = File.join(project, 'textures')
      FileUtils.mkdir_p(File.join(texture_root, 'Surface01'))
      File.write(File.join(texture_root, 'Surface01', '01.png'), 'texture')

      opening = FakePage.new('Opening', 101, '01')
      finale = FakePage.new('Finale', 102, '02')
      pages = FakePages.new([opening, finale])
      pages.selected_page = finale
      model = FakeModel.new(File.join(project, 'Set.skp'), pages)
      discovery = SceneTextureSwitcher::TextureLibraryStatus.discover(project)

      result = Snapshot.build(model, discovery)

      assert_equal 'Set', result[:model_name]
      assert_equal %w[page-101 page-102], result[:scenes].map { |scene| scene[:scene_key] }
      assert_equal %w[ready missing], result[:scenes].map { |scene| scene[:status] }
      assert_equal [false, true], result[:scenes].map { |scene| scene[:current] }
      assert_equal 1, result[:summary][:attention]
      assert_equal '01', opening.cue
      assert_equal '02', finale.cue
    end
  end

  def test_ambiguous_library_marks_rows_as_conflicts
    page = FakePage.new('Opening', 101, '01')
    pages = FakePages.new([page])
    pages.selected_page = page
    model = FakeModel.new('/Project/Set.skp', pages)
    discovery = { status: :ambiguous, root: nil, candidates: ['/Project/textures', '/Project/Textures — Set'] }

    result = Snapshot.build(model, discovery)

    assert_equal 'conflict', result[:scenes].first[:status]
    assert_equal 1, result[:summary][:conflict]
  end
end
