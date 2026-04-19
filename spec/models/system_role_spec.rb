require "rails_helper"

RSpec.describe SystemRole, type: :model do
  it_behaves_like "loggable"

  describe "associations" do
    it { is_expected.to have_many(:system_role_system_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:system_permissions).through(:system_role_system_permissions) }
    it { is_expected.to have_many(:system_group_system_roles).dependent(:destroy) }
    it { is_expected.to have_many(:system_groups).through(:system_group_system_roles) }
    it { is_expected.to have_many(:users).through(:system_groups) }
  end

  describe "validations" do
    subject(:system_role) { build(:system_role) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe ".select_order" do
    it "returns roles sorted by name" do
      second = create(:system_role, name: "Support")
      first = create(:system_role, name: "Admin")

      expect(described_class.select_order.pluck(:id)).to eq([ first.id, second.id ])
    end
  end

  describe ".options_for_select" do
    it "returns pairs of name and id" do
      role = create(:system_role, name: "Manager")

      expect(described_class.options_for_select).to include([ "Manager", role.id ])
    end
  end

  describe ".default_sort" do
    it "returns the default order definition" do
      expect(described_class.default_sort).to eq([ { name: :asc, created_at: :desc } ])
    end
  end

  describe ".ransackable_attributes" do
    it "includes name" do
      expect(described_class.ransackable_attributes).to include("name")
    end
  end

  describe "#update_associations" do
    let(:role) { create(:system_role) }
    let!(:existing_group) { create(:system_group) }
    let!(:replacement_group) { create(:system_group) }
    let!(:existing_permission) { create(:system_permission) }
    let!(:replacement_permission) { create(:system_permission) }

    before do
      SystemGroupSystemRole.create!(system_group: existing_group, system_role: role)
      SystemRoleSystemPermission.create!(system_role: role, system_permission: existing_permission)
    end

    it "replaces associated groups and permissions" do
      role.update_associations(
        system_role: {
          system_group_ids: [ replacement_group.id ],
          system_permission_ids: [ replacement_permission.id ]
        }
      )

      expect(role.system_groups.reload).to contain_exactly(replacement_group)
      expect(role.system_permissions.reload).to contain_exactly(replacement_permission)
    end
  end
end
