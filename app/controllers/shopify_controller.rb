class ShopifyController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def index
	end

	def order
		@order = ShopifyAPI.throttle { ShopifyAPI::Order.find(params[:id]) }
  		id = 0
  		metafields = ShopifyAPI.throttle { order.metafields }
  		metafields.each do |metafield|
  			if metafield.namespace = 'nicheapi' && metafield.key = 'order'
  				id = metafield.value
  			end
  		end
  		if id == 0
			#NICHE
	 		person = {
				:email => params[:email],
	 			:firstName => params[:customer][:first_name],
				:lastName => params[:customer][:last_name],
				:address => params[:shipping_address][:address1],
				:suburb => params[:shipping_address][:city],
				:state => params[:shipping_address][:province_code],
				:postcode => params[:shipping_address][:zip],
				:countryCodeISO3166_A2 => params[:shipping_address][:country_code],
				:phone => params[:shipping_address][:phone],
				:mobile => params[:shipping_address][:phone],
				:optInMailingList => params[:buyer_accepts_marketing].to_s
	 		}
	 		products = []
	 		params[:line_items].each do |line_item|
	 			product = {
		 			:Barcode => line_item[:sku],
		 			:qty => line_item[:quantity]
	 			}
	 			products.push(Product: product)
	 		end
			order = {
				:person => person,
				:products => products,
				:refNo => @order.id
			}
			id = Niche.order(order).to_hash[:create_order_response][:create_order_result]
			#SHOPIFY
 			ShopifyAPI.throttle { @order.add_metafield(ShopifyAPI::Metafield.new({
                 :description => '',
                 :namespace => 'nicheapi',
                 :key => 'order',
                 :value => id,
                 :value_type => 'integer'
 			})) }
  		end
		render :status => 200
	end

end