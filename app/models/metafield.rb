class Metafield < ShopifyAPI::Metafield
	belongs_to :variant
	def self.cached_metafield(id)
		Rails.cache.fetch('metafield/#{id}/#{cache_key}', expires_in: 12.hours) do
			self.find(id)
		end
	end
end