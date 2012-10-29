Spree::Gateway::Bogus.class_eval do

  # our code and gateway(s) accepts both credit cards and payment objects
  # to create_profile.
  
  def create_profile(payment)
       # simulate the storage of credit card profile using remote service
      if payment.is_a? Spree::Creditcard
        success = Spree::Gateway::Bogus::VALID_CCS.include? payment.number
        payment.update_attributes(:gateway_customer_profile_id => generate_profile_id(success))
      else
        success = Spree::Gateway::Bogus::VALID_CCS.include? payment.source.number
        payment.source.update_attributes(:gateway_customer_profile_id => generate_profile_id(success))
      end
  end

  def store(creditcard, options = {})
    if Spree::Gateway::Bogus::VALID_CCS.include? creditcard.number
      ActiveMerchant::Billing::Response.new(true, "Bogus Gateway: Forced success", {}, :test => true, :customerCode => '12345')
    else
      ActiveMerchant::Billing::Response.new(false, "Bogus Gateway: Forced failure", {:message => 'Bogus Gateway: Forced failure'}, :test => true)
    end
  end
end
