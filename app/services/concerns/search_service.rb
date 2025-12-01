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

  def search_buildings(search_term, _year, require_coordinates: false)
    query = Building.joins(:addresses)
            .where('addresses.city ILIKE ? OR addresses.name ILIKE ? OR addresses.searchable_text ILIKE ? OR buildings.name ILIKE ?',
                   "%#{search_term}%", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%")

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
