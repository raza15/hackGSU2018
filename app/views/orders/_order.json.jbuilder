json.extract! order, :id, :order_id, :item_name, :item_quantity, :created_at, :updated_at
json.url order_url(order, format: :json)
