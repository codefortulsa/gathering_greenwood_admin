# frozen_string_literal: true

module EntityBuilders
  extend ActiveSupport::Concern

  def build_building_hash(building, year)
    addresses = building.addresses.to_a
    primary_address = addresses.find(&:is_primary) || addresses.first

    {
      id: building.id,
      name: building.name || "Building #{building.id}",
      year: primary_address&.year || year,
      address: format_address(primary_address),
      latitude: building.latitude,
      longitude: building.longitude,
      confidence_score: 100,
      confidence_reasons: [],
      type: 'building'
    }
  end

  def build_person_hash(person, year)
    {
      id: person.id,
      name: "#{person.first_name} #{person.last_name}".strip,
      sortable_name: "#{person.last_name}, #{person.first_name}".strip,
      year: person.class.name.match(/\d+/)&.to_s || year,
      type: 'person'
    }
  end

  def calculate_building_confidence(building, search_term, year)
    { score: 100, reasons: [] }
  end

  private

  def format_address(address)
    return '' unless address

    parts = [
      address.house_number,
      address.prefix,
      address.name,
      address.suffix
    ].compact.join(' ')
    
    parts += ", #{address.city}" if address.city.present?
    parts
  end
end
