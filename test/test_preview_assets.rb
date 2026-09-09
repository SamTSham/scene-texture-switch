# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'
require 'tmpdir'
require 'fileutils'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/texture_applier'
require_relative '../source/extension/scene_texture_switcher/preview_assets'

class PreviewAssetsTest < Minitest::Test
  Assets = SamMadwar::SceneTextureSwitch::PreviewAssets

  def test_lists_literal_switchable_files_and_ignores_working_files
    Dir.mktmpdir('preview assets ') do |root|
      folder = File.join(root, '03')
      FileUtils.mkdir_p(folder)
      File.write(File.join(folder, 'Surface01.png'), 'png')
      File.write(File.join(folder, 'Surface01.psd'), 'psd')
      File.write(File.join(folder, 'Surface02.jpg'), 'jpg')

      result = Assets.for_state(root, '03')

      assert_equal %w[Surface01 Surface02], result.map { |asset| asset[:surface] }
      refute result.any? { |asset| asset[:path].end_with?('.psd') }
      assert result.all? { |asset| asset[:url].start_with?('file:') }
      assert_includes result.first[:url], '%20'
    end
  end

  def test_large_preview_path_must_be_supported_and_inside_library
    Dir.mktmpdir do |root|
      folder = File.join(root, '01')
      FileUtils.mkdir_p(folder)
      png = File.join(folder, 'Surface01.png')
      psd = File.join(folder, 'Surface01.psd')
      File.write(png, 'png')
      File.write(psd, 'psd')

      assert Assets.allowed_path?(root, png)
      refute Assets.allowed_path?(root, psd)
      refute Assets.allowed_path?(root, __FILE__)
    end
  end
end
