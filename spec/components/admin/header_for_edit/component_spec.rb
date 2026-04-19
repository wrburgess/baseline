require 'rails_helper'

describe Admin::HeaderForEdit::Component, type: :component do
  let(:user) { create(:user) }
  let(:instance) { double('Instance', class_name_title: 'Widget', name: 'Alpha', id: 42) }

  before { sign_in(user) }

  it 'renders the edit headline with controller/action classes' do
    render_inline(described_class.new(instance:, action: 'edit', controller: 'admin/widgets'))

    expect(page).to have_css('div.admin-widgets.edit h2', text: 'Edit Widget: Alpha')
  end
end
