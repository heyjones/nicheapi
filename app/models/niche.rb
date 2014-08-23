class Niche
	extend Savon::Model
	client wsdl: 'http://dev8.nicheweb.com.au/feed.asmx?wsdl'
	def self.login()
		client.call(:log_in, message: { userName: 'staff', password: 'staff' })
	end
	def self.logout()
		client.call(:log_out)
	end
	def self.styles()
		client.call(:style_feed)
	end
	def self.products()
		client.call(:product_feed)
	end
	def self.style_products(style)
		client.call(:product_feed_for_style, message: { styleCode: style[:code] })
	end
	def self.order(order)
		response = client.call(:log_in, message: { userName: 'staff', password: 'staff' }).to_hash[:log_in_response][:log_in_result]
		authorization = response.http.cookies
		client.call(:create_order, message: { order: order }, cookies: authorization)
	end
end