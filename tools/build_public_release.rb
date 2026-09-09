# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)
VERSION = '1.0.1'
BASENAME = 'sam_madwar_scene_texture_switch'
OUTPUT = ARGV[0] || File.join(ROOT, 'builds', "SceneTextureSwitch_#{VERSION}.rbz")
CONTROLLER_SOURCE = File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview')
SHARED_SOURCE = File.join(ROOT, 'source', 'extension', 'scene_texture_switcher')

Dir.mktmpdir('scene-texture-switch-public') do |stage|
  folder = File.join(stage, BASENAME)
  FileUtils.mkdir_p(File.join(folder, 'html'))

  FileUtils.cp(File.join(ROOT, 'source', 'public', "#{BASENAME}.rb"), stage)
  FileUtils.cp(File.join(CONTROLLER_SOURCE, 'core.rb'), folder)
  FileUtils.cp(File.join(CONTROLLER_SOURCE, 'html', 'settings.html'), File.join(folder, 'html'))

  %w[
    namespace.rb texture_library_status.rb scene_snapshot.rb
    overview_pages_observer.rb scene_assignment.rb library_association.rb
    texture_applier.rb scene_marker_name.rb scene_marker_sync.rb
    preview_assets.rb surface_labels.rb scene_transition_observer.rb
  ].each { |name| FileUtils.cp(File.join(SHARED_SOURCE, name), folder) }
  FileUtils.cp(File.join(SHARED_SOURCE, 'html', 'overview.html'), File.join(folder, 'html'))

  starter_parent = File.join(folder, 'starter')
  starter = File.join(starter_parent, 'textures - Starter')
  FileUtils.mkdir_p(starter)
  Dir.children(File.join(ROOT, 'assets', 'starter')).each do |entry|
    next if entry.start_with?('.')

    source = File.join(ROOT, 'assets', 'starter', entry)
    FileUtils.cp(source, starter) if File.file?(source)
  end
  %w[01 02 03].each do |cue|
    cue_folder = File.join(starter, cue)
    FileUtils.mkdir_p(cue_folder)
    Dir.children(File.join(ROOT, 'assets', 'starter', cue)).each do |entry|
      next if entry.start_with?('.')

      source = File.join(ROOT, 'assets', 'starter', cue, entry)
      FileUtils.cp(source, cue_folder) if File.file?(source)
    end
  end

  example = File.join(ROOT, 'assets', 'example')
  FileUtils.cp(File.join(example, 'Texture_Test.skp'), starter_parent)
  FileUtils.cp(File.join(example, 'START HERE - Example.txt'), starter_parent)

  guide = File.join(folder, 'guide')
  FileUtils.mkdir_p(guide)
  Dir.children(File.join(ROOT, 'assets', 'guide')).each do |entry|
    next if entry.start_with?('.')

    source = File.join(ROOT, 'assets', 'guide', entry)
    FileUtils.cp(source, guide) if File.file?(source)
  end

  FileUtils.cp(File.join(ROOT, 'docs', 'USER_GUIDE.md'), File.join(folder, 'README.md'))
  FileUtils.cp(File.join(ROOT, 'LICENSE'), folder)

  FileUtils.mkdir_p(File.dirname(File.expand_path(OUTPUT)))
  FileUtils.rm_f(File.expand_path(OUTPUT))
  success = system('zip', '-q', '-r', File.expand_path(OUTPUT), '.', chdir: stage)
  abort 'Could not create public RBZ.' unless success
end

puts File.expand_path(OUTPUT)
