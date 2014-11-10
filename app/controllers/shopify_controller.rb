class ShopifyController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def index
	end

	def order
		shopifyOrder = ShopifyAPI.throttle { ShopifyAPI::Order.find(params[:id]) }
  		nicheId = 0
		shopifyMetafields = ShopifyAPI.throttle { shopifyOrder.metafields }
		shopifyMetafields.each do |shopifyMetafield|
			if shopifyMetafield.namespace = 'nicheapi' && shopifyMetafield.key = 'order'
				nicheId = shopifyMetafield.value
			end
		end
		if nicheId == 0
puts 'CREATE'
			phone = shopifyOrder.shipping_address.phone
			if phone == ''
				phone = '1234567890'
			end
			person = {
				:email => shopifyOrder.email,
				:firstName => shopifyOrder.customer.first_name,
				:lastName => shopifyOrder.customer.last_name,
				:address => shopifyOrder.shipping_address.address1,
				:suburb => shopifyOrder.shipping_address.city,
				:state => shopifyOrder.shipping_address.province_code,
				:postcode => shopifyOrder.shipping_address.zip,
				:countryCodeISO3166_A2 => shopifyOrder.shipping_address.country_code,
				:phone => phone,
				:mobile => phone,
				:optInMailingList => shopifyOrder.buyer_accepts_marketing.to_s
			}
			products = []
			shopifyOrder.line_items.each do |line_item|
				product = {
					:Barcode => line_item.sku,
					:qty => line_item.quantity
				}
				products.push(Product: product)
			end
			order = {
				:person => person,
				:products => products,
				:refNo => shopifyOrder.id
			}
puts order
			nicheId = Niche.order(order).to_hash[:create_order_response][:create_order_result]
			#SHOPIFY
			ShopifyAPI.throttle { shopifyOrder.add_metafield(ShopifyAPI::Metafield.new({
                 :description => '',
                 :namespace => 'nicheapi',
                 :key => 'order',
                 :value => nicheId,
                 :value_type => 'integer'
			})) }
puts nicheId
		end
		render status: 200, json: order.to_json
	end

end