require 'rails_helper'

describe Admin::TableForShow::Component, type: :component do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'renders title and rows with labels and values' do
    render_inline(described_class.new(title: 'Details')) do |component|
      component.with_row(name: 'Name', value: 'Alpha')
      component.with_row(name: 'Status', value: 'Active')
    end

    expect(page).to have_css('h4.title-header', text: 'Details')
    expect(page).to have_css('table.table.vertical')
    expect(page).to have_css('th', text: 'Name')
    expect(page).to have_css('td', text: 'Alpha')
    expect(page).to have_css('th', text: 'Status')
    expect(page).to have_css('td', text: 'Active')
  end

  it 'omits the header when no title is provided' do
    render_inline(described_class.new) do |component|
      component.with_row(name: 'Name', value: 'Alpha')
    end

    expect(page).not_to have_css('h4.title-header')
  end
end
