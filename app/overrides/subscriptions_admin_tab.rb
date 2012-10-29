Deface::Override.new(:virtual_path => 'spree/layouts/admin' ,
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%= tab :subscriptions %>",
                     :name => "subscriptions_admin_tab")
