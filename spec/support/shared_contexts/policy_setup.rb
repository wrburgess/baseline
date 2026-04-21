RSpec.shared_context 'policy_setup' do
  let(:user) { create(:user) }
  let(:klass_name) { described_class.to_s.gsub('Policy', '') }
  let(:klass) do
    klass_name.constantize
  rescue NameError
    klass_name.demodulize.constantize
  end
  let(:policy) { described_class.new(user, klass) }

  let(:system_group) { create(:system_group) }
  let(:system_role) { create(:system_role) }
  let(:sp_archive) { create(:system_permission, name: "#{klass} Archive", resource: klass, operation: 'archive') }
  let(:sp_collection_export_xlsx) { create(:system_permission, name: "#{klass} Collection Export Xlsx", resource: klass, operation: 'collection_export_xlsx') }
  let(:sp_copy) { create(:system_permission, name: "#{klass} Copy", resource: klass, operation: 'copy') }
  let(:sp_create) { create(:system_permission, name: "#{klass} Create", resource: klass, operation: 'create') }
  let(:sp_destroy) { create(:system_permission, name: "#{klass} Destroy", resource: klass, operation: 'destroy') }
  let(:sp_edit) { create(:system_permission, name: "#{klass} Edit", resource: klass, operation: 'edit') }
  let(:sp_index) { create(:system_permission, name: "#{klass} Index", resource: klass, operation: 'index') }
  let(:sp_member_export_xlsx) { create(:system_permission, name: "#{klass} Member Export Xlsx", resource: klass, operation: 'member_export_xlsx') }
  let(:sp_new) { create(:system_permission, name: "#{klass} New", resource: klass, operation: 'new') }
  let(:sp_show) { create(:system_permission, name: "#{klass} Show", resource: klass, operation: 'show') }
  let(:sp_update) { create(:system_permission, name: "#{klass} Update", resource: klass, operation: 'update') }
  let(:sp_unarchive) { create(:system_permission, name: "#{klass} Unarchive", resource: klass, operation: 'unarchive') }

  before do
    system_role.system_permissions << [
      sp_archive,
      sp_collection_export_xlsx,
      sp_copy,
      sp_create,
      sp_destroy,
      sp_edit,
      sp_index,
      sp_member_export_xlsx,
      sp_new,
      sp_show,
      sp_unarchive,
      sp_update
    ]
    system_group.system_roles << system_role
    system_group.users << user
  end
end
