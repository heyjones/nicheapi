class Niche
	extend Savon::Model
	client wsdl: 'http://dev8.nicheweb.com.au/feed.asmx?wsdl'
	def self.styles()
		client.call(:style_feed)
	end
	def self.products()
		client.call(:product_feed)
	end
	def self.style_products(style)
		client.call(:product_feed_for_style, message: { styleCode: style[:code] })
	end
end