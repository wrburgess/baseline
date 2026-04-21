require 'rails_helper'

describe Admin::HeaderForNew::Component, type: :component do
  let(:user) { create(:user) }
  let(:instance) { double('Instance', class_name_title: 'Widget') }

  before { sign_in(user) }

  it 'renders the new headline with controller/action classes' do
    render_inline(described_class.new(instance:, action: 'new', controller: 'admin/widgets'))

    expect(page).to have_css('div.admin-widgets.new h2', text: 'Create a New Widget')
  end
end
