require "rails_helper"

RSpec.describe SystemOperations do
  describe "constants" do
    it "defines ARCHIVE" do
      expect(described_class::ARCHIVE).to eq("archive")
    end

    it "defines COLLECTION_EXPORT_XLSX" do
      expect(described_class::COLLECTION_EXPORT_XLSX).to eq("collection_export_xlsx")
    end

    it "defines COMMIT" do
      expect(described_class::COMMIT).to eq("commit")
    end

    it "defines COPY" do
      expect(described_class::COPY).to eq("copy")
    end

    it "defines CREATE" do
      expect(described_class::CREATE).to eq("create")
    end

    it "defines CREATE_FROM_UPLOAD" do
      expect(described_class::CREATE_FROM_UPLOAD).to eq("create_from_upload")
    end

    it "defines DESTROY" do
      expect(described_class::DESTROY).to eq("destroy")
    end

    it "defines DISAMBIGUATE" do
      expect(described_class::DISAMBIGUATE).to eq("disambiguate")
    end

    it "defines DISASSOCIATE" do
      expect(described_class::DISASSOCIATE).to eq("disassociate")
    end

    it "defines EDIT" do
      expect(described_class::EDIT).to eq("edit")
    end

    it "defines ENTER_MATCH_NIGHT" do
      expect(described_class::ENTER_MATCH_NIGHT).to eq("enter_match_night")
    end

    it "defines EXPORT_IMPORT_EXAMPLE" do
      expect(described_class::EXPORT_IMPORT_EXAMPLE).to eq("export_import_example")
    end

    it "defines IMPORT" do
      expect(described_class::IMPORT).to eq("import")
    end

    it "defines INDEX" do
      expect(described_class::INDEX).to eq("index")
    end

    it "defines LINK_FIXTURE" do
      expect(described_class::LINK_FIXTURE).to eq("link_fixture")
    end

    it "defines MEMBER_EXPORT_XLSX" do
      expect(described_class::MEMBER_EXPORT_XLSX).to eq("member_export_xlsx")
    end

    it "defines MERGE" do
      expect(described_class::MERGE).to eq("merge")
    end

    it "defines NEW" do
      expect(described_class::NEW).to eq("new")
    end

    it "defines READ" do
      expect(described_class::READ).to eq("read")
    end

    it "defines REJECT" do
      expect(described_class::REJECT).to eq("reject")
    end

    it "defines SHARE" do
      expect(described_class::SHARE).to eq("share")
    end

    it "defines SHOW" do
      expect(described_class::SHOW).to eq("show")
    end

    it "defines UNARCHIVE" do
      expect(described_class::UNARCHIVE).to eq("unarchive")
    end

    it "defines UPDATE" do
      expect(described_class::UPDATE).to eq("update")
    end

    it "defines UPLOAD" do
      expect(described_class::UPLOAD).to eq("upload")
    end
  end

  describe ".all" do
    it "returns the explicit ordered list of all operations" do
      expect(described_class.all).to eq(
        [
          "archive",
          "collection_export_xlsx",
          "commit",
          "copy",
          "create",
          "create_from_upload",
          "destroy",
          "disambiguate",
          "disassociate",
          "edit",
          "enter_match_night",
          "export_import_example",
          "import",
          "index",
          "link_fixture",
          "member_export_xlsx",
          "merge",
          "new",
          "read",
          "reject",
          "share",
          "show",
          "unarchive",
          "update",
          "upload"
        ]
      )
    end

    it "returns frozen strings" do
      described_class.constants.each do |const_name|
        expect(described_class.const_get(const_name)).to be_frozen
      end
    end
  end

  describe ".options_for_select" do
    it "returns an array of uppercase label and lowercase value pairs" do
      options = described_class.options_for_select

      expect(options).to include([ "ARCHIVE", "archive" ])
      expect(options).to include([ "DESTROY", "destroy" ])
      expect(options).to include([ "UNARCHIVE", "unarchive" ])
      expect(options).to include([ "MERGE", "merge" ])
      expect(options).to include([ "ENTER_MATCH_NIGHT", "enter_match_night" ])
    end
  end
end
