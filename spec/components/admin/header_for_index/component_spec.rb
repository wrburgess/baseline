require 'rails_helper'

describe Admin::HeaderForIndex::Component, type: :component do
  let(:user) { create(:user) }
  let(:klass) do
    Class.new do
      def self.name = 'Widget'
    end
  end
  let(:instance) { klass.new }

  before { sign_in(user) }

  it 'renders the index headline and optional filter link' do
    render_inline(described_class.new(instance:, action: 'index', controller: 'admin/widgets', show_filtering: true))

    expect(page).to have_css('div.admin-widgets.index h2', text: 'Widgets')
    expect(page).to have_css('a[data-bs-target="#filters"] i.bi.bi-filter-right')
  end
end
