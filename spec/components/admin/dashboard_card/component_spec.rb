require 'rails_helper'

describe Admin::DashboardCard::Component, type: :component do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'renders the card title and provided links' do
    render_inline(described_class.new(title: 'Reports Overview')) do |component|
      component.with_link(name: 'Recent Reports', url: '/admin/reports/recent')
      component.with_link(name: 'All Reports', url: '/admin/reports')
    end

    expect(page).to have_css('.card-header strong', text: 'Reports Overview')
    expect(page).to have_link('Recent Reports', href: '/admin/reports/recent')
    expect(page).to have_link('All Reports', href: '/admin/reports')
  end

  it 'renders an empty list when no links are supplied' do
    render_inline(described_class.new(title: 'Empty Card'))

    list = page.find('.card-body ul')
    expect(list.all('li').size).to eq(0)
  end
end
