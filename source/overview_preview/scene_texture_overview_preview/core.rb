# frozen_string_literal: true

require 'json'
require File.join(__dir__, 'texture_library_status')
require File.join(__dir__, 'scene_snapshot')
require File.join(__dir__, 'overview_pages_observer')
require File.join(__dir__, 'scene_assignment')

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
        :dialog_title => 'Scene Texture Overview — Development',
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
      @dialog.add_action_callback('requestSnapshot') do |_action_context|
        refresh(@dialog)
      end
      @dialog.add_action_callback('setCue') do |_action_context, scene_key, cue|
        assign_cue(scene_key, cue)
      end
      @dialog.set_on_closed do
        detach_pages_observer
        @dialog = nil
      end
      @dialog.show
      attach_pages_observer
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

    def assign_cue(scene_key, cue)
      result = SceneAssignment.assign(Sketchup.active_model, scene_key, cue)
      unless result[:success]
        UI.messagebox("Texture assignment was not saved.\n\n#{result[:error]}")
        return
      end

      apply_current_texture(result[:cue]) if result[:current]
      refresh(@dialog)
    end

    def apply_current_texture(cue)
      if defined?(SceneTextureSwitcher::Core) && SceneTextureSwitcher::Core.respond_to?(:apply_all_textures)
        SceneTextureSwitcher::Core.apply_all_textures(cue)
      else
        puts '[SceneTextureOverview] Assignment saved; production switcher is unavailable for immediate application.'
      end
    end

    def schedule_refresh
      return if @refresh_scheduled

      @refresh_scheduled = true
      UI.start_timer(0.1, false) do
        @refresh_scheduled = false
        refresh(@dialog) if @dialog
      end
    end

    def attach_pages_observer
      pages = Sketchup.active_model.pages
      return if @observed_pages.equal?(pages)

      detach_pages_observer
      @pages_observer ||= OverviewPagesObserver.new(self)
      pages.add_observer(@pages_observer)
      @observed_pages = pages
    end

    def detach_pages_observer
      @observed_pages.remove_observer(@pages_observer) if @observed_pages && @pages_observer
      @observed_pages = nil
    rescue StandardError => error
      puts "[SceneTextureOverviewPreview] Could not detach observer: #{error.message}"
      @observed_pages = nil
    end
  end

  unless file_loaded?(__FILE__)
    UI.menu('Extensions').add_item('Scene Texture Overview — Development') {
      OverviewPreview.activate
    }
    file_loaded(__FILE__)
  end
end
