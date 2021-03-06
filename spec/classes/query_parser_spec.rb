require 'rails_helper'

describe QueryParser do
  context 'one or more site: params in query string' do
    let(:site_params_parser) { QueryParser.new("(site:agency.gov/archives/2015 Site:archive.agency.gov/ site:archive2.agency.gov) govt site stuff") }

    it 'should extract an array of SiteFilter instances' do
      site_filters = site_params_parser.site_filters
      expect(site_filters[:included_sites].size).to eq(3)
      expect(site_filters[:included_sites][0].domain_name).to eq("agency.gov")
      expect(site_filters[:included_sites][0].url_path).to eq("/archives/2015")
      expect(site_filters[:included_sites][1].domain_name).to eq("archive.agency.gov")
      expect(site_filters[:included_sites][1].url_path).to be_nil
      expect(site_filters[:included_sites][2].domain_name).to eq("archive2.agency.gov")
      expect(site_filters[:included_sites][2].url_path).to be_nil
    end

    it 'should make the resulting query available' do
      expect(site_params_parser.remaining_query).to eq("govt site stuff")
    end
  end

  context 'one or more -site: params in query string' do
    let(:site_params_parser) { QueryParser.new("(-site:excluded3.agency.gov/archives/2016 -site:excluded.agency.gov -Site:excluded2.agency.gov) govt site stuff") }

    it 'should extract an array of :excluded_sites as SiteFilters' do
      site_filters = site_params_parser.site_filters
      expect(site_filters[:excluded_sites].size).to eq(3)
      expect(site_filters[:excluded_sites][0].domain_name).to eq("excluded3.agency.gov")
      expect(site_filters[:excluded_sites][0].url_path).to eq("/archives/2016")
      expect(site_filters[:excluded_sites][1].domain_name).to eq("excluded.agency.gov")
      expect(site_filters[:excluded_sites][1].url_path).to be_nil
      expect(site_filters[:excluded_sites][2].domain_name).to eq("excluded2.agency.gov")
      expect(site_filters[:excluded_sites][2].url_path).to be_nil
    end

    it 'should make the resulting query available' do
      expect(site_params_parser.remaining_query).to eq("govt site stuff")
    end
  end
end