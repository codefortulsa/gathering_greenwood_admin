# frozen_string_literal: true

module SearchService
  extend ActiveSupport::Concern

  SEARCH_YEARS = %w[1910 1920 1930 1940].freeze

  def search_for_year(search_term, year)
    {
      buildings: search_buildings(search_term, year),
      people: search_people(search_term, year),
      documents: [],
      narratives: [],
      photos: [],
      videos: [],
      audios: []
    }
  end

  private

  def search_buildings(search_term, year, require_coordinates: false)
    # Find buildings by name/address
    building_ids = Building.joins(:addresses)
            .where('addresses.city ILIKE ? OR addresses.name ILIKE ? OR addresses.searchable_text ILIKE ? OR buildings.name ILIKE ?',
                   "%#{search_term}%", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%")
            .distinct
            .pluck(:id)

    # Also find buildings where matching people lived
    people = search_people(search_term, year)
    people_building_ids = people.map(&:building_id).compact

    # Combine both sets of building IDs
    all_building_ids = (building_ids + people_building_ids).uniq

    # Build the final query
    query = Building.where(id: all_building_ids)
    query = query.where.not(latitude: nil, longitude: nil) if require_coordinates
    query.limit(50).distinct
  end

  def search_people(search_term, year)
    census_class = "Census#{year}Record".constantize rescue nil
    return [] unless census_class

    census_class.where(
      "first_name ILIKE ? OR last_name ILIKE ?",
      "%#{search_term}%", "%#{search_term}%"
    ).limit(50)
  end
end

  def search_documents(search_term, year)
    []
  end

  def search_narratives(search_term, year)
    []
  end

  def search_photos(search_term, year)
    []
  end

  def search_videos(search_term, year)
    []
  end

  def search_audios(search_term, year)
    []
  end
