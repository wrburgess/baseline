require 'rails_helper'

describe Admin::DashboardPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:system_group) { create(:system_group) }
  let(:system_role) { create(:system_role) }
  let(:sp_archive) { create(:system_permission, name: 'User Archive', resource: 'User', operation: 'archive') }
  let(:policy) { described_class.new(user, :dashboard) }

  before do
    system_role.system_permissions << sp_archive
    system_group.system_roles << system_role
    system_group.users << user
  end

  describe '#index?' do
    it 'allows access if user has index permission' do
      expect(policy.index?).to be_truthy
    end

    it 'denies access if user does not have index permission' do
      system_role.system_permissions.destroy_all
      expect(policy.index?).to be_falsey
    end
  end
end
