require 'rails_helper'

describe Admin::TableForAssociations::Component, type: :component do
  let(:user) { create(:user) }
  let(:data) do
    [
      { name: 'Alpha', count: 2 },
      { name: 'Beta', count: 5 }
    ]
  end

  before do
    sign_in(user)
  end

  it 'renders the title, column headers, and cell values' do
    render_inline(described_class.new(data:, title: 'Related Associations')) do |component|
      component.with_column(label: 'Name') { |row| row[:name] }
      component.with_column(label: 'Members', header: true) { |row| "#{row[:count]} members" }
    end

    expect(page).to have_css('h4.table-header', text: 'Related Associations')
    expect(page).to have_css('thead th', text: 'Name')
    expect(page).to have_css('thead th', text: 'Members')

    first_row = page.all('tbody tr').first
    expect(first_row).to have_css('td', text: 'Alpha')
    expect(first_row).to have_css('th', text: '2 members')
  end

  it 'renders a row for each data entry' do
    render_inline(described_class.new(data:)) do |component|
      component.with_column(label: 'Name') { |row| row[:name] }
    end

    rows = page.all('tbody tr')
    expect(rows.size).to eq(2)
    expect(rows.first).to have_text('Alpha')
    expect(rows.last).to have_text('Beta')
  end
end
