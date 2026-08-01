# frozen_string_literal: true

require 'json'
require File.join(__dir__, 'texture_library_status')
require File.join(__dir__, 'scene_snapshot')

module SceneTextureSwitcher
  # Standalone read-only test companion. It does not start a timer, apply a
  # texture, or write model attributes.
  module OverviewPreview
    extend self

    def activate
      if @dialog && @dialog.visible?
        @dialog.bring_to_front
        refresh(@dialog)
        return
      end

      @dialog = UI::HtmlDialog.new({
        :dialog_title => 'Scene Texture Overview — Preview',
        :preferences_key => 'SceneTextureOverviewPreview',
        :scrollable => false,
        :resizable => true,
        :width => 430,
        :height => 520,
        :min_width => 330,
        :min_height => 240,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })
      @dialog.set_file(File.join(__dir__, 'html', 'overview.html'))
      @dialog.add_action_callback('requestSnapshot') do |dialog, _payload|
        refresh(dialog)
      end
      @dialog.set_on_closed { @dialog = nil }
      @dialog.show
    end

    def refresh(dialog = @dialog)
      return unless dialog

      model = Sketchup.active_model
      project_dir = model.path.to_s.empty? ? nil : File.dirname(model.path)
      discovery = TextureLibraryStatus.discover(project_dir)
      snapshot = SceneSnapshot.build(model, discovery)
      dialog.execute_script("SceneTextureOverview.render(#{JSON.generate(snapshot)})")
    rescue StandardError => error
      puts "[SceneTextureOverviewPreview] Refresh failed: #{error.class}: #{error.message}"
    end
  end

  unless file_loaded?(__FILE__)
    UI.menu('Extensions').add_item('Scene Texture Overview — Preview') {
      OverviewPreview.activate
    }
    file_loaded(__FILE__)
  end
end
