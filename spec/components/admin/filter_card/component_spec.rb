require 'rails_helper'

describe Admin::FilterCard::Component, type: :component do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'renders the default title and yields content inside the offcanvas body' do
    render_inline(described_class.new) do
      'Filter form content'
    end

    expect(page).to have_css('div.offcanvas#filters')
    expect(page).to have_css('h5#filtersLabel', text: 'Filters')
    expect(page).to have_text('Filter form content')
    expect(page).to have_css('button.btn-close[data-bs-dismiss="offcanvas"]')
  end

  it 'renders a custom title when provided' do
    render_inline(described_class.new(title: 'Search Filters')) { 'Content' }

    expect(page).to have_css('h5#filtersLabel', text: 'Search Filters')
  end
end
