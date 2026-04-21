require 'rails_helper'

describe Admin::NavItem::Component, type: :component do
  it 'renders a nav bar item' do
    render_inline(described_class.new(title: 'Nav Item Title'))
    expect(page.find('ul.navbar-nav li.nav-item a.nav-link')).to have_text('Nav Item Title')
  end

  # This test is only for making sure we have the dropdown_item slot for this component,
  # and won't validate the presence of the dropdown item since it's rendered conditionally.
  # We'll test this behavior correctly in the specs for Admin::NavDropdownItemComponent.
  it 'renders dropdown items if specified' do
    render_inline(described_class.new(title: 'Nav Item Title') do |nav_item|
      nav_item.with_dropdown_item(name: 'Dropdown Item', path: '/dropdown_path', model: User)
    end)

    expect(page.find('ul.navbar-nav li.nav-item a.nav-link')).to have_text('Nav Item Title')
  end
end
