# frozen_string_literal: true

module ConfidenceScoring
  extend ActiveSupport::Concern

  def calculate_building_confidence(building, search_term, year)
    score = 50  # Base score
    match_details = []

    # Basic scoring
    if building.name&.downcase&.include?(search_term.downcase)
      score += 30
      match_details << "Name matches search term"
    end

    building.addresses.each do |address|
      if address.city&.downcase&.include?(search_term.downcase)
        score += 15
        match_details << "City matches search term"
      end
      if address.name&.downcase&.include?(search_term.downcase)
        score += 15
        match_details << "Street matches search term"
      end
    end

    score = [score, 100].min

    {
      confidence: score,
      match_details: match_details
    }
  end
end
