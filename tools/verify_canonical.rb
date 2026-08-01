# frozen_string_literal: true

require 'digest'

ROOT = File.expand_path('..', __dir__)

EXPECTED = {
  'vendor/canonical_v1_3/SceneTextureSwitcher_v1.3.rbz' =>
    '597ac446fc10de01732f3483601180cfcdd97e843c937847ddadab3e5844e2ba',
  'source/extension/SceneTextureSwitcher.rb' =>
    '541a98e7bb7b778c9e9bf683a66ad84a224995f071f38dc90d6ce95f6f16060b',
  'source/extension/scene_texture_switcher/core.rb' =>
    'e90671b55e3e00fd07858d3fb27de4dc715530ef9cc0949612c72a3a935c6950',
  'source/extension/scene_texture_switcher/html/dropdown.html' =>
    'fa26c50d1726a29f4b04b64a0ede8e3990deaadb4e2affe464177192fa4c907b'
}.freeze

failures = EXPECTED.each_with_object([]) do |(relative_path, expected), result|
  path = File.join(ROOT, relative_path)
  unless File.file?(path)
    result << "missing: #{relative_path}"
    next
  end

  actual = Digest::SHA256.file(path).hexdigest
  result << "changed: #{relative_path}" unless actual == expected
end

if failures.empty?
  puts 'Canonical v1.3 files verified.'
  exit 0
end

warn failures.join("\n")
exit 1

