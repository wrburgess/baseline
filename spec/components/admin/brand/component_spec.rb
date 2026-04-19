require 'rails_helper'

describe Admin::Brand::Component, type: :component do
  it 'renders with all default values' do
    component = described_class.new
    render_inline(component)

    expect(page).to have_text('Optimus Admin')
    expect(page).to have_text('DEV')
    expect(page).to have_css('.navbar-brand')
  end

  it 'renders component with specified values' do
    component = described_class.new(brand_name: 'Optimus Admin', environment_name: 'staging', classes: 'navbar-test')
    render_inline(component)

    expect(page).to have_text('Optimus Admin')
    expect(page).to have_text('STAGING')
    expect(page).to have_css('.navbar-test')
  end

  it 'renders component for production environment' do
    component = described_class.new(brand_name: 'Optimus Admin', environment_name: 'production', classes: 'navbar-brand')
    render_inline(component)

    expect(page).to have_text('Optimus Admin')
    expect(page).to_not have_text('PRODUCTION')
    expect(page).to have_css('.navbar-brand')
  end
end
