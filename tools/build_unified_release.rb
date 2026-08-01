# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)
VERSION = '1.2.0-rc.1'
OUTPUT = ARGV[0] || File.join(ROOT, 'builds', "SceneTextures_#{VERSION}.rbz")
PREVIEW_SOURCE = File.join(ROOT, 'source', 'overview_preview')
SHARED_SOURCE = File.join(ROOT, 'source', 'extension', 'scene_texture_switcher')

Dir.mktmpdir('scene-textures-release') do |stage|
  folder = File.join(stage, 'scene_texture_overview_preview')
  FileUtils.mkdir_p(File.join(folder, 'html'))

  # Primary unified extension and retirement shim for installed dev builds.
  FileUtils.cp(File.join(ROOT, 'source', 'extension', 'SceneTextureSwitcher.rb'), stage)
  FileUtils.cp(File.join(PREVIEW_SOURCE, 'SceneTextureOverviewPreview.rb'), stage)
  FileUtils.cp(File.join(PREVIEW_SOURCE, 'scene_texture_overview_preview', 'core.rb'), folder)
  FileUtils.cp(File.join(PREVIEW_SOURCE, 'scene_texture_overview_preview', 'html', 'settings.html'), File.join(folder, 'html'))

  %w[
    texture_library_status.rb scene_snapshot.rb overview_pages_observer.rb
    scene_assignment.rb library_association.rb texture_applier.rb
    scene_first_bridge.rb scene_marker_name.rb scene_marker_sync.rb
    preview_assets.rb surface_labels.rb
  ].each { |name| FileUtils.cp(File.join(SHARED_SOURCE, name), folder) }
  FileUtils.cp(File.join(SHARED_SOURCE, 'html', 'overview.html'), File.join(folder, 'html'))

  %w[legacy_library_scanner.rb migration_planner.rb verified_scene_first_migration.rb].each do |name|
    FileUtils.cp(File.join(ROOT, 'lib', 'scene_texture_switcher', name), folder)
  end
  FileUtils.cp(File.join(ROOT, 'docs', 'USER_GUIDE.md'), File.join(folder, 'README.md'))

  FileUtils.mkdir_p(File.dirname(File.expand_path(OUTPUT)))
  FileUtils.rm_f(File.expand_path(OUTPUT))
  success = system('zip', '-q', '-r', File.expand_path(OUTPUT), '.', chdir: stage)
  abort 'Could not create unified release RBZ.' unless success
end

puts File.expand_path(OUTPUT)
