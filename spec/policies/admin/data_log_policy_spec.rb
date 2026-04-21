require 'rails_helper'

describe Admin::DataLogPolicy, type: :policy do
  include_context 'policy_setup'

  describe '#index?' do
    it 'allows access if user has index permission' do
      expect(policy.index?).to be_truthy
    end

    it 'denies access if user does not have index permission' do
      system_role.system_permissions.delete(sp_index)
      expect(policy.index?).to be_falsey
    end
  end

  describe '#show?' do
    it 'allows access if user has show permission' do
      expect(policy.show?).to be_truthy
    end

    it 'denies access if user does not have show permission' do
      system_role.system_permissions.delete(sp_show)
      expect(policy.show?).to be_falsey
    end
  end
end
