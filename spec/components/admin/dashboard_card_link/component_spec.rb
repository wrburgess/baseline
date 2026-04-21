require 'rails_helper'

describe Admin::DashboardCardLink::Component, type: :component do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'renders a link within a list item' do
    render_inline(described_class.new(name: 'All Reports', url: '/admin/reports'))

    expect(page).to have_css('li', text: 'All Reports')
    expect(page).to have_link('All Reports', href: '/admin/reports')
  end

  it 'renders an external link when requested' do
    render_inline(described_class.new(name: 'External Resource', url: 'https://example.com', new_window: true))

    anchor = page.find('li a', text: 'External Resource')
    expect(anchor[:target]).to eq('_blank')
    expect(anchor[:rel]).to include('noopener noreferrer')
  end

  context 'when an authorization policy is provided' do
    let(:policy_instance) { instance_double(Admin::UserPolicy, index?: permitted) }

    before do
      allow(Pundit).to receive(:policy).and_return(policy_instance)
    end

    context 'and policy allows access' do
      let(:permitted) { true }

      it 'renders the link' do
        render_inline(described_class.new(name: 'Users', url: '/admin/users', policy: User))

        expect(page).to have_link('Users', href: '/admin/users')
      end
    end

    context 'and policy denies access' do
      let(:permitted) { false }

      it 'does not render the link' do
        render_inline(described_class.new(name: 'Users', url: '/admin/users', policy: User))

        expect(page).not_to have_link('Users', href: '/admin/users')
      end
    end
  end
end
