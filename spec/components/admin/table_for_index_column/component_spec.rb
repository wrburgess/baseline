require 'rails_helper'

describe Admin::TableForIndexColumn::Component, type: :component do
  it 'exposes the label and stored block' do
    component = described_class.new('Name') { |record| record.name.upcase }

    record = Struct.new(:name).new('alpha')

    expect(component.label).to eq('Name')
    expect(component.td_block.call(record)).to eq('ALPHA')
  end
end
