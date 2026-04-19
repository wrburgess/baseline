require "rails_helper"

RSpec.describe SystemPermission, type: :model do
  it_behaves_like "loggable"

  describe "associations" do
    it { is_expected.to have_many(:system_role_system_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:system_roles).through(:system_role_system_permissions) }
    it { is_expected.to have_many(:system_groups).through(:system_roles) }
    it { is_expected.to have_many(:users).through(:system_groups) }
  end

  describe "validations" do
    subject(:system_permission) { build(:system_permission) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:resource) }
    it { is_expected.to validate_presence_of(:operation) }
  end

  describe ".select_order" do
    it "orders permissions alphabetically" do
      second = create(:system_permission, name: "Beta")
      first = create(:system_permission, name: "Alpha")

      expect(described_class.select_order.pluck(:id)).to eq([ first.id, second.id ])
    end
  end

  describe ".options_for_select" do
    it "returns name and id pairs" do
      permission = create(:system_permission, name: "Reports", operation: "view", resource: "reports")

      expect(described_class.options_for_select).to include([ "Reports", permission.id ])
    end
  end

  describe ".default_sort" do
    it "returns the default sort order" do
      expect(described_class.default_sort).to eq([ { name: :asc, created_at: :desc } ])
    end
  end

  describe ".ransackable_attributes" do
    it "includes name, resource, and operation" do
      expect(described_class.ransackable_attributes).to include("name", "resource", "operation")
    end
  end

  describe "#update_associations" do
    let(:permission) { create(:system_permission) }
    let!(:existing_role) { create(:system_role) }
    let!(:replacement_role) { create(:system_role) }

    before do
      SystemRoleSystemPermission.create!(system_role: existing_role, system_permission: permission)
    end

    it "replaces related roles with provided ids" do
      permission.update_associations(system_permission: { system_role_ids: [ replacement_role.id ] })

      expect(permission.system_roles.reload).to contain_exactly(replacement_role)
    end
  end
end
