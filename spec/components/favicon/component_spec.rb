require 'rails_helper'

describe Favicon::Component, type: :component do
  it 'renders the full favicon link set' do
    allow_any_instance_of(Favicon::Component).to receive(:asset_path) do |_, asset|
      "/assets/#{asset}"
    end

    render_inline(described_class.new)

      expect(page).to have_css("link[rel='icon'][type='image/png'][sizes='96x96'][href*='favicon/favicon-96x96.png']", visible: false)
      expect(page).to have_css("link[rel='icon'][type='image/svg+xml'][href*='favicon/favicon.svg']", visible: false)
      expect(page).to have_css("link[rel='shortcut icon'][href*='favicon/favicon.ico']", visible: false)
      expect(page).to have_css("link[rel='apple-touch-icon'][sizes='180x180'][href*='favicon/apple-touch-icon.png']", visible: false)
  end
end
