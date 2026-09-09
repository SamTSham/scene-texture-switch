# frozen_string_literal: true

require 'open3'

ROOT = File.expand_path('..', __dir__)
VERSION = '1.0.1'
BASENAME = 'sam_madwar_scene_texture_switch'
ARCHIVE = ARGV[0] || File.join(ROOT, 'builds', "SceneTextureSwitch_#{VERSION}.rbz")

def capture!(*command)
  output, error, status = Open3.capture3(*command)
  abort "Command failed: #{command.join(' ')}\n#{error}" unless status.success?
  output.force_encoding(Encoding::UTF_8).scrub
end

abort "Release is missing: #{ARCHIVE}" unless File.file?(ARCHIVE)

entries = capture!('unzip', '-Z1', ARCHIVE).lines.map(&:chomp).reject(&:empty?)
abort 'Archive contains an unsafe path.' if entries.any? { |entry| entry.start_with?('/') || entry.split('/').include?('..') }
abort 'Archive contains macOS metadata files.' if entries.any? { |entry| File.basename(entry).start_with?('.') }

roots = entries.map { |entry| entry.split('/').first }.uniq.sort
expected_roots = [BASENAME, "#{BASENAME}.rb"].sort
abort "Unexpected RBZ roots: #{roots.inspect}" unless roots == expected_roots

required = [
  "#{BASENAME}.rb",
  "#{BASENAME}/core.rb",
  "#{BASENAME}/namespace.rb",
  "#{BASENAME}/LICENSE",
  "#{BASENAME}/README.md",
  "#{BASENAME}/starter/Texture_Test.skp",
  "#{BASENAME}/starter/textures - Starter/01/Surface01.png"
]
missing = required.reject { |entry| entries.include?(entry) }
abort "Required release files are missing: #{missing.join(', ')}" unless missing.empty?

loader = capture!('unzip', '-p', ARCHIVE, "#{BASENAME}.rb")
abort 'Public loader version is incorrect.' unless loader.include?("EXTENSION.version = '#{VERSION}'")
abort 'Public loader path is incorrect.' unless loader.include?("'#{BASENAME}/core'")

text_extensions = %w[.rb .html .md .txt .json]
forbidden = ['/Users/', '/Volumes/', '_PROJEKTE', '1.2.0-rc', 'SceneTextureOverviewPreview.rb']
entries.select { |entry| text_extensions.include?(File.extname(entry)) }.each do |entry|
  next if entry.include?("\uFFFD") # Info-ZIP may not round-trip Unicode names on macOS.

  content = capture!('unzip', '-p', ARCHIVE, entry)
  found = forbidden.find { |text| content.include?(text) }
  abort "Forbidden development text #{found.inspect} in #{entry}" if found

  if File.extname(entry) == '.rb' && content.match?(/(?<!Sketchup\.)require File\.join/)
    abort "Encrypted-incompatible internal require in #{entry}"
  end
end

controller = capture!('unzip', '-p', ARCHIVE, "#{BASENAME}/core.rb")
abort 'Release must not mutate the open model from a startup safety poll.' if controller.include?('start_scene_safety_polling')

puts "Verified public release: #{ARCHIVE}"
puts "Root loader: #{BASENAME}.rb"
puts "Extension folder: #{BASENAME}/"
puts "Files: #{entries.length}"
