require "rails_helper"

RSpec.describe SystemGroup, type: :model do
  it_behaves_like "loggable"

  describe "associations" do
    it { is_expected.to have_many(:system_group_users).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:system_group_users) }
    it { is_expected.to have_many(:system_group_system_roles).dependent(:destroy) }
    it { is_expected.to have_many(:system_roles).through(:system_group_system_roles) }
    it { is_expected.to have_many(:system_permissions).through(:system_roles) }
  end

  describe "validations" do
    subject(:system_group) { build(:system_group) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe ".select_order" do
    it "orders groups alphabetically" do
      second = create(:system_group, name: "Operations")
      first = create(:system_group, name: "Admin")

      expect(described_class.select_order.pluck(:id)).to eq([ first.id, second.id ])
    end
  end

  describe ".options_for_select" do
    it "returns name and id pairs" do
      group = create(:system_group, name: "Support")

      expect(described_class.options_for_select).to include([ "Support", group.id ])
    end
  end

  describe ".default_sort" do
    it "provides the default order definition" do
      expect(described_class.default_sort).to eq([ { name: :asc, created_at: :desc } ])
    end
  end

  describe ".ransackable_attributes" do
    it "includes name" do
      expect(described_class.ransackable_attributes).to include("name")
    end
  end

  describe ".ransackable_associations" do
    it "includes users" do
      expect(described_class.ransackable_associations).to include("users")
    end
  end

  describe "#update_associations" do
    let(:group) { create(:system_group) }
    let!(:existing_user) { create(:user) }
    let!(:replacement_user) { create(:user) }
    let!(:existing_role) { create(:system_role) }
    let!(:replacement_role) { create(:system_role) }

    before do
      SystemGroupUser.create!(system_group: group, user: existing_user)
      SystemGroupSystemRole.create!(system_group: group, system_role: existing_role)
    end

    it "replaces related users and roles" do
      group.update_associations(
        system_group: {
          user_ids: [ replacement_user.id ],
          system_role_ids: [ replacement_role.id ]
        }
      )

      expect(group.users.reload).to contain_exactly(replacement_user)
      expect(group.system_roles.reload).to contain_exactly(replacement_role)
    end
  end
end
