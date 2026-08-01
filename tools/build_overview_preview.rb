# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)
OUTPUT = ARGV[0] || File.join(ROOT, 'builds', 'SceneTextureOverviewPreview_1.1.0-dev.12.rbz')
PREVIEW_SOURCE = File.join(ROOT, 'source', 'overview_preview')
SHARED_SOURCE = File.join(ROOT, 'source', 'extension', 'scene_texture_switcher')

Dir.mktmpdir('scene-texture-overview-preview') do |stage|
  folder = File.join(stage, 'scene_texture_overview_preview')
  FileUtils.mkdir_p(File.join(folder, 'html'))

  FileUtils.cp(File.join(PREVIEW_SOURCE, 'SceneTextureOverviewPreview.rb'), stage)
  FileUtils.cp(File.join(PREVIEW_SOURCE, 'scene_texture_overview_preview', 'core.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'texture_library_status.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'scene_snapshot.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'overview_pages_observer.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'scene_assignment.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'library_association.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'texture_applier.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'scene_first_bridge.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'scene_marker_name.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'scene_marker_sync.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'preview_assets.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'surface_labels.rb'), folder)
  FileUtils.cp(File.join(ROOT, 'lib', 'scene_texture_switcher', 'legacy_library_scanner.rb'), folder)
  FileUtils.cp(File.join(ROOT, 'lib', 'scene_texture_switcher', 'migration_planner.rb'), folder)
  FileUtils.cp(File.join(ROOT, 'lib', 'scene_texture_switcher', 'verified_scene_first_migration.rb'), folder)
  FileUtils.cp(File.join(SHARED_SOURCE, 'html', 'overview.html'), File.join(folder, 'html'))

  FileUtils.mkdir_p(File.dirname(File.expand_path(OUTPUT)))
  FileUtils.rm_f(File.expand_path(OUTPUT))
  success = system('zip', '-q', '-r', File.expand_path(OUTPUT), '.', chdir: stage)
  abort 'Could not create preview RBZ.' unless success
end

puts File.expand_path(OUTPUT)
