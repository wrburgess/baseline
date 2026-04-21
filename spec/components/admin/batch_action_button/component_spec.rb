require 'rails_helper'

describe Admin::BatchActionButton::Component, type: :component do
  it 'renders a submit button with provided attributes' do
    render_inline(described_class.new(:archive, label: 'Archive Selected'))

    button = page.find('button[type="submit"]')
    expect(button[:name]).to eq('archive')
    expect(button[:class]).to include('btn btn-primary')
    expect(button['data-admin--batch-actions-target']).to eq('actionButton')
    expect(button).to have_text('Archive Selected')
  end
end
