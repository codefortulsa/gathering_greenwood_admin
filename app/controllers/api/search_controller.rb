# frozen_string_literal: true

module Api
  class SearchController < BaseController
    include EntityBuilders
    include SearchService

    def search
      search_term = params[:search]
      return render_empty_geojson if search_term.blank?

      features = build_geojson_features(search_term)
      geojson = { type: 'FeatureCollection', features: features }

      render json: geojson
    end

    private

    def build_geojson_features(search_term)
      all_features = []

      SEARCH_YEARS.each do |year|
        buildings = search_buildings(search_term, year, require_coordinates: true)
        
        buildings.each do |building|
          next unless building.latitude && building.longitude
          
          # Build simple GeoJSON feature
          feature = {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [building.longitude, building.latitude]
            },
            properties: build_building_hash(building, year)
          }
          
          all_features << feature
        end
      end

      all_features
    end

    def render_empty_geojson
      render json: { type: 'FeatureCollection', features: [] }
    end
  end
end
