require 'rails_helper'

describe Admin::HeaderForShow::Component, type: :component do
  let(:user) { create(:user) }
  let(:klass) do
    Class.new do
      def self.name = 'Widget'
    end
  end
  let(:instance) do
    double(
      'Instance',
      class: klass,
      class_name_title: 'Widget',
      class_name_plural: 'Widgets',
      name: 'Alpha',
      archived?: false,
      archived_at: nil
    )
  end

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:polymorphic_path).and_return('/admin/widgets')
  end

  it 'renders breadcrumb link, headline, and archived badge placeholder' do
    render_inline(described_class.new(instance:, action: 'show', controller: 'admin/widgets'))

    expect(page).to have_link('Widgets', href: '/admin/widgets')
    expect(page).to have_css('div.admin-widgets.show h2', text: /Alpha/)
    expect(page).not_to have_css('span.badge')
  end
end
