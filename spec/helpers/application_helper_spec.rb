require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#file_name_with_timestamp' do
    let(:frozen_time) { Time.local(2024, 12, 19, 14, 30, 0) }
    let(:timestamp) { frozen_time.strftime('%Y-%m-%d_%H-%M-%S') }

    before do
      Time.use_zone(Time.zone) { travel_to(frozen_time) }
    end

    it 'returns filename with timestamp and extension' do
      result = helper.file_name_with_timestamp(file_name: 'report', file_extension: 'xlsx')
      expect(result).to eq("report_#{timestamp}.xlsx")
    end

    it 'handles special characters in filename' do
      result = helper.file_name_with_timestamp(file_name: 'my report!', file_extension: 'csv')
      expect(result).to eq("my report!_#{timestamp}.csv")
    end

    it 'handles different file extensions' do
      extensions = %w[pdf doc xlsx csv txt]
      extensions.each do |ext|
        result = helper.file_name_with_timestamp(file_name: 'report', file_extension: ext)
        expect(result).to eq("report_#{timestamp}.#{ext}")
      end
    end
  end

  describe '#default_date_format' do
    it 'returns same value if a non-date value is submitted' do
      submitted_value = Faker::Lorem.word
      expect(default_date_format(submitted_value)).to eq submitted_value
    end

    it 'returns the properly formatted date value if date is submitted' do
      submitted_value = Faker::Date.between(from: 2.years.ago, to: Time.zone.today)
      expect(default_date_format(submitted_value)).to eq submitted_value.strftime('%b %e, %Y')
    end

    it 'returns nil if nil is submitted' do
      submitted_value = nil
      expect(default_date_format(submitted_value)).to be_nil
    end
  end

  describe '#selector_date_format' do
    it 'formats a date object' do
      date = Date.new(2024, 12, 19)
      expect(helper.selector_date_format(date)).to eq('2024-12-19')
    end

    it 'formats a datetime object' do
      datetime = DateTime.new(2024, 12, 19, 14, 30, 0)
      expect(helper.selector_date_format(datetime)).to eq('2024-12-19')
    end

    it 'returns original value if not a date object' do
      expect(helper.selector_date_format('2024-12-19')).to eq('2024-12-19')
      expect(helper.selector_date_format(nil)).to be_nil
    end

    it 'formats a time object' do
      time = Time.zone.local(2024, 12, 19, 14, 30, 0)
      expect(helper.selector_date_format(time)).to eq('2024-12-19')
    end
  end

  describe '#external_link_to' do
    it 'renders link with default options' do
      link = helper.external_link_to('Google', 'https://google.com')

      expect(link).to have_link('Google', href: 'https://google.com')
      expect(link).to have_css('a[target="_blank"]')
      expect(link).to have_css('a[rel="noopener noreferrer"]')
      expect(link).to have_content('Google')
    end

    it 'merges custom options with defaults' do
      link = helper.external_link_to('Google', 'https://google.com', class: 'btn')

      expect(link).to have_css('a.btn')
      expect(link).to have_css('a[target="_blank"]')
      expect(link).to have_css('a[rel="noopener noreferrer"]')
    end

    it 'allows overriding default options' do
      link = helper.external_link_to('Google', 'https://google.com', target: '_self')

      expect(link).to have_css('a[target="_self"]')
      expect(link).to have_css('a[rel="noopener noreferrer"]')
    end

    it 'renders data attributes' do
      link = helper.external_link_to('Google', 'https://google.com', data: { test: 'value' })

      expect(link).to have_css('a[data-test="value"]')
    end

    it 'escapes HTML in name' do
      link = helper.external_link_to('<script>alert("xss")</script>', 'https://google.com')

      expect(link).not_to include('<script>')
    end
  end

  describe '#boolean_badge' do
    it 'returns a badge with the text "Yes" and a class of "bg-primary" if the parameter is true' do
      expect(helper.boolean_badge(true)).to include('Yes')
      expect(helper.boolean_badge(true)).to include('bg-primary')
    end

    it 'returns a badge with the text "No" and a class of "bg-secondary" if the parameter is false' do
      expect(helper.boolean_badge(false)).to include('No')
      expect(helper.boolean_badge(false)).to include('bg-secondary')
    end
  end
end
