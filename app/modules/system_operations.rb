module SystemOperations
  ARCHIVE = "archive".freeze
  COLLECTION_EXPORT_XLSX = "collection_export_xlsx".freeze
  COMMIT = "commit".freeze
  COPY = "copy".freeze
  CREATE = "create".freeze
  CREATE_FROM_UPLOAD = "create_from_upload".freeze
  DESTROY = "destroy".freeze
  DISAMBIGUATE = "disambiguate".freeze
  DISASSOCIATE = "disassociate".freeze
  EDIT = "edit".freeze
  ENTER_MATCH_NIGHT = "enter_match_night".freeze
  EXPORT_IMPORT_EXAMPLE = "export_import_example".freeze
  IMPERSONATE = "impersonate".freeze
  IMPORT = "import".freeze
  INDEX = "index".freeze
  LINK_FIXTURE = "link_fixture".freeze
  MEMBER_EXPORT_XLSX = "member_export_xlsx".freeze
  MERGE = "merge".freeze
  NEW = "new".freeze
  READ = "read".freeze
  REJECT = "reject".freeze
  SHARE = "share".freeze
  SHOW = "show".freeze
  TRIGGER_PASSWORD_RESET_EMAIL = "trigger_password_reset_email".freeze
  UNARCHIVE = "unarchive".freeze
  UPDATE = "update".freeze
  UPLOAD = "upload".freeze

  def self.options_for_select
    all.map { |item| [ item.upcase, item ] }
  end

  def self.all
    constants.map(&:to_s).map(&:downcase).sort
  end
end
