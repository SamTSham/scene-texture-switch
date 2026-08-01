# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)
VERSION = '1.2.0-rc.9'
OUTPUT = ARGV[0] || File.join(ROOT, 'builds', "SceneTextureSwitch_#{VERSION}.rbz")
PREVIEW_SOURCE = File.join(ROOT, 'source', 'overview_preview')
SHARED_SOURCE = File.join(ROOT, 'source', 'extension', 'scene_texture_switcher')
STARTER_SOURCE = ENV.fetch(
  'STS_STARTER_SOURCE',
  '/Users/sammadwar/_PROJEKTE/SceneTextureSwitcher/scene_texture_switcher/textures'
)

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
    scene_marker_name.rb scene_marker_sync.rb
    preview_assets.rb surface_labels.rb
    scene_transition_observer.rb
  ].each { |name| FileUtils.cp(File.join(SHARED_SOURCE, name), folder) }
  FileUtils.cp(File.join(SHARED_SOURCE, 'html', 'overview.html'), File.join(folder, 'html'))

  starter = File.join(folder, 'starter', 'textures - Starter')
  FileUtils.mkdir_p(starter)
  Dir.children(File.join(ROOT, 'assets', 'starter')).each do |entry|
    source = File.join(ROOT, 'assets', 'starter', entry)
    FileUtils.cp(source, starter) if File.file?(source)
  end
  %w[01 02 03].each do |cue|
    cue_folder = File.join(starter, cue)
    FileUtils.mkdir_p(cue_folder)
    FileUtils.cp(
      File.join(ROOT, 'assets', 'starter', cue, "_PICTURE SET #{cue}.txt"),
      cue_folder
    )
    %w[Surface01 Surface02].each do |surface|
      source = File.join(STARTER_SOURCE, surface, "#{cue}.png")
      abort "Starter picture is missing: #{source}" unless File.file?(source)

      FileUtils.cp(source, File.join(cue_folder, "#{surface}.png"))
    end
  end
  example = File.join(ROOT, 'assets', 'example')
  FileUtils.cp(File.join(example, 'Texture-Test.skp'), File.dirname(starter))
  FileUtils.cp(File.join(example, 'START HERE - Example.txt'), File.dirname(starter))
  FileUtils.cp(File.join(ROOT, 'docs', 'USER_GUIDE.md'), File.join(folder, 'README.md'))
  guide = File.join(folder, 'guide')
  FileUtils.mkdir_p(guide)
  Dir.children(File.join(ROOT, 'assets', 'guide')).each do |entry|
    source = File.join(ROOT, 'assets', 'guide', entry)
    FileUtils.cp(source, guide) if File.file?(source)
  end

  FileUtils.mkdir_p(File.dirname(File.expand_path(OUTPUT)))
  FileUtils.rm_f(File.expand_path(OUTPUT))
  success = system('zip', '-q', '-r', File.expand_path(OUTPUT), '.', chdir: stage)
  abort 'Could not create unified release RBZ.' unless success
end

puts File.expand_path(OUTPUT)
