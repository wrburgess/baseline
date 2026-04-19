require 'rails_helper'

describe Admin::HeaderForUpload::Component, type: :component do
  let(:user) { create(:user) }
  let(:instance) { double('Instance', class_name_title: 'Widget') }

  before { sign_in(user) }

  it 'renders the upload headline with controller/action classes' do
    render_inline(described_class.new(instance:, action: 'upload', controller: 'admin/widgets'))

    expect(page).to have_css('div.admin-widgets.upload h2', text: 'Widget: Upload CSV or XLSX')
  end
end
