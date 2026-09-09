# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'
require 'tmpdir'
require 'fileutils'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/texture_applier'

class TextureApplierTest < Minitest::Test
  Applier = SamMadwar::SceneTextureSwitch::TextureApplier

  FakeTexture = Struct.new(:width, :height, :size)

  class FakeMaterial
    attr_reader :assigned_path
    attr_accessor :texture

    def initialize
      @texture = FakeTexture.new(240, 135, nil)
    end

    def texture=(path)
      @assigned_path = path
      @texture = FakeTexture.new(nil, nil, nil)
    end
  end

  class FakeModel
    attr_reader :materials, :operations

    def initialize(materials)
      @materials = materials
      @operations = []
    end

    def start_operation(*arguments)
      @operations << [:start, arguments]
    end

    def commit_operation
      @operations << [:commit]
    end

    def abort_operation
      @operations << [:abort]
    end
  end

  def test_applies_scene_first_png_and_preserves_mapping_size
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, '03'))
      File.write(File.join(root, '03', 'Surface01.png'), 'png')
      material = FakeMaterial.new
      model = FakeModel.new('Surface01' => material)

      result = Applier.apply(model, root, '3')

      assert_equal :scene_first, result[:layout]
      assert_equal File.join(root, '03', 'Surface01.png'), material.assigned_path
      assert_equal [240, 135], material.texture.size
      assert_equal 1, result[:applied].length
      assert_equal [
        [:start, ['Apply Scene Textures', true, false, true]],
        [:commit]
      ], model.operations
    end
  end

  def test_png_precedes_jpg_but_jpg_is_accepted
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, '03'))
      png = File.join(root, '03', 'Surface01.png')
      jpg = File.join(root, '03', 'Surface01.jpg')
      File.write(png, 'png')
      File.write(jpg, 'jpg')

      assert_equal png, Applier.preferred_texture(root, :scene_first, 'Surface01', '03')
      File.delete(png)
      assert_equal jpg, Applier.preferred_texture(root, :scene_first, 'Surface01', '03')
    end
  end

  def test_one_failed_material_does_not_stop_later_surfaces
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, '01'))
      File.write(File.join(root, '01', 'Surface01.png'), 'one')
      File.write(File.join(root, '01', 'Surface02.png'), 'two')
      bad = FakeMaterial.new
      def bad.texture=(_path)
        raise 'unreadable image'
      end
      good = FakeMaterial.new
      model = FakeModel.new('Surface01' => bad, 'Surface02' => good)

      result = Applier.apply(model, root, '01')

      assert_equal 1, result[:errors].length
      assert_equal 1, result[:applied].length
      assert_match(/Surface02\.png/, good.assigned_path)
      assert_equal 1, model.operations.count { |entry| entry.first == :commit }
    end
  end
end
