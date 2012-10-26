Spree::LineItem.class_eval do

    def creates_subscription?
        line_item = self
        return (
        (line_item.variant.is_master? && line_item.variant.product.subscribable?) || 
        (!line_item.variant.is_master? && line_item.variant.subscribable?)
        )
    end

end
