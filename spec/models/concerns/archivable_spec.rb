require "rails_helper"

RSpec.describe Archivable do
  let(:described_class) { User }

  describe "#archive!" do
    it "transitions an active record to archived" do
      user = create(:user, archived_at: nil)

      expect { user.archive! }.to change { user.reload.archived? }.from(false).to(true)
      expect(user.archived_at).to be_present
      expect(user.active?).to be false
    end

    it "raises ActiveRecord::RecordInvalid when update! fails" do
      user = create(:user, archived_at: nil)
      allow(user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user))

      expect { user.archive! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#unarchive!" do
    it "transitions an archived record to active" do
      user = create(:user, archived_at: DateTime.current)

      expect { user.unarchive! }.to change { user.reload.active? }.from(false).to(true)
      expect(user.archived_at).to be_nil
      expect(user.archived?).to be false
    end

    it "raises ActiveRecord::RecordInvalid when update! fails" do
      user = create(:user, archived_at: DateTime.current)
      allow(user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user))

      expect { user.unarchive! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
