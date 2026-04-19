require 'rails_helper'

describe Admin::BatchActionModalButton::Component, type: :component do
  it 'renders a trigger button with modal attributes and content' do
    render_inline(described_class.new(:archive, label: 'Archive Selected')) do
      'Modal body content'
    end

    button = page.find('button[type="button"]', text: 'Archive Selected')
    expect(button[:name]).to eq('archive')
    expect(button[:class]).to include('btn btn-primary')
    expect(button['data-admin--batch-actions-target']).to eq('actionButton')
    expect(button['data-bs-toggle']).to eq('modal')
    expect(button['data-bs-target']).to eq('#modal_archive')

    modal = page.find('#modal_archive.modal')
    expect(modal).to have_text('Archive Selected')
    expect(modal).to have_text('Modal body content')
    expect(modal).to have_button('Close')
    expect(modal).to have_button('Archive Selected')
  end
end
